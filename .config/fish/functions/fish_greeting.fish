function fish_greeting
    if test -f ~/.config/pingwiny/slowka.txt
        # Pobieramy 3 losowe linie z pliku
        set -l wybrane (shuf -n 3 ~/.config/pingwiny/slowka.txt)
        
        echo (set_color yellow)"[RAPORT KOWALSKIEGO] - Slovíčka dňa:"(set_color normal)
        
        # Pętla wyświetlająca każde słówko w nowej linii z wcięciem
        for slowko in $wybrane
            echo (set_color cyan)"  -> "(set_color normal)$slowko
        end
    else
        echo (set_color red)"Błąd: Brak pliku ze słówkami w ~/.config/pingwiny/"(set_color normal)
    end
end

