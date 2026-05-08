function zrob_raport
    set ext $argv[1]
    if test -z "$ext"
        set ext "jpg"
    end
    
    echo "Raport taktyczny: Rozpoczynam operację CHRONOLOGIA..."
    
    # Skanujemy teren przez find, żeby uniknąć wybuchu powłoki Fish
    set pliki (find . -maxdepth 1 -iname "slajd*.$ext" -type f)
    
    if test (count $pliki) -eq 0
        echo "Melduję pusty radar, Szefie! Brak plików Slajd*.$ext w sektorze."
        echo "Czy na pewno mamy tu pliki z rozszerzeniem .$ext? (Jeśli to PNG, odpal: zrob_raport png)"
        return 1
    end
    
    echo "Namierzono "(count $pliki)" celów. Przystępuję do wyrównania szeregów..."
    
    # Etap 1: Zmiana nazw
    for plik in $pliki
        set numer (string match -r '\d+' $plik)
        if test -n "$numer"
            # Generujemy nową, sterylną nazwę bez ścieżki "./"
            set nowy_plik (printf "Slajd%03d.%s" $numer $ext)
            set czysty_plik (string replace "./" "" $plik)
            
            if test "$czysty_plik" != "$nowy_plik"
                mv "$plik" "$nowy_plik"
                echo "Przemianowano: $czysty_plik -> $nowy_plik"
            end
        end
    end
    
    # Sprawdzamy zasoby logistyczne
    if not type -q img2pdf
        echo "Brak img2pdf na wyposażeniu! Uruchamiam awaryjny zrzut zaopatrzenia..."
        sudo dnf install img2pdf -y
    end
    
    echo "Scalam wyselekcjonowane cele..."
    
    # Etap 2: Zbieramy gotowe pliki, sortujemy je alfabetycznie i przekazujemy jako listę argumentów
    set posortowane_pliki (find . -maxdepth 1 -iname "slajd*.$ext" -type f | sort)
    
    img2pdf $posortowane_pliki -o Zabezpieczona_Prezentacja.pdf
    
    echo "Misja zakończona, Skipper! Cel zneutralizowany i zarchiwizowany w Zabezpieczona_Prezentacja.pdf."
end
