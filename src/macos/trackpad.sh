#!/bin/bash

# Trackpad Preferences Script
# Handles trackpad-related system preferences

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Trackpad preferences
setup_trackpad() {
    print_section "Trackpad"

    # Enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
    defaults write -g com.apple.mouse.tapBehavior -int 1
    defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
    print_success "Enabled tap to click"

    # Enable two-finger right-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -int 1
    defaults -currentHost write -g com.apple.trackpad.enableSecondaryClick -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 0
    defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 0
    defaults -currentHost write -g com.apple.trackpad.trackpadCornerClickBehavior -int 0
    print_success "Enabled two-finger right-click"
}

# Main function
main() {
    setup_trackpad
}

# Run main function
main "$@"
