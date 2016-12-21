#!/bin/bash


cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"


print_in_purple "\n   Keyboard\n\n"


# Enable access for all keyboard controls
execute "defaults write -g AppleKeyboardUIMode -int 3" \
    "Enable full keyboard access for all controls"


# Instead of holding the key to show additional symbols keys repeat
execute "defaults write -g ApplePressAndHoldEnabled -bool false" \
    "Disable press-and-hold in favor of key repeat"


# Sets the delay until repeat to 10
execute "defaults write -g 'InitialKeyRepeat_Level_Saved' -int 10" \
    "Set delay until repeat"


# Sets the repeat rate of a character to as fast as possible
execute "defaults write -g KeyRepeat -int 1" \
    "Set the key repeat rate to fast"


# Disables smart quotes or quotes that change while you type
execute "defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false" \
    "Disable smart quotes"


# Disables smart dashes or dashes that change while you type
execute "defaults write -g NSAutomaticDashSubstitutionEnabled -bool false" \
    "Disable smart dashes"
