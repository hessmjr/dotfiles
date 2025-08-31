#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

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
    install_vscode
}

main "$@"
