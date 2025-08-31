#!/bin/bash

# Git Tower Setup Script
# Downloads and installs Git Tower directly from source

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

# Check if Git Tower is already installed
is_tower_installed() {
    if [[ -d "/Applications/Tower.app" ]]; then
        return 0  # App is installed
    else
        return 1  # App is not installed
    fi
}

# Download and install Git Tower
install_tower() {
    print_section "Git Tower"

    if is_tower_installed; then
        print_success "Git Tower is already installed, skipping..."
        return 0
    fi

    print_info "Downloading Git Tower..."

    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Download Git Tower for macOS
    local download_url="https://www.git-tower.com/apps/tower3-mac/stable"
    local filename="Tower.dmg"

    if curl -L -o "$filename" "$download_url"; then
        print_success "Download completed"

        # Mount the DMG
        if hdiutil attach "$filename" -quiet; then
            print_success "DMG mounted successfully"

            # Find the mounted volume
            local mount_point=$(hdiutil info | grep "/Volumes/Tower" | head -1 | awk '{print $3}')

            if [[ -n "$mount_point" ]]; then
                # Copy to Applications
                if cp -R "$mount_point/Tower.app" "/Applications/"; then
                    print_success "Git Tower installed successfully"
                else
                    print_warning "Failed to copy to Applications directory"
                    hdiutil detach "$mount_point" -quiet
                    return 1
                fi

                # Unmount the DMG
                hdiutil detach "$mount_point" -quiet
            else
                print_warning "Could not find mounted Tower volume"
                return 1
            fi
        else
            print_warning "Failed to mount DMG file"
            return 1
        fi
    else
        print_warning "Failed to download Git Tower"
        return 1
    fi

    # Clean up
    cd /
    rm -rf "$temp_dir"
}

# Main function
main() {
    install_tower
}

# Run main function
main "$@"
