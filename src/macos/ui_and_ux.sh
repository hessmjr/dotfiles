#!/bin/bash

# UI & UX Preferences Script
# Handles UI and UX related system preferences

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

# UI and UX preferences
setup_ui_ux() {
    print_section "UI & UX"

    # Avoid creating .DS_Store files on network/USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    print_success "Disabled .DS_Store creation on network/USB volumes"

    # Make crash reports appear as notifications
    defaults write com.apple.CrashReporter UseUNC 1
    print_success "Set crash reports to appear as notifications"

    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true
    print_success "Disabled shadow in screenshots"

    # Restart SystemUIServer to apply changes
    killall "SystemUIServer" &> /dev/null
    print_success "Restarted SystemUIServer to apply UI changes"
}

# Main function
main() {
    setup_ui_ux
}

# Run main function
main "$@"
