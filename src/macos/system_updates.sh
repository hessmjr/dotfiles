#!/bin/bash

# macOS System Updates Setup Script
# Configures system update preferences and auto-update behavior

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Configure system update preferences
configure_system_updates() {
    print_section "System Updates Configuration"

    print_info "Configuring system update preferences..."

    # Disable automatic system updates
    print_info "Disabling automatic system updates..."
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool false
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool false
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool false
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool false

    # Disable automatic app updates
    print_info "Disabling automatic app updates..."
    sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool false
    sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool false

    # Disable automatic security updates
    print_info "Disabling automatic security updates..."
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticInstallation -bool false

    # Disable automatic XProtect updates
    print_info "Disabling automatic XProtect updates..."
    sudo defaults write /Library/Preferences/com.apple.XProtect.plist AutoUpdate -bool false

    # Disable automatic Gatekeeper updates
    print_info "Disabling automatic Gatekeeper updates..."
    sudo defaults write /Library/Preferences/com.apple.security.revocation.plist CRLUpdateInterval -int 0
    sudo defaults write /Library/Preferences/com.apple.security.revocation.plist OCSPUpdateInterval -int 0

    # Disable automatic Time Machine backups (optional - some users prefer this)
    print_info "Disabling automatic Time Machine backups..."
    sudo tmutil disable

    # Disable automatic Spotlight indexing updates
    print_info "Disabling automatic Spotlight indexing updates..."
    sudo mdutil -a -i off

    # Disable automatic font validation
    print_info "Disabling automatic font validation..."
    sudo defaults write /Library/Preferences/com.apple.FontValidator AutoValidateFonts -bool false

    # Disable automatic language model updates
    print_info "Disabling automatic language model updates..."
    sudo defaults write /Library/Preferences/com.apple.SpeechRecognitionCore AllowLanguageModelUpdates -bool false

    # Disable automatic Siri suggestions
    print_info "Disabling automatic Siri suggestions..."
    sudo defaults write /Library/Preferences/com.apple.suggestions.plist SuggestionsCanPopUp -bool false

    # Disable automatic Handoff and Continuity
    print_info "Disabling automatic Handoff and Continuity..."
    sudo defaults write /Library/Preferences/com.apple.Bluetooth.plist AutoSeekingKeyboard -bool false
    sudo defaults write /Library/Preferences/com.apple.Bluetooth.plist AutoSeekingPointingDevice -bool false

    print_success "System update preferences configured successfully"
    print_warning "Note: Some updates may still occur for critical security patches"
    print_info "To manually check for updates, use: Software Update in System Preferences"
}

# Main function
main() {
    configure_system_updates
}

# Run main function
main "$@"
