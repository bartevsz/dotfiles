function reload-fonts --wraps='fc-cache -f -v' --description 'alias reload-fonts=fc-cache -f -v'
    fc-cache -f -v $argv
end
