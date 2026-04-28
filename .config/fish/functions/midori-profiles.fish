for profile in ~/.config/mozilla/midori/*.*
    if test -d $profile
        ln -sf ~/dotfiles/midori/user.js $profile/user.js
        echo "Zabezpieczono profil: "(basename $profile)
    end
end
