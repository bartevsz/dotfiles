function update --description 'System Update (DNF, Flatpak, Spicetify)'
    echo "󰚰 Aktualizacja Flatpak..."
    sudo flatpak update -y

    echo "󰏖 Aktualizacja DNF..."
    sudo dnf update -y

    echo "󰌆 Naprawa uprawnień Spotify..."
	sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/current/active/files/extra/share/spotify/ -R/Apps -R

    echo "󰎄 Spicetify update..."
    spicetify update

    echo "󰄬 Gotowe."
    cleanup
end
