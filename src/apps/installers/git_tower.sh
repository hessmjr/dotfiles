#!/bin/bash

# Git Tower Setup Script
# Downloads and installs Git Tower

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Check if Git Tower is already installed
is_git_tower_installed() {
    if [[ -d "/Applications/Tower.app" ]]; then
        return 0  # App is installed
    else
        return 1  # App is not installed
    fi
}

# Download and install Git Tower
install_git_tower() {
    print_section "Git Tower"

    if is_git_tower_installed; then
        print_success "Git Tower is already installed, skipping..."
        return 0
    fi

    print_info "Downloading Git Tower..."

    # Create temporary directory
    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    # Download Git Tower for macOS
    local download_url="https://www.git-tower.com/download"
    local filename="Tower.dmg"

    if download_file "$download_url" "$filename"; then
        # Mount the DMG file
        local mount_point=$(mount_dmg "$filename" "Tower")
        if [[ -n "$mount_point" ]]; then
            # Copy to Applications
            if install_app_to_applications "$mount_point/Tower.app" "Git Tower"; then
                print_success "Git Tower installed successfully"
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
    install_git_tower
}

# Run main function
main "$@"
