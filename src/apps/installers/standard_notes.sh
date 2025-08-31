#!/bin/bash


set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_standard_notes_installed() {
    if [[ -d "/Applications/Standard Notes.app" ]]; then
        return 0
    else
        return 1
    fi
}

install_standard_notes() {
    print_section "Standard Notes"

    if is_standard_notes_installed; then
        print_success "Standard Notes is already installed, skipping..."
        return 0
    fi

    print_info "Downloading Standard Notes..."

    # Create temporary directory
    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    # Download Standard Notes for macOS
    local download_url="https://github.com/standardnotes/app/releases/latest/download/Standard-Notes-3.0.0.dmg"
    local filename="StandardNotes.dmg"

    if download_file "$download_url" "$filename"; then
        # Mount the DMG file
        local mount_point=$(mount_dmg "$filename" "Standard Notes")
        if [[ -n "$mount_point" ]]; then
            # Copy to Applications
            if install_app_to_applications "$mount_point/Standard Notes.app" "Standard Notes"; then
                print_success "Standard Notes installed successfully"
            else
                unmount_dmg "$mount_point"
                cleanup_temp_dir "$temp_dir"
                return 1
            fi
            # Unmount DMG
            unmount_dmg "$mount_point"
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
    install_standard_notes
}

main "$@"
