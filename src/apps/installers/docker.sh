#!/bin/bash

# Docker Setup Script
# Downloads and installs Docker Desktop directly from source

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Download and install Docker
install_docker() {
    local app_path="/Applications/Docker.app"
    local details="Will download and install Docker Desktop from the official source."

    if ! prompt_for_app_installation "Docker Desktop" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading Docker Desktop..."

    # Create temporary directory
    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    # Download Docker Desktop for macOS
    local download_url="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
    local filename="Docker.dmg"

    if download_file "$download_url" "$filename"; then
        # Mount the DMG
        local mount_point=$(mount_dmg "$filename" "Docker")
        if [[ -n "$mount_point" ]]; then
            # Copy to Applications
            if install_app_to_applications "$mount_point/Docker.app" "Docker"; then
                print_success "Docker installation completed"
            else
                unmount_dmg "$mount_point"
                cleanup_temp_dir "$temp_dir"
                return 1
            fi

            # Unmount the DMG
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
    install_docker
}

# Run main function
main "$@"
