#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

is_asdf_installed() {
    if command -v asdf >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

check_asdf_status() {
    if is_asdf_installed; then
        local version=$(asdf --version 2>/dev/null | head -n1 | cut -d' ' -f2 || echo "unknown")
        print_success "asdf is already installed (version: $version)"
        return 0
    else
        print_info "asdf is not installed"
        return 1
    fi
}

# asdf helper functions
asdf_install_latest() {
    local tool="$1"
    if [[ -z "$tool" ]]; then
        print_error "Usage: asdf_install_latest <tool>"
        return 1
    fi

    local latest_version=$(asdf latest "$tool" 2>/dev/null)
    if [[ -n "$latest_version" ]]; then
        print_info "Installing latest $tool version: $latest_version"
        asdf install "$tool" "$latest_version"
        asdf global "$tool" "$latest_version"
        print_success "$tool $latest_version installed and set as global"
    else
        print_error "Could not find latest version for $tool"
        return 1
    fi
}

asdf_install_common() {
    print_info "Installing common development tools with asdf..."

    # Node.js
    if asdf plugin list | grep -q "nodejs"; then
        asdf_install_latest "nodejs"
    else
        print_warning "Node.js plugin not installed. Run: asdf plugin add nodejs"
    fi

    # Python
    if asdf plugin list | grep -q "python"; then
        asdf_install_latest "python"
    else
        print_warning "Python plugin not installed. Run: asdf plugin add python"
    fi

    # Ruby
    if asdf plugin list | grep -q "ruby"; then
        asdf_install_latest "ruby"
    else
        print_warning "Ruby plugin not installed. Run: asdf plugin add ruby"
    fi
}

asdf_setup_plugins() {
    print_info "Setting up common asdf plugins..."

    # Add common plugins
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    asdf plugin add python
    asdf plugin add ruby
    asdf plugin add golang

    print_success "Common asdf plugins added successfully"
}

install_asdf() {
    print_info "Installing asdf version manager via Homebrew..."

    # Check if Homebrew is available
    if ! command -v brew >/dev/null 2>&1; then
        print_error "Homebrew is required to install asdf. Please install Homebrew first."
        return 1
    fi

    # Install asdf via Homebrew
    print_info "Installing asdf via Homebrew..."
    if brew install asdf; then
        print_success "asdf installed successfully via Homebrew"
    else
        print_error "Failed to install asdf via Homebrew"
        return 1
    fi

    # Source asdf shell integration to make it available in current session
    if [[ -f "$(brew --prefix asdf)/libexec/asdf.sh" ]]; then
        source "$(brew --prefix asdf)/libexec/asdf.sh"
        print_info "Sourced asdf shell integration"
    fi

    # Verify installation
    if is_asdf_installed; then
        local version=$(asdf --version 2>/dev/null | head -n1 | cut -d' ' -f2 || echo "unknown")
        print_success "asdf installation completed (version: $version)"

        # Set up common plugins and tools
        print_info "Setting up common asdf plugins and tools..."
        asdf_setup_plugins

        # Ask if user wants to install common development tools
        if ask_for_confirmation "Would you like to install common development tools (Node.js, Python, Ruby)?" "y"; then
            asdf_install_common
        else
            print_info "Skipping common development tools installation"
        fi

        print_info "Note: You may need to restart your terminal or run 'source ~/.zshrc' for asdf to be available"
        return 0
    else
        print_error "asdf installation failed"
        return 1
    fi
}

main() {
    print_info "Setting up asdf version manager..."

    if check_asdf_status; then
        print_info "asdf is already properly configured"
        return 0
    fi

    install_asdf
}

main "$@"
