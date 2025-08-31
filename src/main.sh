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

# Create symbolic links for dotfiles
create_symlinks() {
    print_info "Creating symbolic links for dotfiles..."

    local backup_dir="$HOME/.dotfiles_backup"
    mkdir -p "$backup_dir"

    # Zsh configuration files
    local zsh_files=(
        "aliases.zsh"
        "exports.zsh"
        "functions.zsh"
        "prompt.zsh"
    )

    for file in "${zsh_files[@]}"; do
        local source="$SCRIPT_DIR/src/zsh/$file"
        local target="$HOME/.$file"

        if [[ -f "$source" ]]; then
            # Backup existing file if it exists
            if [[ -f "$target" ]]; then
                if [[ ! -L "$target" ]]; then
                    print_warning "Backing up existing $target"
                    mv "$target" "$backup_dir/"
                fi
            fi

            # Create symbolic link
            ln -sf "$source" "$target"
            print_success "Linked $target → $source"
        else
            print_warning "Source file $source not found, skipping"
        fi
    done
}

# Main function
main() {
    print_info "Starting dotfiles setup..."

    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Check OS
    check_os

    # Create symbolic links
    create_symlinks

    print_success "Dotfiles setup complete!"
    print_info "You may need to restart your terminal or run 'source ~/.zshrc' for changes to take effect"
}

# Run main function
main "$@"
