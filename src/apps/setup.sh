#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is intended for macOS only"
        exit 1
    fi
    print_success "Detected macOS"
}

discover_app_installers() {
    local installers_dir="$SCRIPT_DIR/installers"
    local installers=()

    if [[ ! -d "$installers_dir" ]]; then
        print_error "Installers directory not found: $installers_dir"
        return 1
    fi

    while IFS= read -r -d '' file; do
        local filename=$(basename "$file")
        if [[ "$filename" != "setup.sh" ]]; then
            installers+=("$filename")
        fi
    done < <(find "$installers_dir" -name "*.sh" -type f -print0)

    echo "${installers[@]}"
}

run_apps_setup() {
    local non_interactive="${1:-false}"
    print_info "Discovering app installers..."

    local installers=($(discover_app_installers))

    if [[ ${#installers[@]} -eq 0 ]]; then
        print_warning "No app installers found in $SCRIPT_DIR/installers/"
        return 1
    fi

    print_info "Found ${#installers[@]} app installers: ${installers[*]}"

    init_progress "${#installers[@]}"

    if [[ "$non_interactive" != true ]]; then
        if ! ask_for_confirmation_with_details "App Installation Summary" \
            "Found ${#installers[@]} applications to potentially install. You'll be prompted before each installation." "y"; then
            print_info "App installation cancelled by user"
            return 0
        fi
    else
        print_info "Non-interactive mode: proceeding with all app installations"
    fi

    print_info "Starting app installation process..."

    for installer in "${installers[@]}"; do
        local installer_path="$SCRIPT_DIR/installers/$installer"

        if [[ -f "$installer_path" ]]; then
            update_progress "Processing $installer"

            if "$installer_path"; then
                print_success "$installer completed successfully"
            else
                print_warning "$installer failed, continuing with other apps..."
            fi
        else
            print_error "Installer script not found: $installer_path"
        fi
    done

    print_success "All app installation scripts completed!"
}

check_apps_status() {
    print_info "Checking current applications status..."
    return 1
}

main() {
    local non_interactive="${1:-false}"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --check-only)
                if check_apps_status; then
                    exit 0
                else
                    exit 1
                fi
                ;;
            --non-interactive)
                non_interactive=true
                shift
                ;;
            *)
                print_warning "Unknown option: $1"
                print_info "Usage: $0 [--check-only] [--non-interactive]"
                exit 1
                ;;
        esac
    done

    print_info "Starting applications setup..."

    check_macos

    if check_apps_status; then
        print_info "Applications check complete - no action needed."
        exit 0
    fi

    run_apps_setup "$non_interactive"

    print_success "Applications setup complete!"
}

main "$@"
