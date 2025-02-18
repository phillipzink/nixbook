echo "This will delete ALL local files and reset this Nixbook!";
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
echo "Powerwashing NixBook..."
  # Get latest nixbook code
  sudo git -C /etc/nixbook reset --hard
  sudo git -C /etc/nixbook clean -fd
  sudo git -C /etc/nixbook pull --rebase
  

  # Erase data and set up home directory again
  cp ~/.Xauthority /tmp/
  rm -rf ~/
  mv /tmp/.Xauthority ~/
  mkdir ~/Desktop
  mkdir ~/Documents
  mkdir ~/Downloads
  mkdir ~/Pictures
  mkdir ~/.local
  mkdir ~/.local/share
  cp -R /etc/nixbook/config/config ~/.config
  cp /etc/nixbook/config/desktop/* ~/Desktop/
  cp -R /etc/nixbook/config/applications ~/.local/share/applications

  sudo rm -r /var/lib/flatpak

  # Clear space and rebuild
  sudo nix-collect-garbage -d
  sudo nixos-rebuild switch --upgrade
  sudo nixos-rebuild list-generations

  # Add flathub and some apps
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install flathub com.google.Chrome -y
  flatpak install flathub org.mozilla.firefox -y
  flatpak install flathub us.zoom.Zoom -y
  flatpak install flathub org.libreoffice.LibreOffice -y

  # Add Betterfox configuration to Firefox and install extensions
  flatpak run --branch=stable --arch=x86_64 --command=firefox --file-forwarding org.mozilla.firefox &
  while ! pgrep -f "org.mozilla.firefox" > /dev/null; do
    sleep 1
  done
  sleep 5
  flatpak kill org.mozilla.firefox
  FIREFOX_DIR="$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
  PROFILE_DIR=$FIREFOX_DIR/$(grep "Default=.*\.default*" "$FIREFOX_DIR/profiles.ini" | cut -d "=" -f2)
  curl -L -o $PROFILE_DIR/user.js https://github.com/yokoffing/Betterfox/raw/refs/heads/main/user.js
  sed -i 's/\/\/ Enter your personal overrides below this line:/\/\/ Enter your personal overrides below this line:\n\/\/PREF: revert back to Standard ETP\nuser_pref(\"browser.contentblocking.category\", \"standard\");\nuser_pref(\"extensions.enabledScopes\", 15);\nuser_pref(\"extensions.autoDisableScopes\", 0);/g' "$PROFILE_DIR/user.js"
  #cp /etc/nixbook/config/firefox_extenstions/* $PROFILE_DIR/
  curl -L -o $PROFILE_DIR/extensions/uBlock0@raymondhill.net.xpi https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi
  curl -L -o $PROFILE_DIR/extensions/{446900e4-71c2-419f-a6a7-df9c091e268b}.xpi https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi
  flatpak run --branch=stable --arch=x86_64 --command=firefox --file-forwarding org.mozilla.firefox &
  while ! pgrep -f "org.mozilla.firefox" > /dev/null; do
    sleep 1
  done
  sleep 5
  flatpak kill org.mozilla.firefox
  rm $PROFILE_DIR/user.js
  
  reboot
else
  echo "Powerwashing Cancelled!"
fi
