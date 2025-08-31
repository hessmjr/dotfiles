#!/bin/bash

# macOS Homebrew Setup Script
# Installs Homebrew and essential development packages

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Check if Homebrew is installed
check_homebrew() {
    print_info "Checking Homebrew installation..."

    if command -v brew &> /dev/null; then
        local brew_path=$(which brew)
        print_success "Homebrew found at: $brew_path"
        return 0
    else
        print_warning "Homebrew not found"
        return 1
    fi
}

# Install Homebrew
install_homebrew() {
    print_section "Homebrew Installation"

    print_info "Installing Homebrew..."
    print_warning "This requires an internet connection and may take several minutes"

    # Install Homebrew using the official install script
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        print_success "Homebrew installed successfully"

        # Add Homebrew to PATH for current session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            # Apple Silicon Macs
            export PATH="/opt/homebrew/bin:$PATH"
            print_info "Added Homebrew to PATH for Apple Silicon Mac"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            # Intel Macs
            export PATH="/usr/local/bin:$PATH"
            print_info "Added Homebrew to PATH for Intel Mac"
        fi

        # Verify installation
        if check_homebrew; then
            print_success "Homebrew installation verified"
            return 0
        else
            print_error "Homebrew installation verification failed"
            return 1
        fi
    else
        print_error "Failed to install Homebrew"
        return 1
    fi
}

# Update Homebrew
update_homebrew() {
    print_section "Homebrew Update"

    print_info "Updating Homebrew..."

    if brew update; then
        print_success "Homebrew updated successfully"
        return 0
    else
        print_warning "Failed to update Homebrew"
        return 1
    fi
}

# Upgrade Homebrew packages
upgrade_homebrew_packages() {
    print_section "Homebrew Package Upgrade"

    print_info "Upgrading existing Homebrew packages..."

    if brew upgrade; then
        print_success "Homebrew packages upgraded successfully"
        return 0
    else
        print_warning "Failed to upgrade some Homebrew packages"
        return 1
    fi
}

# Install essential development packages
install_development_packages() {
    print_section "Development Packages Installation"

    print_info "Installing essential development packages..."

    # Define the packages to install
    local packages=(
        "git"              # Version control
        "asdf"             # Version manager for multiple languages
        "awscli"           # AWS command line interface
        "kubectx"          # Kubernetes context switcher
        "kubernetes-cli"   # Kubernetes command line tools
        "sops"             # Secrets management
        "terraform"        # Infrastructure as code
    )

    local failed_packages=()
    local successful_packages=()

    for package in "${packages[@]}"; do
        print_info "Installing $package..."

        if brew install "$package"; then
            print_success "$package installed successfully"
            successful_packages+=("$package")
        else
            print_warning "Failed to install $package"
            failed_packages+=("$package")
        fi
    done

    # Report results
    print_info "Installation Summary:"
    print_success "Successfully installed: ${successful_packages[*]}"

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        print_warning "Failed to install: ${failed_packages[*]}"
        print_info "You can try installing these manually with: brew install <package>"
    fi

    return ${#failed_packages[@]}
}

# Configure Homebrew
configure_homebrew() {
    print_section "Homebrew Configuration"

    print_info "Configuring Homebrew..."

    # Enable Homebrew analytics (optional - can be disabled if privacy is a concern)
    if ask_for_confirmation "Enable Homebrew analytics for better package support?" "y"; then
        brew analytics on
        print_success "Homebrew analytics enabled"
    else
        brew analytics off
        print_success "Homebrew analytics disabled"
    fi

    # Set up Homebrew completions
    print_info "Setting up Homebrew completions..."
    if [[ -f "/opt/homebrew/etc/bash_completion.d/brew" ]] || [[ -f "/usr/local/etc/bash_completion.d/brew" ]]; then
        print_success "Homebrew completions already configured"
    else
        print_info "Homebrew completions will be available after shell restart"
    fi

    # Clean up old versions
    print_info "Cleaning up old package versions..."
    if brew cleanup; then
        print_success "Homebrew cleanup completed"
    else
        print_warning "Homebrew cleanup failed"
    fi
}

# Verify package installations
verify_packages() {
    print_section "Package Verification"

    print_info "Verifying package installations..."

    local packages=("git" "asdf" "aws" "kubectx" "kubectl" "sops" "terraform")
    local missing_packages=()

    for package in "${packages[@]}"; do
        if command -v "$package" &> /dev/null; then
            local version=$("$package" --version 2>/dev/null | head -1 || echo "version unknown")
            print_success "$package: $version"
        else
            print_warning "$package: not found in PATH"
            missing_packages+=("$package")
        fi
    done

    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        print_success "All packages verified successfully"
        return 0
    else
        print_warning "Some packages may not be in PATH: ${missing_packages[*]}"
        print_info "Try restarting your terminal or adding Homebrew to your shell profile"
        return 1
    fi
}

# Main Homebrew setup function
setup_homebrew() {
    print_section "Homebrew Development Environment Setup"

    # Check if Homebrew is installed
    if check_homebrew; then
        print_info "Homebrew is already installed"

        # Update Homebrew
        if ask_for_confirmation "Update Homebrew to latest version?" "y"; then
            update_homebrew
        fi

        # Upgrade existing packages
        if ask_for_confirmation "Upgrade existing Homebrew packages?" "y"; then
            upgrade_homebrew_packages
        fi
    else
        print_info "Homebrew needs to be installed"

        if ask_for_confirmation "Install Homebrew now?" "y"; then
            install_homebrew
        else
            print_error "Homebrew is required for development packages"
            print_info "You can install it manually later with: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            return 1
        fi
    fi

    # Install development packages
    if ask_for_confirmation "Install essential development packages?" "y"; then
        install_development_packages
    else
        print_info "Skipping package installation"
    fi

    # Configure Homebrew
    configure_homebrew

    # Verify installations
    verify_packages

    print_success "Homebrew development environment setup completed!"
    print_info "You may need to restart your terminal for all changes to take effect"
    print_info "To add Homebrew to your shell profile, run: echo 'eval \"\$(/opt/homebrew/bin/brew shellenv)\"' >> ~/.zshrc"
}

# Main function
main() {
    setup_homebrew
}

# Run main function
main "$@"
