#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_zsh_status() {
    print_info "Checking current zsh configuration status..."

    local existing_files=()
    local missing_files=()
    local needs_update=false
    local zsh_dir="$HOME/.zsh"

    local zsh_files=(
        "aliases.zsh"
        "exports.zsh"
        "functions.zsh"
        "prompt.zsh"
    )

    # Check if ~/.zsh directory exists
    if [[ ! -d "$zsh_dir" ]]; then
        print_info "~/.zsh directory does not exist"
        needs_update=true
    fi

    for file in "${zsh_files[@]}"; do
        local target="$zsh_dir/$file"
        local expected_source="$SCRIPT_DIR/src/zsh/$file"

        if [[ -f "$target" ]]; then
            existing_files+=("$file")
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

create_zsh_symlinks() {
    print_info "Setting up zsh configuration files..."

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_dir="$HOME/.dotfiles_backup/$timestamp"
    local backup_created=false

    # Create ~/.zsh directory if it doesn't exist
    local zsh_dir="$HOME/.zsh"
    if [[ ! -d "$zsh_dir" ]]; then
        print_info "Creating ~/.zsh directory..."
        mkdir -p "$zsh_dir"
    fi

    local zsh_files=(
        "aliases.zsh"
        "exports.zsh"
        "functions.zsh"
        "prompt.zsh"
    )

    # First pass: check if any files need backing up
    local needs_backup=false
    for file in "${zsh_files[@]}"; do
        local target="$zsh_dir/$file"
        if [[ -f "$target" ]] && [[ ! -L "$target" ]]; then
            needs_backup=true
            break
        fi
    done

    # Only create backup directory if there are files to backup
    if [[ "$needs_backup" == true ]]; then
        mkdir -p "$backup_dir"
        backup_created=true
        print_info "Backup directory: $backup_dir"
    fi

    for file in "${zsh_files[@]}"; do
        local source="$SCRIPT_DIR/src/zsh/$file"
        local target="$zsh_dir/$file"

        if [[ -f "$source" ]]; then
            if [[ -f "$target" ]]; then
                if [[ ! -L "$target" ]]; then
                    if [[ "$backup_created" == false ]]; then
                        mkdir -p "$backup_dir"
                        backup_created=true
                        print_info "Backup directory: $backup_dir"
                    fi
                    print_warning "Backing up existing $target to $backup_dir/"
                    mv "$target" "$backup_dir/"
                elif [[ -L "$target" ]]; then
                    # Only backup symlink if backup dir was already created
                    if [[ "$backup_created" == true ]]; then
                        print_info "Backing up existing symlink $target to $backup_dir/"
                        cp -P "$target" "$backup_dir/" 2>/dev/null || true
                    fi
                fi
            fi

            ln -sf "$source" "$target"
            print_success "Linked $target → $source"
        else
            print_warning "Source file $source not found, skipping"
        fi
    done

    # Create private.zsh template if it doesn't exist
    local private_file="$zsh_dir/private.zsh"
    if [[ ! -f "$private_file" ]]; then
        print_info "Creating private.zsh template for secrets..."
        cat > "$private_file" << 'EOF'
# Private Zsh Configuration
# This file is for personal secrets, API keys, and sensitive configurations
# Add your private configurations here - this file is not tracked in git

# Example:
# export API_KEY="your-secret-api-key"
# export DATABASE_PASSWORD="your-database-password"
# alias secret_command="your-secret-command"

# Add your private configurations below this line
EOF
        print_success "Created $private_file template"
        print_info "You can edit it with: edit_zsh_private"
    else
        print_info "private.zsh already exists, skipping creation"
    fi

    # Only show backup message if backup directory exists and has files
    if [[ "$backup_created" == true ]] && [[ -d "$backup_dir" ]] && [[ "$(ls -A "$backup_dir" 2>/dev/null)" ]]; then
        print_info "Previous zsh configurations backed up to: $backup_dir"
        print_info "To restore: copy files from backup directory to your home directory"
    elif [[ "$backup_created" == true ]] && [[ -d "$backup_dir" ]] && [[ -z "$(ls -A "$backup_dir" 2>/dev/null)" ]]; then
        # Clean up empty backup directory
        rmdir "$backup_dir" 2>/dev/null || true
    fi
}

main() {
    local check_only=false

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

    print_info "Starting zsh configuration setup..."

    if check_zsh_status; then
        if [[ "$check_only" == true ]]; then
            exit 0
        else
            print_info "Zsh configuration check complete - no action needed."
            exit 0
        fi
    fi

    if [[ "$check_only" == true ]]; then
        exit 1
    fi

    create_zsh_symlinks

    print_success "Zsh configuration setup complete!"
    print_info "You may need to restart your terminal or run 'source ~/.zshrc' for changes to take effect"
}

main "$@"
