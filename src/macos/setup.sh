#!/bin/bash

# macOS Setup Script
# Modern orchestrator for all macOS preference setup scripts

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

    # Run the modern modular setup
    run_macos_setup

    print_success "macOS system preferences setup complete!"
    print_info "Some changes may require a restart to take full effect"
}

# Run main function
main "$@"
