function broken
    rg -oIN "\[\[(.*?)\]\]" /home/Obsidian | sort | uniq -c
end
