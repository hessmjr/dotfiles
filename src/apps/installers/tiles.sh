#!/bin/bash

# Tiles Setup Script
# Downloads and installs Tiles directly from source

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

# Check if Tiles is already installed
is_tiles_installed() {
    if [[ -d "/Applications/Tiles.app" ]]; then
        return 0  # App is installed
    else
        return 1  # App is not installed
    fi
}

# Download and install Tiles
install_tiles() {
    print_section "Tiles"

    if is_tiles_installed; then
        print_success "Tiles is already installed, skipping..."
        return 0
    fi

    print_info "Downloading Tiles..."

    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Download Tiles for macOS
    local download_url="https://freemacsoft.net/downloads/Tiles_1.2.0.zip"
    local filename="Tiles.zip"

    if curl -L -o "$filename" "$download_url"; then
        print_success "Download completed"

        # Extract the zip file
        if unzip -q "$filename"; then
            print_success "Extraction completed"

            # Move to Applications
            if mv "Tiles.app" "/Applications/"; then
                print_success "Tiles installed successfully"
            else
                print_warning "Failed to move to Applications directory"
                return 1
            fi
        else
            print_warning "Failed to extract zip file"
            return 1
        fi
    else
        print_warning "Failed to download Tiles"
        return 1
    fi

    # Clean up
    cd /
    rm -rf "$temp_dir"
}

# Main function
main() {
    install_tiles
}

# Run main function
main "$@"
