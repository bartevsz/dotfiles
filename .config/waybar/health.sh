#!/bin/bash

# Zbieranie danych o procesorze
f=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)
if [ -n "$f" ]; then
    m=$((f/1000))
    if [ "$m" -gt 2500 ]; then
        cpu_speed="$m MHz (Turbo)"
    else
        cpu_speed="$m MHz (Power Save)"
    fi
else
    cpu_speed="N/A"
fi

cpu_usg=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.1f%", usage}')
temp=$(sensors 2>/dev/null | awk '/Tctl|Package id 0/ {print $2; exit}' | tr -d '+')

# RAM i Dysk
ram_usg=$(free -h | awk '/^Mem:/ {print $3}')
disk_usg=$(df -h / | awk 'NR==2 {print $5}')

# Liczenie pakietów (Cicha i szybka metoda)
rpm_count=$(rpm -qa 2>/dev/null | wc -l)
flat_count=$(flatpak list 2>/dev/null | wc -l)

# Formatowanie tekstu
info="Taktowanie: $cpu_speed\nObciążenie: $cpu_usg ($temp)\nRAM: $ram_usg\nDysk: $disk_usg\nPakiety: $rpm_count (rpm), $flat_count (flatpak)"

# Reakcja na kliknięcie
if [ "$1" == "--popup" ]; then
    zenity --info --title="Health Summary" --text="<b>Stan Systemu:</b>\n\n$info" --width=250
    exit 0
fi

echo "{\"text\": \"\", \"tooltip\": \"$info\"}"
