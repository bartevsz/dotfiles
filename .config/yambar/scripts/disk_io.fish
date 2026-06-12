k_io.fish — prędkość I/O dysku dla yambar (tryb polled)

# Poprawka 1: Dokładniejsze celowanie w nazwę dysku (uwzględnia pełne nazwy NVMe)
set dev (lsblk -dno NAME | grep -E '^(nvme[0-9]n[0-9]|sd[a-z]|vd[a-z])' | head -1)
if test -z "$dev"
    set dev (lsblk -dno NAME | head -1)
end

# Zabezpieczenie przed brakiem pliku stat
if test -z "$dev"; or not test -e "/sys/block/$dev/stat"
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

# Sektory po 512 bajtów → wynik w [Bajty/sekundę]
set rbytes (math "($r2 - $r1) * 512")
set wbytes (math "($w2 - $w1) * 512")

function human
    set v $argv[1]
    # Poprawka 2: Użycie natywnego polecenia test zamiast logicznego math
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

echo "io|string|$r↓ $w↑"
echo ""
