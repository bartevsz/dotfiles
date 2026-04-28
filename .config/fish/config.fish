if status is-interactive
    set_color normal
    clear
    fastfetch
end

function fish_prompt
    set_color 00F0D8 # Ścieżka w Neon Teal
    echo -n (prompt_pwd)' '
    
    # Detektor Distroboxa (Prawdziwa nazwa kontenera)
    if test -f /run/.containerenv
        set container_name (awk -F\" '/name=/ {print $2}' /run/.containerenv)
        set_color yellow
        echo -n "[📦 $container_name] "
    end
    
    set_color FF5E00 # Strzałka w Plazmowym Pomarańczu
    echo -n 'λ '
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
    
    # Bezpieczne ładowanie ścieżek NPM (tylko jeśli zainstalowany)
    if command -v npm > /dev/null
        set -Ux fish_user_paths (npm prefix -g)/bin $fish_user_paths
    end

    if test (tty) = /dev/tty1
        exec dbus-run-session Hyprland
    end
end

if test -z "$DBUS_SESSION_BUS_ADDRESS"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
end
