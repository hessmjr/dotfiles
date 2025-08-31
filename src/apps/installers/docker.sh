#!/bin/bash


set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_docker_installed() {
    if [[ -d "/Applications/Docker.app" ]]; then
        return 0
    else
        return 1
    fi
}

check_docker_status() {
    if is_docker_installed; then
        print_success "Docker Desktop is already installed"
        return 0
    else
        print_info "Docker Desktop is not installed"
        return 1
    fi
}

install_docker() {
    local app_path="/Applications/Docker.app"
    local details="Will download and install Docker Desktop from Docker's official source."

    if ! prompt_for_app_installation "Docker Desktop" "$app_path" "$details"; then
        return 0
    fi

    print_info "Downloading Docker Desktop..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    local download_url="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
    local filename="Docker.dmg"

    if download_file "$download_url" "$filename"; then
        if mount_dmg "$filename"; then
            if install_app_to_applications "Docker.app" "Docker Desktop"; then
                print_success "Docker Desktop installation completed"
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
        check_docker_status
        exit $?
    fi

    install_docker
}

main "$@"
