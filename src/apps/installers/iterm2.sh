#!/bin/bash

# iTerm2 Setup Script
# Downloads and installs iTerm2 directly from source

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Download and install iTerm2
install_iterm2() {
    local app_path="/Applications/iTerm.app"
    local details="Will download and install iTerm2 from the official source."

    if ! prompt_for_app_installation "iTerm2" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading iTerm2..."

    # Create temporary directory
    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    # Download iTerm2 for macOS
    local download_url="https://iterm2.com/downloads/stable/latest"
    local filename="iTerm2-3.5.0.zip"

    if download_file "$download_url" "$filename"; then
        # Extract the zip file
        if extract_zip "$filename"; then
            # Move to Applications
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

    # Clean up
    cleanup_temp_dir "$temp_dir"
}

# Main function
main() {
    install_iterm2
}

# Run main function
main "$@"
