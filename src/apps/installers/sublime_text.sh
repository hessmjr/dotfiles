#!/bin/bash


set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_sublime_installed() {
    if [[ -d "/Applications/Sublime Text.app" ]]; then
        return 0
    else
        return 1
    fi
}

install_sublime() {
    print_section "Sublime Text"

    if is_sublime_installed; then
        print_success "Sublime Text is already installed, skipping..."
        return 0
    fi

    print_info "Downloading Sublime Text..."

    # Create temporary directory
    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    # Download Sublime Text for macOS
    local download_url="https://download.sublimetext.com/sublime_text_build_4152_mac.zip"
    local filename="SublimeText.zip"

    if download_file "$download_url" "$filename"; then
        # Extract the zip file
        if extract_zip "$filename"; then
            # Move to Applications
            if install_app_to_applications "Sublime Text.app" "Sublime Text"; then
                print_success "Sublime Text installed successfully"
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

    # Clean up
    cleanup_temp_dir "$temp_dir"
}

main() {
    install_sublime
}

main "$@"
