if status is-interactive
    set_color normal
    clear
    fastfetch
end

# Nowa, krótsza ścieżka
fish_add_path /home/mb/.spicetify

function fish_prompt
    set_color 8aadf4
    echo -n (prompt_pwd)
    set_color D9E0EE
    echo -n ' ❯ '
    set_color normal
end

if status is-interactive
    # Zastępuje cat przez bat dla ładniejszych wydruków
    abbr -a cat 'bat'
    
    # Szybki podgląd struktury Twojego mózgu (braIN)
    abbr -a lsb 'tree ~/Dokumenty/braIN/'
end
