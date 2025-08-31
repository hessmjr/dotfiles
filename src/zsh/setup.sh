#!/bin/bash

# Zsh Setup Script
# This script handles all zsh-specific configuration and setup

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

# Check current zsh dotfiles status
check_zsh_status() {
    print_info "Checking current zsh configuration status..."

    local existing_files=()
    local missing_files=()
    local needs_update=false

    # Zsh configuration files to check
    local zsh_files=(
        "aliases.zsh"
        "exports.zsh"
        "functions.zsh"
        "prompt.zsh"
    )

    for file in "${zsh_files[@]}"; do
        local target="$HOME/.$file"
        local expected_source="$SCRIPT_DIR/src/zsh/$file"

        if [[ -f "$target" ]]; then
            existing_files+=("$file")
            # Check if it's a symlink pointing to the right place
            if [[ ! -L "$target" ]] || [[ "$(readlink "$target")" != "$expected_source" ]]; then
                needs_update=true
            fi
        else
            missing_files+=("$file")
            needs_update=true
        fi
    done

    if [[ ${#existing_files[@]} -gt 0 ]]; then
        print_info "Found existing zsh files: ${existing_files[*]}"
    fi

    if [[ ${#missing_files[@]} -gt 0 ]]; then
        print_info "Missing zsh files: ${missing_files[*]}"
    fi

    if [[ "$needs_update" == true ]]; then
        print_info "Zsh configuration updates needed"
        return 1
    else
        print_success "All zsh files are properly configured and up to date!"
        return 0
    fi
}

# Create symbolic links for zsh dotfiles with timestamped backups
create_zsh_symlinks() {
    print_info "Setting up zsh configuration files..."

    # Create timestamped backup directory
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_dir="$HOME/.dotfiles_backup/$timestamp"
    mkdir -p "$backup_dir"

    print_info "Backup directory: $backup_dir"

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
                    print_warning "Backing up existing $target to $backup_dir/"
                    mv "$target" "$backup_dir/"
                elif [[ -L "$target" ]]; then
                    # Also backup symlinks for reference
                    print_info "Backing up existing symlink $target to $backup_dir/"
                    cp -P "$target" "$backup_dir/" 2>/dev/null || true
                fi
            fi

            # Create symbolic link
            ln -sf "$source" "$target"
            print_success "Linked $target → $source"
        else
            print_warning "Source file $source not found, skipping"
        fi
    done

    if [[ -d "$backup_dir" ]] && [[ "$(ls -A "$backup_dir")" ]]; then
        print_info "Previous zsh configurations backed up to: $backup_dir"
        print_info "To restore: copy files from backup directory to your home directory"
    fi
}

# Main zsh setup function
main() {
    local check_only=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check-only)
                check_only=true
                shift
                ;;
            *)
                print_warning "Unknown option: $1"
                print_info "Usage: $0 [--check-only]"
                exit 1
                ;;
        esac
    done

    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    # Check current zsh status
    if check_zsh_status; then
        if [[ "$check_only" == true ]]; then
            exit 0
        else
            print_info "Zsh configuration check complete - no action needed."
            exit 0
        fi
    fi

    # If check-only mode, exit with error code
    if [[ "$check_only" == true ]]; then
        exit 1
    fi

    # Create zsh symbolic links if updates needed
    create_zsh_symlinks

    print_success "Zsh configuration setup complete!"
    print_info "You may need to restart your terminal or run 'source ~/.zshrc' for changes to take effect"
}

# Run main function
main "$@"
