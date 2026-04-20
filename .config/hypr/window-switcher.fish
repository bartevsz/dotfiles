#!/usr/bin/fish

# Pobieramy listę okien w formacie: "adres tytuł"
# Używamy jq, żeby wyciągnąć dane z Hyprlanda
set choice (hyctl clients -j | jq -r '.[] | "\(.address) \(.title)"' | wofi --show dmenu --prompt "Wybierz okno:")

# Jeśli użytkownik coś wybrał (nie nacisnął Esc)
if test -n "$choice"
    # Wycinamy adres (pierwszy człon przed spacją)
    set addr (string split " " $choice)[1]
    # Rozkazujemy Hyprlandowi skoczyć do tego adresu
    hyprctl dispatch focuswindow address:$addr
end
