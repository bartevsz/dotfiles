#!/usr/bin/fish

set dev ""

for path in /sys/block/*
    set name (basename $path)

    if string match -rq '^(nvme[0-9]+n[0-9]+|sd[a-z]+|vd[a-z]+)$' "$name"
        if test -e "$path/stat"
            set dev $name
            break
        end
    end
end

if test -z "$dev"
    echo "io|string|󰋊 err"
    echo ""
    exit 0
end

set stat /sys/block/$dev/stat

set b1 (string split -n ' ' (string trim (cat $stat)))
sleep 1
set b2 (string split -n ' ' (string trim (cat $stat)))

set rbytes (math "($b2[3] - $b1[3]) * 512")
set wbytes (math "($b2[7] - $b1[7]) * 512")

function human
    set v $argv[1]

    if test "$v" -ge 1048576
        printf "%.1fM" (math "$v / 1048576")
    else if test "$v" -ge 1024
        printf "%.0fK" (math "$v / 1024")
    else
        printf "%dB" $v
    end
end

set r (human $rbytes)
set w (human $wbytes)

echo "io|string|R $r  W $w"
echo ""
