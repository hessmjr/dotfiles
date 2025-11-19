#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Get the apps directory (where this script is located)
APPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is intended for macOS only"
        exit 1
    fi
    print_success "Detected macOS"
}

discover_app_installers() {
    local installers_dir="$APPS_DIR/installers"
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
    print_info "Discovering app installers..."

    local installers=($(discover_app_installers))

    if [[ ${#installers[@]} -eq 0 ]]; then
        print_warning "No app installers found in $APPS_DIR/installers/"
        return 1
    fi

    print_info "Found ${#installers[@]} app installers: ${installers[*]}"

    init_progress "${#installers[@]}"

    if ! ask_for_confirmation_with_details "App Installation Summary" \
        "Found ${#installers[@]} applications to potentially install. You'll be prompted before each installation." "y"; then
        print_info "App installation cancelled by user"
        return 0
    fi

    print_info "Starting app installation process..."

    # Helper function to run scripts safely (prevents exit from killing parent)
    run_script_safely() {
        local script_path="$1"
        # Run in subshell with set +e to prevent exit from killing parent
        (set +e; "$script_path")
        local exit_code=$?
        return $exit_code
    }

    for installer in "${installers[@]}"; do
        local installer_path="$APPS_DIR/installers/$installer"

        if [[ -f "$installer_path" ]]; then
            update_progress "Processing $installer"

            if run_script_safely "$installer_path"; then
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

    local installers_dir="$APPS_DIR/installers"
    local needs_update=false
    local checked_count=0
    local total_count=0

    if [[ ! -d "$installers_dir" ]]; then
        print_error "Installers directory not found: $installers_dir"
        return 1
    fi

    # Get list of available installers
    local installers=($(discover_app_installers))
    total_count=${#installers[@]}

    if [[ $total_count -eq 0 ]]; then
        print_warning "No app installers found"
        return 1
    fi

    print_info "Checking ${total_count} available applications..."

    # Check each application using its own installer script
    for installer in "${installers[@]}"; do
        local installer_path="$APPS_DIR/installers/$installer"

        if [[ -f "$installer_path" ]]; then
            print_info "Checking $installer..."

            # Call the installer script with --check-only flag
            if "$installer_path" --check-only 2>/dev/null; then
                print_success "$installer is already properly configured"
                ((checked_count++))
            else
                print_info "$installer needs to be installed/updated"
                needs_update=true
                ((checked_count++))
            fi
        else
            print_warning "Installer script not found: $installer_path"
        fi
    done

    print_info "Applications status: $checked_count/$total_count checks completed"

    if [[ "$needs_update" == true ]]; then
        print_info "Some applications need to be installed or updated"
        return 1
    else
        print_success "All available applications are already properly configured"
        return 0
    fi
}

main() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check-only)
                if check_apps_status; then
                    exit 0
                else
                    exit 1
                fi
                ;;
            *)
                print_warning "Unknown option: $1"
                print_info "Usage: $0 [--check-only]"
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

    run_apps_setup

    print_success "Applications setup complete!"
}

main "$@"
