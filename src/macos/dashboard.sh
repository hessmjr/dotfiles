#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

setup_dashboard() {
    print_section "Dashboard"

    defaults write com.apple.dashboard mcx-disabled -bool true
    print_success "Disabled Dashboard"

    killall "Dock" &> /dev/null
    print_success "Restarted Dock to apply Dashboard changes"
}

main() {
    setup_dashboard
}

main "$@"
