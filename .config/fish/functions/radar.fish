function radar
    rg -oIN "#[A-Za-z0-9_żółćęśąźńŻÓŁĆĘŚĄŹŃ-]+" /home/Obsidian | sort | uniq -c | sort -nr
end
