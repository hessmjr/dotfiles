#!/bin/bash


set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_cursor_installed() {
    if [[ -d "/Applications/Cursor.app" ]]; then
        return 0
    else
        return 1
    fi
}

check_cursor_status() {
    if is_cursor_installed; then
        print_success "Cursor is already installed"
        return 0
    else
        print_info "Cursor is not installed"
        return 1
    fi
}

install_cursor() {
    local app_path="/Applications/Cursor.app"
    local details="Will download and install Cursor from the official source."

    if ! prompt_for_app_installation "Cursor" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading Cursor..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    local download_url="https://download.todesktop.com/230313mzl4w92u92/linux"
    local filename="Cursor.dmg"

    if download_file "$download_url" "$filename"; then
        if mount_dmg "$filename"; then
            if install_app_to_applications "Cursor.app" "Cursor"; then
                print_success "Cursor installation completed"
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
        check_cursor_status
        exit $?
    fi

    install_cursor
}

main "$@"
