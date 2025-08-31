#!/bin/bash

# macOS Main Setup Script
# Orchestrates all macOS preference setup scripts

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Close System Preferences to avoid conflicts
close_system_preferences() {
    print_info "Closing System Preferences to avoid conflicts..."
    osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
}

# Run all macOS preference scripts
run_macos_setup() {
    print_info "Running macOS preference setup scripts..."

    # Get script directory
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Close System Preferences first
    close_system_preferences

    # Run individual preference scripts
    print_info "Setting up Dashboard preferences..."
    "$script_dir/dashboard.sh"

    print_info "Setting up Keyboard preferences..."
    "$script_dir/keyboard.sh"

    print_info "Setting up Trackpad preferences..."
    "$script_dir/trackpad.sh"

    print_info "Setting up UI & UX preferences..."
    "$script_dir/ui_and_ux.sh"

    print_info "Setting up System Updates preferences..."
    "$script_dir/system_updates.sh"

    print_info "Setting up Developer Tools..."
    "$script_dir/developer_tools.sh"

    print_info "Setting up Homebrew Development Environment..."
    "$script_dir/homebrew.sh"

    print_success "All macOS preference scripts completed successfully!"
}

# Main function
main() {
    print_info "Starting macOS system preferences setup..."

    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is intended for macOS only"
        exit 1
    fi

    # Run the setup
    run_macos_setup

    print_success "macOS system preferences setup complete!"
    print_info "Some changes may require a restart to take full effect"
}

# Run main function
main "$@"
