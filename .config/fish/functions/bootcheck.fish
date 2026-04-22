function bootcheck
    doas dmesg | awk -F'[][]' '{gsub(/ /, "", $2); if (NR>1 && prev != "") printf "%.6f [s] |%s\n", $2 - prev, $3; prev=$2}' | sort -nr | head -n 10
end
