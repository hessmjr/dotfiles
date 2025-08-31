#!/bin/bash

# Dashboard Preferences Script
# Handles dashboard-related system preferences

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

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

# Main function
main() {
    setup_dashboard
}

# Run main function
main "$@"
