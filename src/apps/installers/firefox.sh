#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_firefox_installed() {
    if [[ -d "/Applications/Firefox.app" ]]; then
        return 0
    else
        return 1
    fi
}

check_firefox_status() {
    if is_firefox_installed; then
        print_success "Firefox is already installed"
        return 0
    else
        print_info "Firefox is not installed"
        return 1
    fi
}

install_firefox() {
    local app_path="/Applications/Firefox.app"
    local details="Will download and install Firefox from Mozilla's official source."

    if ! prompt_for_app_installation "Firefox" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading Firefox..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    local download_url="https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US"
    local filename="Firefox.dmg"

    if download_file "$download_url" "$filename"; then
        if mount_dmg "$filename"; then
            if install_app_to_applications "Firefox.app" "Firefox"; then
                print_success "Firefox installation completed"
            else
                unmount_dmg
                cleanup_temp_dir "$temp_dir"
                return 1
            fi
            unmount_dmg
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
    local check_only=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check-only)
                check_only=true
                shift
                ;;
            *)
                print_warning "Unknown option: $1"
                print_info "Usage: $0 [--check-only]"
                exit 1
                ;;
        esac
    done

    if [[ "$check_only" == true ]]; then
        check_firefox_status
        exit $?
    fi

    install_firefox
}

main "$@"
