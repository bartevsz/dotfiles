function omni
    cd /home/Obsidian; and fzf --preview 'bat --color=always {}' --bind 'enter:execute(nvim {})'
end
