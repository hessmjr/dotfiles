#!/bin/bash


set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_iterm2_installed() {
    if [[ -d "/Applications/iTerm.app" ]]; then
        return 0
    else
        return 1
    fi
}

check_iterm2_status() {
    if is_iterm2_installed; then
        print_success "iTerm2 is already installed"
        return 0
    else
        print_info "iTerm2 is not installed"
        return 1
    fi
}

install_iterm2() {
    local app_path="/Applications/iTerm.app"
    local details="Will download and install iTerm2 from the official source."

    if ! prompt_for_app_installation "iTerm2" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading iTerm2..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    local download_url="https://iterm2.com/downloads/stable/latest"
    local filename="iTerm2.zip"

    if download_file "$download_url" "$filename"; then
        if extract_zip "$filename"; then
            if install_app_to_applications "iTerm.app" "iTerm2"; then
                print_success "iTerm2 installation completed"
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
        check_iterm2_status
        exit $?
    fi

    install_iterm2
}

main "$@"
