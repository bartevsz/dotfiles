function pushGit --description 'Synchronizacja konfiguracji z bazą dotfiles oraz push na Git'
    set -l dotfiles ~/dotfiles
    set -l errors 0

    # Skaner: czy baza dotfiles istnieje?
    if not test -d $dotfiles
        echo "Skipper, baza dotfiles nie odnaleziona pod $dotfiles!"
        return 1
    end

    # Przygotowanie lądowisk
    mkdir -p $dotfiles/.config/nvim
    mkdir -p $dotfiles/.config/fish/functions

    # === ŁADUNEK 1: init.lua ===
    set -l nvim_src ~/.config/nvim/init.lua
    if test -f $nvim_src
        cp -f $nvim_src $dotfiles/.config/nvim/init.lua
        echo "Załadowano: init.lua"
    else
        echo "Uwaga: brak pliku $nvim_src — pomijam."
        set errors (math $errors + 1)
    end

    # === ŁADUNEK 2: obsidian_server.py ===
    set -l server_src ~/.config/fish/obsidian_server.py
    if test -f $server_src
        cp -f $server_src $dotfiles/.config/fish/obsidian_server.py
        echo "Załadowano: obsidian_server.py"
    else
        echo "Uwaga: brak pliku $server_src — pomijam."
        set errors (math $errors + 1)
    end

    # === ŁADUNEK 3: wszystkie funkcje fish ===
    for src in ~/.config/fish/functions/*.fish
        if test -f $src
            cp -f $src $dotfiles/.config/fish/functions/(basename $src)
            echo "Załadowano: "(basename $src)
        else
            echo "Uwaga: brak pliku $src — pomijam."
            set errors (math $errors + 1)
        end
    end

    # Raport końcowy kopiowania
    if test $errors -gt 0
        echo "Transport zakończony z $errors brakami w ładunku."
    else
        echo "Wszystkie jednostki załadowane. Przystępuję do transmisji Git..."
    end

    # === MODUŁ GIT PUSH ===
    set -l current_dir (pwd)
    set -l is_dotfiles false

    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Skipper, znajdujemy się w sektorze cywilnym! Przekierowuję współrzędne prosto do bazy ~/dotfiles..."
        cd ~/dotfiles
        set is_dotfiles true
    end

    git add .

    if test (count $argv) -eq 0
        git commit -m "Aktualizacja konfiguracji nvim + Obsidian"
    else
        git commit -m "$argv"
    end

    git push
    set -l push_status $status

    if test "$is_dotfiles" = "true"
        cd $current_dir
    end

    if test $push_status -eq 0
        set_color green
        echo "Operacja zakończona pełnym sukcesem, Szefie!"
        set_color normal
    else
        set_color red
        echo "KRYTYCZNA AWARIA! Dowództwo odrzuciło nasz ładunek (Kod błędu: $push_status)."
        set_color normal
    end
end
