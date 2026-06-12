#!/usr/bin/env fish
# disk_io.fish — prędkość I/O dysku dla yambar (tryb polled)
# Instalacja: cp disk_io.fish ~/.config/yambar/scripts/disk_io.fish && chmod +x ~/.config/yambar/scripts/disk_io.fish

set dev (lsblk -dno NAME | string match -r '^(nvme|sd|vd)' | head -1)
if test -z "$dev"
    set dev (lsblk -dno NAME | head -1)
end

if test -z "$dev"
    echo "io|string|󰋊 err"
    echo ""
    exit 0
end

set stat /sys/block/$dev/stat

set b1 (cat $stat)
sleep 1
set b2 (cat $stat)

set r1 (echo $b1 | awk '{print $3}')
set r2 (echo $b2 | awk '{print $3}')
set w1 (echo $b1 | awk '{print $7}')
set w2 (echo $b2 | awk '{print $7}')

# Sektory po 512 bajtów → bajty/s
set rbytes (math "($r2 - $r1) * 512")
set wbytes (math "($w2 - $w1) * 512")

function human
    set v $argv[1]
    if test (math "$v >= 1048576") = 1
        printf "%.1fM" (math "$v / 1048576")
    else if test (math "$v >= 1024") = 1
        printf "%.0fK" (math "$v / 1024")
    else
        printf "%dB" $v
    end
end

set r (human $rbytes)
set w (human $wbytes)

echo "io|string|$r↓ $w↑"
echo ""
