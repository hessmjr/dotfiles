#!/bin/bash

# Trackpad Preferences Script
# Handles trackpad-related system preferences

set -e

# Colors for output
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_section() {
    echo -e "${PURPLE}[SECTION]${NC} $1"
}

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
