#!/usr/bin/env fish
while true
    # Automatyczne wykrywanie katalogu podświetlenia (bl0 lub bl1)
    set dev_dir (ls -d /sys/class/backlight/amdgpu_bl* 2>/dev/null)[1]
    
    if test -n "$dev_dir"
        set max (cat $dev_dir/max_brightness)
        set cur (cat $dev_dir/brightness)
        set percent (math -s0 "100 * $cur / $max")

        # Progi procentowe dla paska znakowego
        set levels 1 2 4 8 14 22 33 49 70 100
        set filled 0
        for s in $levels
            if test $percent -ge $s
                set filled (math $filled + 1)
            end
        end

        set bar ""
        for i in (seq 1 10)
            if test $i -le $filled
                set bar "$bar▮"
            else
                set bar "$bar▯"
            end
        end
        echo "brightness|string|$bar"
    else
        echo "brightness|string|▯▯▯▯▯▯▯▯▯▯"
    end
    echo ""
    sleep 1
end
