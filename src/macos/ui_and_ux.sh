#!/bin/bash

# UI & UX Preferences Script
# Handles UI and UX related system preferences

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

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

    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true
    print_success "Enabled hidden files in Finder"

    # Show file extensions in Finder
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    print_success "Enabled file extensions in Finder"

    # Show path bar in Finder
    defaults write com.apple.finder ShowPathbar -bool true
    print_success "Enabled path bar in Finder"

    # Show status bar in Finder
    defaults write com.apple.finder ShowStatusBar -bool true
    print_success "Enabled status bar in Finder"

    # Restart Finder to apply file system changes
    killall "Finder" &> /dev/null
    print_success "Restarted Finder to apply file system changes"

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
