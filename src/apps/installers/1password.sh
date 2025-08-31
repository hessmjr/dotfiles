#!/bin/bash

# 1Password Setup Script
# Downloads and installs 1Password directly from source

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_section() {
    echo -e "${PURPLE}[SECTION]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

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
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Download 1Password for macOS
    local download_url="https://downloads.1password.com/mac/1Password-8.10.0.pkg"
    local filename="1Password.pkg"

    if curl -L -o "$filename" "$download_url"; then
        print_success "Download completed"

        # Install the PKG file
        if sudo installer -pkg "$filename" -target /; then
            print_success "1Password installed successfully"
        else
            print_warning "Failed to install 1Password package"
            return 1
        fi
    else
        print_warning "Failed to download 1Password"
        return 1
    fi

    # Clean up
    cd /
    rm -rf "$temp_dir"
}

# Main function
main() {
    install_1password
}

# Run main function
main "$@"
