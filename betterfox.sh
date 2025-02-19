#!/bin/sh

echo "This will delete ALL your Firefox profile settings including Bookmarks, History, and Extensions. Then a new profile will be created with Betterfox settings and uBlock Origin and Bitwarden Extensions.";
echo "During the process FIrefox will open and close itself twice. There is no harm in closing it yourself, but also no need."
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
 # Add Betterfox configuration to Firefox and install extensions
  rm -rf /home/user/.var/app/org.mozilla.firefox
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
  curl -L -o $PROFILE_DIR/extensions/uBlock0@raymondhill.net.xpi https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi
  curl -L -o $PROFILE_DIR/extensions/{446900e4-71c2-419f-a6a7-df9c091e268b}.xpi https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi
  flatpak run --branch=stable --arch=x86_64 --command=firefox --file-forwarding org.mozilla.firefox &
  while ! pgrep -f "org.mozilla.firefox" > /dev/null; do
    sleep 1
  done
  sleep 5
  flatpak kill org.mozilla.firefox
  rm $PROFILE_DIR/user.js
else
  echo "Betterfox install Cancelled!"
fi
