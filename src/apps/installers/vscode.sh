#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_vscode_installed() {
    if [[ -d "/Applications/Visual Studio Code.app" ]]; then
        return 0
    else
        return 1
    fi
}

check_vscode_status() {
    if is_vscode_installed; then
        print_success "Visual Studio Code is already installed"
        return 0
    else
        print_info "Visual Studio Code is not installed"
        return 1
    fi
}

install_vscode() {
    local app_path="/Applications/Visual Studio Code.app"
    local details="Will download and install Visual Studio Code from Microsoft's official source."

    if ! prompt_for_app_installation "Visual Studio Code" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading Visual Studio Code..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    local download_url="https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal"
    local filename="VSCode-darwin-universal.zip"

    if download_file "$download_url" "$filename"; then
        if extract_zip "$filename"; then
            if install_app_to_applications "Visual Studio Code.app" "Visual Studio Code"; then
                print_success "Visual Studio Code installation completed"
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
        check_vscode_status
        exit $?
    fi

    install_vscode
}

main "$@"
