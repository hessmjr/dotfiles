#!/bin/bash

# Main Dotfiles Setup Script
# This script handles the complete setup of dotfiles

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
check_os() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is intended for macOS only"
        exit 1
    fi
    print_success "Detected macOS"
}

# Check current dotfiles status and determine action needed
check_dotfiles_status() {
    print_info "Checking current dotfiles status..."

    local needs_update=false

    # Check if zsh setup script exists
    if [[ ! -f "$SCRIPT_DIR/src/zsh/setup.sh" ]]; then
        print_error "Zsh setup script not found at $SCRIPT_DIR/src/zsh/setup.sh"
        return 1
    fi

    # Check if macOS setup script exists
    if [[ ! -f "$SCRIPT_DIR/src/macos/main.sh" ]]; then
        print_error "macOS setup script not found at $SCRIPT_DIR/src/macos/main.sh"
        return 1
    fi

    # Run zsh setup script to check status
    if "$SCRIPT_DIR/src/zsh/setup.sh" --check-only 2>/dev/null; then
        print_info "Zsh configuration is up to date"
    else
        print_info "Zsh configuration updates needed"
        needs_update=true
    fi

    # Run macOS setup script to check status
    if "$SCRIPT_DIR/src/macos/setup.sh" --check-only 2>/dev/null; then
        print_info "macOS preferences are up to date"
    else
        print_info "macOS preferences updates needed"
        needs_update=true
    fi

    if [[ "$needs_update" == true ]]; then
        print_info "Updates needed - proceeding with installation/update"
        return 1
    else
        print_success "All dotfiles and macOS preferences are properly configured and up to date!"
        print_info "No installation needed - everything is already set up correctly."
        return 0
    fi
}

# Create symbolic links for dotfiles
create_symlinks() {
    print_info "Setting up dotfiles..."

    # Run zsh setup script
    if [[ -f "$SCRIPT_DIR/src/zsh/setup.sh" ]]; then
        print_info "Running zsh configuration setup..."
        "$SCRIPT_DIR/src/zsh/setup.sh"
    else
        print_error "Zsh setup script not found"
        exit 1
    fi

    # Run macOS setup script
    if [[ -f "$SCRIPT_DIR/src/macos/main.sh" ]]; then
        print_info "Running macOS system preferences setup..."
        "$SCRIPT_DIR/src/macos/main.sh"
    else
        print_error "macOS setup script not found"
        exit 1
    fi
}

# Main function
main() {
    print_info "Starting dotfiles setup..."

    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Check OS
    check_os

    # Check current dotfiles status
    if check_dotfiles_status; then
        print_info "Setup check complete - no action needed."
        exit 0
    fi

    # Create symbolic links if updates needed
    create_symlinks

    print_success "Dotfiles setup complete!"
    print_info "You may need to restart your terminal or run 'source ~/.zshrc' for changes to take effect"
}

# Run main function
main "$@"
