#!/bin/bash


set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_google_chrome_installed() {
    if [[ -d "/Applications/Google Chrome.app" ]]; then
        return 0
    else
        return 1
    fi
}

check_google_chrome_status() {
    if is_google_chrome_installed; then
        print_success "Google Chrome is already installed"
        return 0
    else
        print_info "Google Chrome is not installed"
        return 1
    fi
}

install_google_chrome() {
    local app_path="/Applications/Google Chrome.app"
    local details="Will download and install Google Chrome from Google's official source."

    if ! prompt_for_app_installation "Google Chrome" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading Google Chrome..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    local download_url="https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"
    local filename="GoogleChrome.dmg"

    if download_file "$download_url" "$filename"; then
        if mount_dmg "$filename"; then
            if install_app_to_applications "Google Chrome.app" "Google Chrome"; then
                print_success "Google Chrome installation completed"
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
        check_google_chrome_status
        exit $?
    fi

    install_google_chrome
}

main "$@"
