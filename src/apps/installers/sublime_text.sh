#!/bin/bash


set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_sublime_text_installed() {
    if [[ -d "/Applications/Sublime Text.app" ]]; then
        return 0
    else
        return 1
    fi
}

check_sublime_text_status() {
    if is_sublime_text_installed; then
        print_success "Sublime Text is already installed"
        return 0
    else
        print_info "Sublime Text is not installed"
        return 1
    fi
}

install_sublime_text() {
    local app_path="/Applications/Sublime Text.app"
    local details="Will download and install Sublime Text from the official source."

    if ! prompt_for_app_installation "Sublime Text" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading Sublime Text..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    local download_url="https://download.sublimetext.com/sublime_text_build_4152_mac.zip"
    local filename="SublimeText.zip"

    if download_file "$download_url" "$filename"; then
        if extract_zip "$filename"; then
            if install_app_to_applications "Sublime Text.app" "Sublime Text"; then
                print_success "Sublime Text installation completed"
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
        check_sublime_text_status
        exit $?
    fi

    install_sublime_text
}

main "$@"
