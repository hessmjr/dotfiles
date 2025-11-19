#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_os() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is intended for macOS only"
        exit 1
    fi
    print_success "Detected macOS"
}

check_status() {
    print_info "Checking current dotfiles status..."

    local needs_update=false

    if [[ ! -f "$SCRIPT_DIR/zsh/setup.sh" ]]; then
        print_error "Zsh setup script not found at $SCRIPT_DIR/zsh/setup.sh"
        return 1
    fi

    if [[ ! -f "$SCRIPT_DIR/macos/setup.sh" ]]; then
        print_error "macOS setup script not found at $SCRIPT_DIR/macos/setup.sh"
        return 1
    fi

    if "$SCRIPT_DIR/zsh/setup.sh" --check-only 2>/dev/null; then
        print_info "Zsh configuration is up to date"
    else
        print_info "Zsh configuration updates needed"
        needs_update=true
    fi

    if "$SCRIPT_DIR/macos/setup.sh" --check-only 2>/dev/null; then
        print_info "macOS preferences are up to date"
    else
        print_info "macOS preferences updates needed"
        needs_update=true
    fi

    if "$SCRIPT_DIR/apps/setup.sh" --check-only 2>/dev/null; then
        print_info "Applications are up to date"
    else
        print_info "Applications updates needed"
        needs_update=true
    fi

    if [[ "$needs_update" == true ]]; then
        print_info "Updates needed - proceeding with installation/update"
        return 1
    else
        print_success "All dotfiles, macOS preferences, and applications are properly configured and up to date!"
        print_info "No installation needed - everything is already set up correctly."
        return 0
    fi
}

execute_setup() {
    print_info "Setting up dotfiles..."

    if [[ -f "$SCRIPT_DIR/zsh/setup.sh" ]]; then
        print_section "Zsh Configuration Setup"
        print_info "This will configure your zsh shell with custom aliases, functions, and prompt settings."
        print_info ""
        print_info "Checking current zsh configuration..."

        # Run check to show current state
        "$SCRIPT_DIR/zsh/setup.sh" --check-only 2>/dev/null || true

        print_info ""
        if ask_for_confirmation "Would you like to set up/update zsh configuration?" "y"; then
            print_info "Running zsh configuration setup..."
            "$SCRIPT_DIR/zsh/setup.sh"
        else
            print_info "Skipping zsh configuration setup"
        fi
    else
        print_error "Zsh setup script not found"
        exit 1
    fi

    if [[ -f "$SCRIPT_DIR/macos/setup.sh" ]]; then
        print_section "macOS System Preferences Setup"
        print_info "This will configure various macOS system preferences including keyboard, trackpad, UI settings, and developer tools."
        print_info ""
        print_info "Checking current macOS preferences..."

        # Run check to show current state
        "$SCRIPT_DIR/macos/setup.sh" --check-only 2>/dev/null || true

        print_info ""
        if ask_for_confirmation "Would you like to set up/update macOS system preferences?" "y"; then
            print_info "Running macOS system preferences setup..."
            "$SCRIPT_DIR/macos/setup.sh"
        else
            print_info "Skipping macOS system preferences setup"
        fi
    else
        print_error "macOS setup script not found"
        exit 1
    fi

    if [[ -f "$SCRIPT_DIR/apps/setup.sh" ]]; then
        print_section "Applications Setup"
        print_info "This will install various applications including development tools, browsers, and utilities."
        print_info ""
        print_info "Checking current applications..."

        # Run check to show current state
        "$SCRIPT_DIR/apps/setup.sh" --check-only 2>/dev/null || true

        print_info ""
        if ask_for_confirmation "Would you like to set up/update applications?" "y"; then
            print_info "Running applications setup..."
            "$SCRIPT_DIR/apps/setup.sh"
        else
            print_info "Skipping applications setup"
        fi
    else
        print_error "Apps setup script not found"
        exit 1
    fi
}

main() {
    print_info "Starting dotfiles setup..."
    print_section "Dotfiles Setup Overview"
    print_info "This setup will configure three main areas:"
    print_info "1. Zsh Configuration - Shell aliases, functions, and prompt"
    print_info "2. macOS Preferences - System settings, keyboard, trackpad, UI"
    print_info "3. Applications - Development tools, browsers, utilities"
    print_info ""
    print_info "You will be prompted for each major step. You can choose to complete or skip each section."

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    check_os

    if check_status; then
        print_info "Setup check complete - no action needed."
        exit 0
    fi

    execute_setup

    print_section "Setup Summary"
    print_success "Dotfiles setup complete!"
    print_info "You may need to restart your terminal or run 'source ~/.zshrc' for changes to take effect"
    print_info ""
    print_info "Next steps:"
    print_info "- Restart your terminal to see zsh changes"
    print_info "- Check System Preferences for macOS changes"
    print_info "- Launch newly installed applications"
}

main "$@"
