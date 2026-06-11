function update --description 'System Update (Alpine + Distrobox + Spicetify)'
    echo "󰚰 Aktualizacja Alpine..."
    doas apk upgrade

    echo "󰏖 Aktualizacja kontenerów Distrobox..."
    distrobox upgrade --all

    echo "󰎄 Spicetify update..."
    distrobox enter spotify -- spicetify update

    echo "󰄬 Gotowe."
end
