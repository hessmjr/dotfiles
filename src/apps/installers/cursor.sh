#!/bin/bash


set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

install_cursor() {
    local app_path="/Applications/Cursor.app"
    local details="Will download and install Cursor from the official source."

    if ! prompt_for_app_installation "Cursor" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading Cursor..."

    # Create temporary directory
    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    # Download Cursor for macOS
    local download_url="https://download.cursor.sh/mac/universal"
    local filename="Cursor.dmg"

    if download_file "$download_url" "$filename"; then
        # Mount the DMG
        local mount_point=$(mount_dmg "$filename" "Cursor")
        if [[ -n "$mount_point" ]]; then
            # Copy to Applications
            if install_app_to_applications "$mount_point/Cursor.app" "Cursor"; then
                print_success "Cursor installation completed"
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

main() {
    install_cursor
}

main "$@"
