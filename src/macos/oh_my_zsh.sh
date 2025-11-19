#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_oh_my_zsh_installed() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        return 0
    else
        return 1
    fi
}

check_oh_my_zsh_status() {
    if is_oh_my_zsh_installed; then
        print_success "Oh My Zsh is already installed"
        return 0
    else
        print_info "Oh My Zsh is not installed"
        return 1
    fi
}

install_oh_my_zsh() {
    print_section "Oh My Zsh Installation"

    print_info "Installing Oh My Zsh..."
    print_warning "This will install Oh My Zsh to ~/.oh-my-zsh"

    # Install Oh My Zsh using the official install script
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        print_success "Oh My Zsh installed successfully"
        return 0
    else
        print_error "Failed to install Oh My Zsh"
        return 1
    fi
}

setup_oh_my_zsh() {
    print_section "Oh My Zsh Setup"

    # Check if Oh My Zsh is installed
    if check_oh_my_zsh_status; then
        print_info "Oh My Zsh is already installed"
        return 0
    else
        print_info "Oh My Zsh needs to be installed"

        if ask_for_confirmation "Install Oh My Zsh now?" "y"; then
            install_oh_my_zsh
        else
            print_info "Skipping Oh My Zsh installation"
            print_info "You can install it manually later with: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
            return 0
        fi
    fi
}

main() {
    setup_oh_my_zsh
}

main "$@"

