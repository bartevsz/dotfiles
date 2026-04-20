if status is-interactive
    set_color normal
    clear
    fastfetch
end

function fish_prompt
    set_color 00F0D8 # Ścieżka w Neon Teal
    echo -n (prompt_pwd)
    set_color FF5E00 # Strzałka w Plazmowym Pomarańczu
    echo -n 'λ  '
    set_color normal
end

if not set -q XDG_RUNTIME_DIR
    set -gx XDG_RUNTIME_DIR /tmp/(id -u)
    mkdir -m 0700 -p $XDG_RUNTIME_DIR
end

if status is-login
    ulimit -s 8192
    fish_add_path /sbin
    fish_add_path /home/mb/.spicetify
    set -Ux fish_user_paths (npm prefix -g)/bin $fish_user_paths
    if test (tty) = /dev/tty1
        exec dbus-run-session Hyprland
    end
end

if test -z "$DBUS_SESSION_BUS_ADDRESS"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
end
