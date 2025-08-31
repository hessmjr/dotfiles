#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is intended for macOS only"
        exit 1
    fi

    local os_version=$(sw_vers -productVersion)
    local min_version="10.10"

    if [[ "$(echo "$os_version $min_version" | tr " " "\n" | sort -V | head -n1)" != "$min_version" ]]; then
        print_error "This script requires macOS $min_version or later (current: $os_version)"
        exit 1
    fi

    print_success "Detected macOS $os_version"
}

close_system_preferences() {
    print_info "Closing System Preferences to avoid conflicts..."
    osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
}

run_macos_setup() {
    print_info "Running macOS preference setup scripts..."

    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    close_system_preferences

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

check_macos_status() {
    print_info "Checking current macOS preferences status..."
    return 1
}

main() {
    local check_only=false

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

    check_macos

    if check_macos_status; then
        if [[ "$check_only" == true ]]; then
            exit 0
        else
            print_info "macOS preferences check complete - no action needed."
            exit 0
        fi
    fi

    if [[ "$check_only" == true ]]; then
        exit 1
    fi

    run_macos_setup

    print_success "macOS system preferences setup complete!"
    print_info "Some changes may require a restart to take full effect"
}

main "$@"
