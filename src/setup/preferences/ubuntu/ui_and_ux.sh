#!/bin/bash


cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"


print_in_purple "\n   UI & UX\n\n"


# Set background image to stretched
execute "gsettings set org.gnome.desktop.background picture-options 'stretched'" \
    "Set desktop background image options"


# Set favorites on the launcher menu
execute "gsettings set com.canonical.Unity.Launcher favorites \"[
            'ubiquity-gtkui.desktop',
            'nautilus-home.desktop'
         ]\"" \
    "Set Launcher favorites"
