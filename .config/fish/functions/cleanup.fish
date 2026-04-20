function cleanup --description 'Kompleksowe czyszczenie systemu (Logs, DNF, Kernels, Flatpak, Vivaldi)'
    echo "󰃢 Czyszczenie logów journalctl (starsze niż 7 dni)..."
    sudo journalctl --vacuum-time=7d

    echo "󰏖 Czyszczenie cache DNF..."
    sudo dnf clean all

    echo "󰆴 Usuwanie osieroconych pakietów RPM..."
    sudo dnf autoremove -y

    echo "󰓷 Usuwanie starych wersji kernela (limit=2)..."
    sudo dnf remove (dnf repoquery --installonly --latest-limit=-2 -q) -y

    echo "󰚰 Usuwanie nieużywanych runtime'ów Flatpak..."
    flatpak remove --unused -y

    echo "󰅖 Usuwanie blokad profilu Vivaldi..."
    rm -f ~/.config/vivaldi/SingletonLock
    rm -f ~/.config/vivaldi/Default/SingletonLock

    echo "󰄬 System odświeżony"
end
