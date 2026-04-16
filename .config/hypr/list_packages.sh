#!/bin/bash

# Lokalizacja w Twoim sejfie braIN
TARGET_DIR="$HOME/Dokumenty/braIN/99_ZASOBY/Dokumenty"
FILE="$TARGET_DIR/System_Inventory.md"

# Nagłówek notatki Obsidianowej
echo "---" > "$FILE"
echo "tags: [system, backup, inventory]" >> "$FILE"
echo "last_update: $(date +'%Y-%m-%d %H:%M')" >> "$FILE"
echo "---" >> "$FILE"
echo "# 📦 Inwentaryzacja Systemowa" >> "$FILE"
echo "Wygenerowano: $(date)" >> "$FILE"

# 1. DNF & RPM
echo -e "\n## 🖥️ Pakiety RPM (DNF)" >> "$FILE"
echo '```text' >> "$FILE"
rpm -qa --qf '%{NAME}-%{VERSION}\n' | sort >> "$FILE"
echo '```' >> "$FILE"

# 2. FLATPAK
echo -e "\n## 📦 Aplikacje Flatpak" >> "$FILE"
echo '```text' >> "$FILE"
if command -v flatpak &> /dev/null; then
    flatpak list --columns=application,name,version >> "$FILE"
else
    echo "Brak zainstalowanego Flatpaka." >> "$FILE"
fi
echo '```' >> "$FILE"

# 3. SNAP
echo -e "\n## ⚡ Pakiety Snap" >> "$FILE"
echo '```text' >> "$FILE"
if command -v snap &> /dev/null; then
    snap list >> "$FILE"
else
    echo "Brak zainstalowanego Snapa." >> "$FILE"
fi
echo '```' >> "$FILE"

# 4. APPIMAGE
echo -e "\n## 🚀 Znalezione pliki AppImage" >> "$FILE"
echo '```text' >> "$FILE"
find "$HOME" -maxdepth 4 -name "*.AppImage" -type f -executable >> "$FILE"
echo '```' >> "$FILE"

