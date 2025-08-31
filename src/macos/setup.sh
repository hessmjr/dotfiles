#!/bin/bash

# macOS Setup Script
# This script handles all macOS-specific system preferences and configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo -e "${PURPLE}[SECTION]${NC} $1"
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is intended for macOS only"
        exit 1
    fi

    # Check minimum macOS version
    local os_version=$(sw_vers -productVersion)
    local min_version="10.10"

    if [[ "$(echo "$os_version $min_version" | tr " " "\n" | sort -V | head -n1)" != "$min_version" ]]; then
        print_error "This script requires macOS $min_version or later (current: $os_version)"
        exit 1
    fi

    print_success "Detected macOS $os_version"
}

# Close System Preferences to avoid conflicts
close_system_preferences() {
    print_info "Closing System Preferences to avoid conflicts..."
    osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
}

# Dashboard preferences
setup_dashboard() {
    print_section "Dashboard"

    # Disable Dashboard
    defaults write com.apple.dashboard mcx-disabled -bool true
    print_success "Disabled Dashboard"

    # Restart Dock to apply changes
    killall "Dock" &> /dev/null
    print_success "Restarted Dock to apply Dashboard changes"
}

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

# Check if macOS preferences need updating
check_macos_status() {
    print_info "Checking current macOS preferences status..."

    # For now, we'll assume updates are always needed since these are system defaults
    # In the future, we could add more sophisticated checking
    return 1
}

# Main macOS setup function
main() {
    local check_only=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check-only)
                check_only=true
                shift
                ;;
            *)
                print_warning "Unknown option: $1"
                print_info "Usage: $0 [--check-only]"
                exit 1
                ;;
        esac
    done

    print_info "Starting macOS system preferences setup..."

    # Check macOS compatibility
    check_macos

    # Check if updates are needed
    if check_macos_status; then
        if [[ "$check_only" == true ]]; then
            exit 0
        else
            print_info "macOS preferences check complete - no action needed."
            exit 0
        fi
    fi

    # If check-only mode, exit with error code
    if [[ "$check_only" == true ]]; then
        exit 1
    fi

    # Close System Preferences
    close_system_preferences

    # Setup various macOS preferences
    setup_dashboard
    setup_keyboard
    setup_trackpad
    setup_ui_ux

    print_success "macOS system preferences setup complete!"
    print_info "Some changes may require a restart to take full effect"
}

# Run main function
main "$@"
