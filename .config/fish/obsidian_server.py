#!/usr/bin/env python3
import http.server
import threading
import time
import os
import queue
import urllib.parse
from pathlib import Path

SERVE_DIR = Path("/tmp/obsidian-preview")
PORT = 8080
SERVE_DIR.mkdir(parents=True, exist_ok=True)

clients = []
clients_lock = threading.Lock()
current_file = {"name": ""}

INJECT = b"""
<script>
(function() {
  var es = new EventSource('/sse');
  es.onmessage = function(e) {
    if (e.data === 'reload') {
      window.location.reload();
    } else if (e.data.startsWith('redirect:')) {
      window.location.href = e.data.split('redirect:')[1];
    }
  };
  es.onerror = function() {
    setTimeout(function() { window.location.reload(); }, 1000);
  };
})();
</script>
"""

def watch_files():
    mtimes = {}
    while True:
        try:
            for f in SERVE_DIR.glob("*.html"):
                mtime = f.stat().st_mtime
                if f in mtimes and mtimes[f] != mtime:
                    notify_clients("reload")
                mtimes[f] = mtime
        except Exception:
            pass
        time.sleep(0.3)

def notify_clients(msg):
    with clients_lock:
        dead = []
        for q in clients:
            try:
                q.put(msg)
            except Exception:
                dead.append(q)
        for q in dead:
            clients.remove(q)

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        path = urllib.parse.unquote(self.path.lstrip("/"))

        if self.path == "/sse":
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Cache-Control", "no-cache")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            q = queue.Queue()
            with clients_lock:
                clients.append(q)
            try:
                while True:
                    try:
                        msg = q.get(timeout=15)
                        self.wfile.write(f"data: {msg}\n\n".encode())
                        self.wfile.flush()
                    except queue.Empty:
                        self.wfile.write(b": ping\n\n")
                        self.wfile.flush()
            except Exception:
                with clients_lock:
                    if q in clients:
                        clients.remove(q)
            return

        if self.path.startswith("/switch/"):
            name = urllib.parse.unquote(self.path[8:])
            current_file["name"] = name
            encoded = urllib.parse.quote(name)
            notify_clients(f"redirect:/{encoded}.html")
            self.send_response(200)
            self.end_headers()
            return

        if self.path == "/" or path == "":
            if current_file["name"]:
                encoded = urllib.parse.quote(current_file["name"])
                self.send_response(302)
                self.send_header("Location", f"/{encoded}.html")
                self.end_headers()
            else:
                files = sorted(SERVE_DIR.glob("*.html"))
                if files:
                    name = urllib.parse.quote(files[0].name)
                    self.send_response(302)
                    self.send_header("Location", f"/{name}")
                    self.end_headers()
                else:
                    self.send_response(200)
                    self.end_headers()
                    self.wfile.write(b"<p>Brak plikow HTML w /tmp/obsidian-preview/</p>")
            return

        file_path = SERVE_DIR / path
        if not file_path.exists():
            self.send_response(404)
            self.end_headers()
            self.wfile.write(f"<p>Nie znaleziono: {path}</p>".encode())
            return

        content = file_path.read_bytes()
        if file_path.suffix == ".html":
            content = content.replace(b"</body>", INJECT + b"</body>")
            if b"</body>" not in content:
                content += INJECT

        self.send_response(200)
        if file_path.suffix == ".html":
            self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)

threading.Thread(target=watch_files, daemon=True).start()

server = http.server.ThreadingHTTPServer(("", PORT), Handler)
print(f"Serwer: http://localhost:{PORT}")
try:
    server.serve_forever()
except KeyboardInterrupt:
    pass
