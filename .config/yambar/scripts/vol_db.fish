#!/usr/bin/fish

while true
    if command -sq amixer
        # Pobieramy linię dla głównego kanału
        set info (amixer sget Master | grep -m1 "Front Left:")
        
        # Wyciągamy wartość z drugiego nawiasu (procenty)
        set vol (echo $info | awk -F'[][]' '{print $2}')
        
        # Sprawdzamy, czy nie jest wyciszone [off]
        # Używamy zmiennej vol_state, by nie drażnić fisha słowem 'status'
        set vol_state (echo $info | grep -q "\[off\]"; and echo "MUTE"; or echo "$vol")
        
        echo "vol_state|string|$vol_state"
    else
        echo "vol_state|string|ERR"
    end
    echo ""
    sleep 1
end
