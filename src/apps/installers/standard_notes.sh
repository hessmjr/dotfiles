#!/bin/bash


set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_standard_notes_installed() {
    if [[ -d "/Applications/Standard Notes.app" ]]; then
        return 0
    else
        return 1
    fi
}

check_standard_notes_status() {
    if is_standard_notes_installed; then
        print_success "Standard Notes is already installed"
        return 0
    else
        print_info "Standard Notes is not installed"
        return 1
    fi
}

install_standard_notes() {
    local app_path="/Applications/Standard Notes.app"
    local details="Will download and install Standard Notes from the official source."

    if ! prompt_for_app_installation "Standard Notes" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading Standard Notes..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    local download_url="https://github.com/standardnotes/app/releases/latest/download/Standard-Notes-3.0.0.dmg"
    local filename="StandardNotes.dmg"

    if download_file "$download_url" "$filename"; then
        if mount_dmg "$filename"; then
            if install_app_to_applications "Standard Notes.app" "Standard Notes"; then
                print_success "Standard Notes installation completed"
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
        check_standard_notes_status
        exit $?
    fi

    install_standard_notes
}

main "$@"
