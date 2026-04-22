#!/usr/bin/fish
while true
    # Niezawodne pobranie zużycia przez vmstat (idle odjęte od 100)
    set idle (vmstat 1 2 | tail -1 | awk '{print $15}')
    set load (math 100 - $idle)
    
    set freq (awk -F':' '/cpu MHz/ {sum+=$2; count++} END {printf "%8.1f", sum/count}' /proc/cpuinfo)
    set temp (math (cat /sys/class/thermal/thermal_zone0/temp) / 1000)
    
    echo "load|string|$load"
    echo "freq|string|$freq"
    echo "temp|int|$temp"
    echo ""
    sleep 2
end
