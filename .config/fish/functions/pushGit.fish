function pushGit --description 'Synchronizacja konfiguracji nvima i Obsidian z bazą dotfiles oraz push na Git'
    set -l dotfiles ~/dotfiles
    set -l errors 0

    # Skaner: czy baza dotfiles istnieje?
    if not test -d $dotfiles
        echo "Skipper, baza dotfiles nie odnaleziona pod $dotfiles!"
        return 1
    end

    # Mapa ładunków: źródło -> cel
    set -l sources \
        ~/.config/nvim/init.lua \
        ~/.config/fish/functions/obsidian.fish \
        ~/.config/fish/functions/syncNvim.fish \
        ~/.config/fish/functions/radar.fish \
        ~/.config/fish/functions/links.fish \
        ~/.config/fish/functions/tasks.fish \
        ~/.config/fish/functions/daily.fish \
        ~/.config/fish/functions/omni.fish \
        ~/.config/fish/functions/broken.fish \
        ~/.config/fish/obsidian_server.py \
        ~/.config/fish/functions/midori-profiles.fish

    set -l destinations \
        $dotfiles/.config/nvim/init.lua \
        $dotfiles/.config/fish/functions/obsidian.fish \
        $dotfiles/.config/fish/functions/syncNvim.fish \
        $dotfiles/.config/fish/functions/radar.fish \
        $dotfiles/.config/fish/functions/links.fish \
        $dotfiles/.config/fish/functions/tasks.fish \
        $dotfiles/.config/fish/functions/daily.fish \
        $dotfiles/.config/fish/functions/omni.fish \
        $dotfiles/.config/fish/functions/broken.fish \
        $dotfiles/.config/fish/obsidian_server.py \
        $dotfiles/.config/fish/functions/midori-profiles.fish

    # Przygotowanie lądowisk
    mkdir -p $dotfiles/.config/nvim
    mkdir -p $dotfiles/.config/fish/functions

    # Transport ładunków do bazy
    for i in (seq (count $sources))
        set src $sources[$i]
        set dst $destinations[$i]
        if test -f $src
            cp -f $src $dst
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

    # ==========================================
    # ZINTEGROWANY MODUŁ PUSH GIT
    # ==========================================
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
    
    # Wystrzelenie na serwer i przechwycenie statusu
    git push
    set -l push_status $status
    
    if test "$is_dotfiles" = "true"
        cd $current_dir
    end
    
    # Prawdziwy system weryfikacji sukcesu
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
