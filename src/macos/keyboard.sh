#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

setup_keyboard() {
    print_section "Keyboard"

    defaults write -g AppleKeyboardUIMode -int 3
    print_success "Enabled full keyboard access for all controls"

    defaults write -g ApplePressAndHoldEnabled -bool false
    print_success "Disabled press-and-hold in favor of key repeat"

    defaults write -g 'InitialKeyRepeat_Level_Saved' -int 10
    print_success "Set delay until repeat to 10"

    defaults write -g KeyRepeat -int 1
    print_success "Set key repeat rate to fast"

    defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
    print_success "Disabled smart quotes"

    defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
    print_success "Disabled smart dashes"
}

main() {
    setup_keyboard
}

main "$@"
