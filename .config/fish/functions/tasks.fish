function tasks --argument mode
    if test "$mode" = "done"
        rg "- \[x\]" /home/Obsidian
    else
        rg "- \[ \]" /home/Obsidian
    end
end
