function img2pdf
    echo "Raport taktyczny: Parsowanie parametrów dla img2pdf..."
    
    set -l pliki
    set -l opcje
    set -l skip_next 0
    
    # Etap 1: Zaawansowana separacja plików od flag i ścieżek wyjściowych
    for i in (seq 1 (count $argv))
        if test $skip_next -eq 1
            set skip_next 0
            continue
        end
        
        set arg $argv[$i]
        
        # Łapiemy flagę wyjścia i jej wartość (np. -o /tajna/sciezka/wynik.pdf)
        if string match -q "-o" -- $arg; or string match -q "--output" -- $arg
            set opcje $opcje $arg $argv[(math $i + 1)]
            set skip_next 1
        else if string match -q "-*" -- $arg
            # Inne flagi
            set opcje $opcje $arg
        else if test -f "$arg"
            # To jest fizycznie istniejący plik
            set pliki $pliki "$arg"
        else
            # Pozostałe argumenty (np. wartości dla innych flag), wrzucamy do opcji
            set opcje $opcje "$arg"
        end
    end
    
    if test (count $pliki) -eq 0
        echo "Brak plików wejściowych! Przekazuję kontrolę do systemowego narzędzia..."
        command img2pdf $argv
        return
    end
    
    echo "Korekta indeksacji plików..."
    
    # Etap 2: Niewrażliwa na przedrostki zmiana nazw (zero-padding)
    set -l nowe_pliki
    for plik in $pliki
        # Izolujemy katalog od samej nazwy pliku, by nie podmienić cyfr w ścieżce
        set dir (dirname "$plik")
        set base (basename "$plik")
        
        # Szukamy jakiegokolwiek ciągu cyfr w nazwie
        set numer (string match -r '\d+' $base)
        
        if test -n "$numer"
            # Formatujemy do 3 cyfr
            set padded_numer (printf "%03d" $numer)
            # Podmieniamy wyizolowany numer w nazwie bazowej
            set nowa_baza (string replace -r '\d+' $padded_numer $base)
            set nowy_plik "$dir/$nowa_baza"
            
            if test "$plik" != "$nowy_plik"
                mv "$plik" "$nowy_plik"
                echo "Zabezpieczono chronologię: $plik -> $nowy_plik"
                set plik "$nowy_plik"
            end
        end
        # Dodajemy zaktualizowaną ścieżkę do nowej puli
        set nowe_pliki $nowe_pliki "$plik"
    end
    
    # Sprawdzenie magazynu
    if not type -q command img2pdf
        echo "Brak narzędzia bazowego! Zrzut logistyczny w toku..."
        sudo dnf install img2pdf -y
    end
    
    # Etap 3: Ułożenie taktyczne i finałowy atak
    set -l posortowane_pliki (printf "%s\n" $nowe_pliki | sort)
    
    echo "Składam ostateczny dokument wg poprawnej chronologii..."
    command img2pdf $posortowane_pliki $opcje
    echo "Misja zakończona sukcesem, Szefie!"
end
