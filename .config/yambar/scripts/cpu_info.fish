#!/usr/bin/fish
while true
    # Pobieramy pierwszą linię /proc/stat i wyciągamy czasy CPU
    set stat1 (string split ' ' (head -n 1 /proc/stat))[3..6]
    sleep 1
    set stat2 (string split ' ' (head -n 1 /proc/stat))[3..6]

    # Obliczamy deltę obciążenia
    set diff_user (math $stat2[1] - $stat1[1])
    set diff_nice (math $stat2[2] - $stat1[2])
    set diff_sys (math $stat2[3] - $stat1[3])
    set diff_idle (math $stat2[4] - $stat1[4])

    set total (math $diff_user + $diff_nice + $diff_sys + $diff_idle)
    if test $total -gt 0
        set load (math -s0 "100 * ($total - $diff_idle) / $total")
    else
        set load 0
    end

    # Taktowanie (w MHz) – czysty parsujący string zamiast awk
    set freq_raw (string match -r 'cpu MHz\s*:\s*([0-9.]+)' (cat /proc/cpuinfo))[2]
    # Wyciągamy średnią lub bierzemy pierwszy rdzeń (najlżejsza opcja dla Alpine)
    set freq (math -s1 $freq_raw[1])

    # Temperatura z jądra
    set temp (math -s0 (cat /sys/class/thermal/thermal_zone0/temp) / 1000)
    
    echo "load|string|$load"
    echo "freq|string|$freq"
    echo "temp|int|$temp"
    echo ""
    sleep 1
end


