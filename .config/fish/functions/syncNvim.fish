function syncNvim --description 'Synchronizacja konfiguracji nvima i Obsidian z bazą dotfiles'
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
        ~/.config/fish/functions/pushGit.fish \
        ~/.config/fish/functions/syncNvim.fish \
        ~/.config/fish/functions/radar.fish \
        ~/.config/fish/functions/links.fish \
        ~/.config/fish/functions/tasks.fish \
        ~/.config/fish/functions/daily.fish \
        ~/.config/fish/functions/omni.fish \
        ~/.config/fish/functions/broken.fish \
        ~/.config/fish/obsidian_server.py

    set -l destinations \
        $dotfiles/.config/nvim/init.lua \
        $dotfiles/.config/fish/functions/obsidian.fish \
        $dotfiles/.config/fish/functions/pushGit.fish \
        $dotfiles/.config/fish/functions/syncNvim.fish \
        $dotfiles/.config/fish/functions/radar.fish \
        $dotfiles/.config/fish/functions/links.fish \
        $dotfiles/.config/fish/functions/tasks.fish \
        $dotfiles/.config/fish/functions/daily.fish \
        $dotfiles/.config/fish/functions/omni.fish \
        $dotfiles/.config/fish/functions/broken.fish \
        $dotfiles/.config/fish/obsidian_server.py

    # Przygotowanie lądowisk
    mkdir -p $dotfiles/.config/nvim
    mkdir -p $dotfiles/.config/fish/functions

    # Transport ładunków do bazy
    for i in (seq (count $sources))
        set src $sources[$i]
        set dst $destinations[$i]
        if test -f $src
            cp $src $dst
            echo "Załadowano: "(basename $src)
        else
            echo "Uwaga: brak pliku $src — pomijam."
            set errors (math $errors + 1)
        end
    end

    # Raport końcowy
    if test $errors -gt 0
        echo "Transport zakończony z $errors brakami w ładunku."
    else
        echo "Wszystkie jednostki załadowane. Przystępuję do transmisji..."
    end

    # Przekazanie do pushGit
    if test (count $argv) -eq 0
        pushGit "Aktualizacja konfiguracji nvim + Obsidian"
    else
        pushGit $argv
    end
end
