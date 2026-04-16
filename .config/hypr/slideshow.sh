#!/bin/bash

DIR="$HOME/Obrazy/hyprland_Wallpapers"
MONITOR="eDP-1"

while true; do
    for WALLPAPER in "$DIR"/*; do
        # Pomijaj, jeśli to nie jest plik
        [ -f "$WALLPAPER" ] || continue

        # Załaduj nową tapetę do pamięci
        hyprctl hyprpaper preload "$WALLPAPER"

        # Ustaw tapetę na monitorze
        hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER"

        # Wywal z pamięci RAM nieużywane tapety
        hyprctl hyprpaper unload unused

        # Czekaj 30 sekund
        sleep 30
    done
done
