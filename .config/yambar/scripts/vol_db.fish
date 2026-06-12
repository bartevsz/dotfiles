#!/usr/bin/fish
while true
    if command -sq amixer
        set info (amixer sget Master | string match -r '\[\d+%\].*')
        
        if test -n "$info"
            # Wyciągamy procenty i stan [on/off] za pomocą wbudowanego regexa
            set vol (string match -r '\d+%' $info)
            set state (string match -r '\[on\]|\[off\]' $info)

            if test "$state" = "[off]"
                echo "vol_state|string|MUTE"
            else
                echo "vol_state|string|$vol"
            end
        else
            echo "vol_state|string|ERR"
        end
    else
        echo "vol_state|string|ERR"
    end
    echo ""
    sleep 1
end

