function mail_to_obsidian
    set source_dir ~/Temporary/MailExport
    set target_dir ~/Dokumenty/braIN/99_ZASOBY/Emaile/Tresc
    
    for file in $source_dir/*.eml
        if test -f $file
            set filename (basename $file .eml)
            # Konwersja treści do Markdown (wymaga pandoc)
            pandoc $file -o $target_dir/$filename.md
            # Przeniesienie oryginału do archiwum
            mv $file ~/Temporary/MailArchive/
            echo "Zimportowano: $filename"
        end
    end
end
