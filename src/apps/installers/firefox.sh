#!/bin/bash

# Firefox Setup Script
# Downloads and installs Firefox directly from Mozilla

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
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Download Firefox for macOS
    local download_url="https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US"
    local filename="Firefox.dmg"

    if curl -L -o "$filename" "$download_url"; then
        print_success "Download completed"

        # Mount the DMG
        if hdiutil attach "$filename" -quiet; then
            print_success "DMG mounted successfully"

            # Find the mounted volume
            local mount_point=$(hdiutil info | grep "/Volumes/Firefox" | head -1 | awk '{print $3}')

            if [[ -n "$mount_point" ]]; then
                # Copy to Applications
                if cp -R "$mount_point/Firefox.app" "/Applications/"; then
                    print_success "Firefox installed successfully"
                else
                    print_warning "Failed to copy to Applications directory"
                    hdiutil detach "$mount_point" -quiet
                    return 1
                fi

                # Unmount the DMG
                hdiutil detach "$mount_point" -quiet
            else
                print_warning "Could not find mounted Firefox volume"
                return 1
            fi
        else
            print_warning "Failed to mount DMG file"
            return 1
        fi
    else
        print_warning "Failed to download Firefox"
        return 1
    fi

    # Clean up
    cd /
    rm -rf "$temp_dir"
}

# Main function
main() {
    install_firefox
}

# Run main function
main "$@"
