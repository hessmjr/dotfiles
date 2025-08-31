#!/bin/bash

# Apps Main Setup Script
# Dynamically discovers and runs all app installation scripts

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is intended for macOS only"
        exit 1
    fi
    print_success "Detected macOS"
}

# Discover all available app installers
discover_app_installers() {
    local installers_dir="$SCRIPT_DIR/installers"
    local installers=()

    if [[ ! -d "$installers_dir" ]]; then
        print_error "Installers directory not found: $installers_dir"
        return 1
    fi

    # Find all .sh files in the installers directory
    while IFS= read -r -d '' file; do
        local filename=$(basename "$file")
        if [[ "$filename" != "main.sh" ]]; then  # Exclude main.sh if it got moved
            installers+=("$filename")
        fi
    done < <(find "$installers_dir" -name "*.sh" -type f -print0)

    echo "${installers[@]}"
}

# Run all discovered app installation scripts
run_apps_setup() {
    local non_interactive="${1:-false}"
    print_info "Discovering app installers..."

    # Discover available installers
    local installers=($(discover_app_installers))

    if [[ ${#installers[@]} -eq 0 ]]; then
        print_warning "No app installers found in $SCRIPT_DIR/installers/"
        return 1
    fi

    print_info "Found ${#installers[@]} app installers: ${installers[*]}"

    # Initialize progress tracking
    init_progress "${#installers[@]}"

    # Ask user if they want to proceed with app installation (unless non-interactive)
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

    # Run each discovered installer script
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

# Check current apps status
check_apps_status() {
    print_info "Checking current applications status..."

    # For now, we'll assume updates are always needed since we're downloading fresh
    # In the future, we could add more sophisticated checking
    return 1
}

# Main apps setup function
main() {
    local check_only=false
    local non_interactive=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check-only)
                check_only=true
                shift
                ;;
            --non-interactive)
                non_interactive=true
                shift
                ;;
            --help|-h)
                print_info "Usage: $0 [OPTIONS]"
                print_info "Options:"
                print_info "  --check-only        Check status without making changes"
                print_info "  --non-interactive   Skip all user prompts (for automation)"
                print_info "  --help, -h          Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                print_info "Usage: $0 [--check-only] [--non-interactive] [--help]"
                exit 1
                ;;
        esac
    done

    print_info "Starting applications setup..."

    # Check macOS compatibility
    check_macos

    # Check current apps status
    if check_apps_status; then
        if [[ "$check_only" == true ]]; then
            exit 0
        else
            print_info "Applications check complete - no action needed."
            exit 0
        fi
    fi

    # If check-only mode, exit with error code
    if [[ "$check_only" == true ]]; then
        exit 1
    fi

    # Set non-interactive mode for utils if requested
    if [[ "$non_interactive" == true ]]; then
        export NON_INTERACTIVE=true
    fi

    # Run the apps setup
    run_apps_setup "$non_interactive"

    print_success "Applications setup complete!"
    print_info "Some applications may require manual setup or configuration"
}

# Run main function
main "$@"
