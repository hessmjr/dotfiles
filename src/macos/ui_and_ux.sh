#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

setup_ui_ux() {
    print_section "UI & UX"

    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    print_success "Disabled .DS_Store creation on network/USB volumes"

    defaults write com.apple.CrashReporter UseUNC 1
    print_success "Set crash reports to appear as notifications"

    defaults write com.apple.screencapture disable-shadow -bool true
    print_success "Disabled shadow in screenshots"

    defaults write com.apple.finder AppleShowAllFiles -bool true
    print_success "Enabled hidden files in Finder"

    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    print_success "Enabled file extensions in Finder"

    defaults write com.apple.finder ShowPathbar -bool true
    print_success "Enabled path bar in Finder"

    defaults write com.apple.finder ShowStatusBar -bool true
    print_success "Enabled status bar in Finder"

    killall "Finder" &> /dev/null
    print_success "Restarted Finder to apply file system changes"

    killall "SystemUIServer" &> /dev/null
    print_success "Restarted SystemUIServer to apply UI changes"
}

main() {
    setup_ui_ux
}

main "$@"
