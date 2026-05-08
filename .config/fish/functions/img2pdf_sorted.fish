function img2pdf_sorted

    if not type -q img2pdf
        echo "Brak programu img2pdf"
        return 1
    end
    
    set -l output "output.pdf"
    set -l files
    
    set -l skip 0
    
    for arg in $argv
    
        if test $skip -eq 1
            set output $arg
            set skip 0
            continue
        end
        
        if test "$arg" = "-o"
            set skip 1
            continue
        end
        
        set files $files $arg
        
    end
    
    if test (count $files) -eq 0
        echo "Brak plików wejściowych"
        return 1
    end
    
    # jeśli output nie jest absolutny
    if not string match -q "/*" -- $output
        set output "$PWD/$output"
    end
    
    # naturalne sortowanie
    set files (printf "%s\n" $files | sort -V)
    
    echo "Plik wyjściowy:"
    echo $output
    
    echo "Kolejność:"
    printf '%s\n' $files
    
    command img2pdf $files -o $output
    
end
