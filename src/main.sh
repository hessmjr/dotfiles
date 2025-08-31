#!/bin/bash


set -e

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

check_status() {
    print_info "Checking current dotfiles status..."

    local needs_update=false

    if [[ ! -f "$SCRIPT_DIR/src/zsh/setup.sh" ]]; then
        print_error "Zsh setup script not found at $SCRIPT_DIR/src/zsh/setup.sh"
        return 1
    fi

    if [[ ! -f "$SCRIPT_DIR/src/macos/setup.sh" ]]; then
        print_error "macOS setup script not found at $SCRIPT_DIR/src/macos/setup.sh"
        return 1
    fi

    if "$SCRIPT_DIR/src/zsh/setup.sh" --check-only 2>/dev/null; then
        print_info "Zsh configuration is up to date"
    else
        print_info "Zsh configuration updates needed"
        needs_update=true
    fi

    if "$SCRIPT_DIR/src/macos/setup.sh" --check-only 2>/dev/null; then
        print_info "macOS preferences are up to date"
    else
        print_info "macOS preferences updates needed"
        needs_update=true
    fi

    if "$SCRIPT_DIR/src/apps/setup.sh" --check-only 2>/dev/null; then
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

    if [[ -f "$SCRIPT_DIR/src/zsh/setup.sh" ]]; then
        print_info "Running zsh configuration setup..."
        "$SCRIPT_DIR/src/zsh/setup.sh"
    else
        print_error "Zsh setup script not found"
        exit 1
    fi

    if [[ -f "$SCRIPT_DIR/src/macos/setup.sh" ]]; then
        print_info "Running macOS system preferences setup..."
        "$SCRIPT_DIR/src/macos/setup.sh"
    else
        print_error "macOS setup script not found"
        exit 1
    fi

    if [[ -f "$SCRIPT_DIR/src/apps/setup.sh" ]]; then
        print_info "Running applications setup..."
        "$SCRIPT_DIR/src/apps/setup.sh"
    else
        print_error "Apps setup script not found"
        exit 1
    fi
}

main() {
    print_info "Starting dotfiles setup..."

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    check_os

    if check_status; then
        print_info "Setup check complete - no action needed."
        exit 0
    fi

    execute_setup

    print_success "Dotfiles setup complete!"
    print_info "You may need to restart your terminal or run 'source ~/.zshrc' for changes to take effect"
}

main "$@"
