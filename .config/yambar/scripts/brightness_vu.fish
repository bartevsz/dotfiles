#!/usr/bin/env fish

while true
    set dev amdgpu_bl1
    set max 64764
    set cur (brightnessctl -d $dev g 2>/dev/null)

    set levels 1 2.4 4.9 8.7 14.2 22.1 33.4 49.1 70.6 100

    set -l vals
    for s in $levels
        set vals $vals (math "$max * $s / 100")
    end

    set filled 0
    for v in $vals
        if test $cur -ge $v
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
    echo ""
    sleep 1
end
