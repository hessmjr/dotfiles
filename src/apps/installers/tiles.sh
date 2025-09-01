#!/bin/bash


set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_tiles_installed() {
    if [[ -d "/Applications/Tiles.app" ]]; then
        return 0
    else
        return 1
    fi
}

check_tiles_status() {
    if is_tiles_installed; then
        print_success "Tiles is already installed"
        return 0
    else
        print_info "Tiles is not installed"
        return 1
    fi
}

install_tiles() {
    local app_path="/Applications/Tiles.app"
    local details="Will download and install Tiles from the official source."

    if ! prompt_for_app_installation "Tiles" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading Tiles..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    local download_url="https://freemacsoft.net/downloads/Tiles.zip"
    local filename="Tiles.zip"

    if download_file "$download_url" "$filename"; then
        if extract_zip "$filename"; then
            if install_app_to_applications "Tiles.app" "Tiles"; then
                print_success "Tiles installation completed"
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
        check_tiles_status
        exit $?
    fi

    install_tiles
}

main "$@"
