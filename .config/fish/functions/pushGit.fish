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
    mkdir -p $dotfiles/midori

    # === ŁADUNEK 1: init.lua ===
    set -l nvim_src ~/.config/nvim/init.lua
    if test -f $nvim_src && not test -L $nvim_src
        cp -f $nvim_src $dotfiles/.config/nvim/init.lua
        echo "Załadowano: init.lua"
    else if test -L $nvim_src
        echo "Pomijam: init.lua (symlink — już zsynchronizowany)"
    else
        echo "Uwaga: brak pliku $nvim_src — pomijam."
        set errors (math $errors + 1)
    end

    # === ŁADUNEK 2: obsidian_server.py ===
    set -l server_src ~/.config/fish/obsidian_server.py
    if test -f $server_src && not test -L $server_src
        cp -f $server_src $dotfiles/.config/fish/obsidian_server.py
        echo "Załadowano: obsidian_server.py"
    else if test -L $server_src
        echo "Pomijam: obsidian_server.py (symlink — już zsynchronizowany)"
    else
        echo "Uwaga: brak pliku $server_src — pomijam."
        set errors (math $errors + 1)
    end

    # === ŁADUNEK 3: wszystkie funkcje fish ===
    for src in ~/.config/fish/functions/*.fish
        if test -L $src
            echo "Pomijam: "(basename $src)" (symlink — już zsynchronizowany)"
        else if test -f $src
            cp -f $src $dotfiles/.config/fish/functions/(basename $src)
            echo "Załadowano: "(basename $src)
        else
            echo "Uwaga: brak pliku $src — pomijam."
            set errors (math $errors + 1)
        end
    end

    # === ŁADUNEK 4: Midori user.js ===
    # Dynamiczne wykrywanie aktywnego profilu z profiles.ini
    set -l profiles_ini ~/.config/mozilla/midori/profiles.ini
    if test -f $profiles_ini
        # Szukamy Default= w sekcji [Install...] — to aktywny profil
        set -l active_profile (grep -A1 '^\[Install' $profiles_ini | grep '^Default=' | head -1 | cut -d= -f2)
        if test -n "$active_profile"
            set -l midori_profile_dir ~/.config/mozilla/midori/$active_profile
            set -l midori_user_js $midori_profile_dir/user.js
            set -l dotfiles_user_js $dotfiles/midori/user.js

            # Upewniamy się że dotfiles/midori/user.js istnieje
            if not test -f $dotfiles_user_js
                echo "Uwaga: brak $dotfiles_user_js — tworzę pusty szablon."
                echo '# Midori (Firefox) user preferences' > $dotfiles_user_js
                set errors (math $errors + 1)
            end

            # Symlinkujemy wszystkie istniejące profile (obsługa przyszłych profili)
            for profile_dir in ~/.config/mozilla/midori/*.default ~/.config/mozilla/midori/*.default-release
                if test -d $profile_dir
                    set -l target $profile_dir/user.js
                    if test -L $target
                        echo "Pomijam: "(basename $profile_dir)"/user.js (symlink — już zsynchronizowany)"
                    else
                        # Jeśli istnieje zwykły plik — najpierw go backupujemy
                        if test -f $target
                            cp -f $target $target.bak
                            echo "Backup: "(basename $profile_dir)"/user.js → user.js.bak"
                        end
                        ln -sf $dotfiles_user_js $target
                        echo "Podlinkowano: "(basename $profile_dir)"/user.js → dotfiles/midori/user.js"
                    end
                end
            end
        else
            echo "Uwaga: nie znaleziono aktywnego profilu Midori w profiles.ini"
            set errors (math $errors + 1)
        end
    else
        echo "Pomijam: Midori profiles.ini nie odnalezione (przeglądarka niezainstalowana?)"
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
