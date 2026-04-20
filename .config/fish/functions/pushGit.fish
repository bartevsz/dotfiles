function pushGit --description 'Inteligentny zrzut zaopatrzenia'
    # Zapisujemy Twoje obecne współrzędne
    set -l current_dir (pwd)
    set -l is_dotfiles false
    
    # Skaner taktyczny: czy jesteśmy w repozytorium Git?
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Skipper, znajdujemy się w sektorze cywilnym! Przekierowuję współrzędne prosto do bazy ~/dotfiles..."
        cd ~/dotfiles
        set is_dotfiles true
    end
    
    # Krok 1: Zabezpieczenie ładunku
    git add .
    
    # Krok 2: Oznaczanie ładunku
    if test (count $argv) -eq 0
        git commit -m "Automatyczny raport sytuacyjny z pola walki"
    else
        git commit -m "$argv"
    end
    
    # Krok 3: Wystrzelenie na serwer
    git push
    
    # Krok 4: Cichy powrót na początkowe współrzędne (jeśli wykonaliśmy skok)
    if test "$is_dotfiles" = "true"
        cd $current_dir
    end
    
    echo "Operacja pushGit zakończona pełnym sukcesem, Szefie!"
end
