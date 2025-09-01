#!/bin/bash


set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_git_tower_installed() {
    if [[ -d "/Applications/Tower.app" ]]; then
        return 0
    else
        return 1
    fi
}

check_git_tower_status() {
    if is_git_tower_installed; then
        print_success "Git Tower is already installed"
        return 0
    else
        print_info "Git Tower is not installed"
        return 1
    fi
}

install_git_tower() {
    local app_path="/Applications/Tower.app"
    local details="Will download and install Git Tower from the official source."

    if ! prompt_for_app_installation "Git Tower" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading Git Tower..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    local download_url="https://www.git-tower.com/apps/mac"
    local filename="Tower.dmg"

    if download_file "$download_url" "$filename"; then
        if mount_dmg "$filename"; then
            if install_app_to_applications "Tower.app" "Git Tower"; then
                print_success "Git Tower installation completed"
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
        check_git_tower_status
        exit $?
    fi

    install_git_tower
}

main "$@"
