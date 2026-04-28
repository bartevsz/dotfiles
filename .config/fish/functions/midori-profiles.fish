function midori-profiles --description 'Automatycznie zabezpiecza wszystkie profile przeglądarki Midori utwardzonym plikiem user.js'
    for profile in ~/.config/mozilla/midori/*.*
        if test -d $profile
            ln -sf ~/dotfiles/midori/user.js $profile/user.js
            set_color green
            echo "Zabezpieczono profil: "(basename $profile)
            set_color normal
        end
    end
end
