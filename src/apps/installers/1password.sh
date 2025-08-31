#!/bin/bash

# 1Password Setup Script
# Downloads and installs 1Password directly from source

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Check if 1Password is already installed
is_1password_installed() {
    if [[ -d "/Applications/1Password.app" ]]; then
        return 0  # App is installed
    else
        return 1  # App is not installed
    fi
}

# Download and install 1Password
install_1password() {
    print_section "1Password"

    if is_1password_installed; then
        print_success "1Password is already installed, skipping..."
        return 0
    fi

    print_info "Downloading 1Password..."

    # Create temporary directory
    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    # Download 1Password for macOS
    local download_url="https://downloads.1password.com/mac/1Password-8.10.0.pkg"
    local filename="1Password.pkg"

    if download_file "$download_url" "$filename"; then
        # Install the PKG file
        if sudo installer -pkg "$filename" -target /; then
            print_success "1Password installed successfully"
        else
            print_warning "Failed to install 1Password package"
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
    install_1password
}

# Run main function
main "$@"
