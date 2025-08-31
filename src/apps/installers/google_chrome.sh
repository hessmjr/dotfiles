#!/bin/bash


set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_chrome_installed() {
    if [[ -d "/Applications/Google Chrome.app" ]]; then
        return 0
    else
        return 1
    fi
}

install_chrome() {
    print_section "Google Chrome"

    if is_chrome_installed; then
        print_success "Google Chrome is already installed, skipping..."
        return 0
    fi

    print_info "Downloading Google Chrome..."

    # Create temporary directory
    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    # Download Google Chrome for macOS
    local download_url="https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"
    local filename="GoogleChrome.dmg"

    if download_file "$download_url" "$filename"; then
        # Mount the DMG file
        local mount_point=$(mount_dmg "$filename" "Google Chrome")
        if [[ -n "$mount_point" ]]; then
            # Copy to Applications
            if install_app_to_applications "$mount_point/Google Chrome.app" "Google Chrome"; then
                print_success "Google Chrome installed successfully"
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

main() {
    install_chrome
}

main "$@"
