#!/bin/bash

# Tiles Setup Script
# Downloads and installs Tiles window manager

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

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
    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    # Download Tiles for macOS
    local download_url="https://download.tilesapp.com/latest/Tiles.zip"
    local filename="Tiles.zip"

    if download_file "$download_url" "$filename"; then
        # Extract the zip file
        if extract_zip "$filename"; then
            # Move to Applications
            if install_app_to_applications "Tiles.app" "Tiles"; then
                print_success "Tiles installed successfully"
            else
                cleanup_temp_dir "$temp_dir"
                return 1
            fi
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
    install_tiles
}

# Run main function
main "$@"
