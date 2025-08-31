#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_1password_installed() {
    if [[ -d "/Applications/1Password.app" ]]; then
        return 0
    else
        return 1
    fi
}

install_1password() {
    print_section "1Password"

    if is_1password_installed; then
        print_success "1Password is already installed, skipping..."
        return 0
    fi

    print_info "Downloading 1Password..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    local download_url="https://downloads.1password.com/mac/1Password-8.10.0.pkg"
    local filename="1Password.pkg"

    if download_file "$download_url" "$filename"; then
        if sudo installer -pkg "$filename" -target /; then
            print_success "1Password installed successfully"
        else
            print_warning "Failed to install 1Password package"
            return 1
        fi
    else
        cleanup_temp_dir "$temp_dir"
        return 1
    fi

    cleanup_temp_dir "$temp_dir"
}

main() {
    install_1password
}

main "$@"
