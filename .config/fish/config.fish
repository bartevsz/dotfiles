if status is-interactive
    set_color normal
    ulimit -s 8192
    clear
    fastfetch
end

fish_add_path /sbin
fish_add_path /home/mb/.spicetify

function fish_prompt
    set_color 00F0D8 # Ścieżka w Neon Teal
    echo -n (prompt_pwd)
    set_color FF5E00 # Strzałka w Plazmowym Pomarańczu
    echo -n 'λ  '
    set_color normal
end

if status is-interactive
    abbr -a cat 'bat'
    abbr -a lsb 'tree ~/Dokumenty/braIN/'
end

if not set -q XDG_RUNTIME_DIR
    set -gx XDG_RUNTIME_DIR /tmp/(id -u)
    mkdir -m 0700 -p $XDG_RUNTIME_DIR
end

if status is-login
    if test (tty) = /dev/tty1
        exec dbus-run-session Hyprland
    end
end
