#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_firefox_installed() {
    if [[ -d "/Applications/Firefox.app" ]]; then
        return 0
    else
        return 1
    fi
}

install_firefox() {
    print_section "Firefox"

    if is_firefox_installed; then
        print_success "Firefox is already installed, skipping..."
        return 0
    fi

    print_info "Downloading Firefox..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    local download_url="https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US"
    local filename="Firefox.dmg"

    if download_file "$download_url" "$filename"; then
        local mount_point=$(mount_dmg "$filename" "Firefox")
        if [[ -n "$mount_point" ]]; then
            if install_app_to_applications "$mount_point/Firefox.app" "Firefox"; then
                print_success "Firefox installed successfully"
            else
                unmount_dmg "$mount_point"
                cleanup_temp_dir "$temp_dir"
                return 1
            fi
            unmount_dmg "$mount_point"
        else
            cleanup_temp_dir "$temp_dir"
            return 1
        fi
    else
        cleanup_temp_dir "$temp_dir"
        return 1
    fi

    cleanup_temp_dir "$temp_dir"
}

main() {
    install_firefox
}

main "$@"
