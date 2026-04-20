function obsidian --argument filename
    set -q filename[1]; or set filename "index.md"
    set filename (realpath $filename)
    set basename (basename $filename .md)

    set tmp_dir /tmp/obsidian-preview
    mkdir -p $tmp_dir
    set html_file $tmp_dir/$basename.html

    pandoc $filename -o $html_file -s --mathjax --metadata title=$basename

    python3 ~/.config/fish/obsidian_server.py &
    set server_pid $last_pid

    sleep 0.5
    set encoded (string replace -a ' ' '%20' $basename)
    firefox "http://localhost:8080/$encoded.html" &

    nvim $filename

    kill $server_pid 2>/dev/null
end
