#!/bin/bash

# Keyboard Preferences Script
# Handles keyboard-related system preferences

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Keyboard preferences
setup_keyboard() {
    print_section "Keyboard"

    # Enable full keyboard access for all controls
    defaults write -g AppleKeyboardUIMode -int 3
    print_success "Enabled full keyboard access for all controls"

    # Disable press-and-hold in favor of key repeat
    defaults write -g ApplePressAndHoldEnabled -bool false
    print_success "Disabled press-and-hold in favor of key repeat"

    # Set delay until repeat to 10
    defaults write -g 'InitialKeyRepeat_Level_Saved' -int 10
    print_success "Set delay until repeat to 10"

    # Set the repeat rate to fast
    defaults write -g KeyRepeat -int 1
    print_success "Set key repeat rate to fast"

    # Disable smart quotes
    defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
    print_success "Disabled smart quotes"

    # Disable smart dashes
    defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
    print_success "Disabled smart dashes"
}

# Main function
main() {
    setup_keyboard
}

# Run main function
main "$@"
