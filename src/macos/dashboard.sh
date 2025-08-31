#!/bin/bash

# Dashboard Preferences Script
# Handles dashboard-related system preferences

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
