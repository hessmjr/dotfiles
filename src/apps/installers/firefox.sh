#!/bin/bash

# Firefox Setup Script
# Downloads and installs Firefox browser

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Check if Firefox is already installed
is_firefox_installed() {
    if [[ -d "/Applications/Firefox.app" ]]; then
        return 0  # App is installed
    else
        return 1  # App is not installed
    fi
}

# Download and install Firefox
install_firefox() {
    print_section "Firefox"

    if is_firefox_installed; then
        print_success "Firefox is already installed, skipping..."
        return 0
    fi

    print_info "Downloading Firefox..."

    # Create temporary directory
    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    # Download Firefox for macOS
    local download_url="https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US"
    local filename="Firefox.dmg"

    if download_file "$download_url" "$filename"; then
        # Mount the DMG file
        local mount_point=$(mount_dmg "$filename" "Firefox")
        if [[ -n "$mount_point" ]]; then
            # Copy to Applications
            if install_app_to_applications "$mount_point/Firefox.app" "Firefox"; then
                print_success "Firefox installed successfully"
            else
                unmount_dmg "$mount_point"
                cleanup_temp_dir "$temp_dir"
                return 1
            fi
            # Unmount DMG
            unmount_dmg "$mount_point"
        else
            cleanup_temp_dir "$temp_dir"
            return 1
        fi
    else
        cleanup_temp_dir "$temp_dir"
        return 1
    fi

    # Clean up
    cleanup_temp_dir "$temp_dir"
}

# Main function
main() {
    install_firefox
}

# Run main function
main "$@"
