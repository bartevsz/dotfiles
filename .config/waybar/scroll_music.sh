#!/bin/bash

# Sprawdzamy status dowolnego aktywnego odtwarzacza
if ! playerctl status > /dev/null 2>&1; then
    echo "Brak odtwarzania"
    exit 0
fi

# Format: Wykonawca - Tytuł • Album (Rok)
# Usunięto flagę -p spotify, aby skrypt był uniwersalny
# sed "s/&/\&amp;/g" rozwiązuje błędy parsowania GTK widoczne w logach
exec zscroll -l 39 \
    --delay 0.15 \
    --scroll-padding " • " \
    --match-command "playerctl status 2>/dev/null || echo 'Stopped'" \
    --match-text "Playing" "--scroll 1" \
    --match-text "Paused" "--scroll 0" \
    --match-text "Stopped" "--scroll 0" \
    --update-check true "bash -c 'A=\"\$(playerctl metadata --format \"{{artist}}\" 2>/dev/null)\"; T=\"\$(playerctl metadata --format \"{{title}}\" 2>/dev/null)\"; AL=\"\$(playerctl metadata --format \"{{album}}\" 2>/dev/null)\"; Y=\"\$(~/.config/waybar/get_year.sh \"\$A\" \"\$AL\")\"; echo \"\$A - \$T • \$AL (\$Y)\" | sed \"s/&/\&amp;/g\"'" 2>/dev/null
