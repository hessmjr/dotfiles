#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

setup_favorites_folder() {
    print_info "Setting up favorites folder with directory aliases..."

    local favorites_dir="$HOME/favorites"
    local documents_dir="$HOME/Documents"
    local desktop_dir="$HOME/Desktop"
    local zsh_dir="$HOME/.zsh"

    # Create favorites directory if it doesn't exist
    if [[ ! -d "$favorites_dir" ]]; then
        print_info "Creating favorites directory at $favorites_dir"
        mkdir -p "$favorites_dir"
    else
        print_success "Favorites directory already exists"
    fi

    # Create aliases (symlinks) to the directories
    # Remove existing aliases if they exist to ensure clean setup
    if [[ -L "$favorites_dir/Documents" ]]; then
        print_info "Removing existing Documents alias"
        rm "$favorites_dir/Documents"
    fi
    if [[ -L "$favorites_dir/Desktop" ]]; then
        print_info "Removing existing Desktop alias"
        rm "$favorites_dir/Desktop"
    fi
    if [[ -L "$favorites_dir/zsh" ]]; then
        print_info "Removing existing zsh alias"
        rm "$favorites_dir/zsh"
    fi

    # Create new aliases
    print_info "Creating Documents alias"
    ln -s "$documents_dir" "$favorites_dir/Documents"

    print_info "Creating Desktop alias"
    ln -s "$desktop_dir" "$favorites_dir/Desktop"

    print_info "Creating zsh alias"
    ln -s "$zsh_dir" "$favorites_dir/zsh"

    print_success "Favorites folder setup complete"
}

add_favorites_to_dock() {
    print_info "Adding favorites folder to dock..."

    local favorites_dir="$HOME/favorites"

    # Check if favorites folder is already in dock
    local dock_items=$(defaults read com.apple.dock persistent-apps 2>/dev/null || echo "")
    local favorites_in_dock=false

    if [[ -n "$dock_items" ]]; then
        # Check if favorites folder is already in dock by looking for the path
        if echo "$dock_items" | grep -q "$favorites_dir"; then
            favorites_in_dock=true
        fi
    fi

    if [[ "$favorites_in_dock" == true ]]; then
        print_success "Favorites folder is already in dock"
        return 0
    fi

    # Add favorites folder to dock
    print_info "Adding favorites folder to dock..."

    # Use osascript to add the folder to dock
    osascript <<EOF
tell application "System Events"
    tell dock preferences
        set properties to {dock contents:dock contents & {make new folder at end of dock with properties {path:"$favorites_dir", display as:folder, sort by:name}}
    end tell
end tell
EOF

    # Alternative method using dockutil if available
    if command -v dockutil &> /dev/null; then
        print_info "Using dockutil to add favorites folder to dock..."
        dockutil --add "$favorites_dir" --view folder --display folder --sort name --no-restart
    fi

    # Restart dock to apply changes
    print_info "Restarting dock to apply changes..."
    killall Dock 2>/dev/null || true

    print_success "Favorites folder added to dock"
}

check_favorites_status() {
    local favorites_dir="$HOME/favorites"
    local documents_alias="$favorites_dir/Documents"
    local desktop_alias="$favorites_dir/Desktop"
    local zsh_alias="$favorites_dir/zsh"

    local all_good=true

    # Check if favorites directory exists
    if [[ ! -d "$favorites_dir" ]]; then
        print_info "Favorites directory does not exist"
        all_good=false
    fi

    # Check if aliases exist and are valid
    if [[ ! -L "$documents_alias" ]] || [[ ! -e "$documents_alias" ]]; then
        print_info "Documents alias is missing or broken"
        all_good=false
    fi

    if [[ ! -L "$desktop_alias" ]] || [[ ! -e "$desktop_alias" ]]; then
        print_info "Desktop alias is missing or broken"
        all_good=false
    fi

    if [[ ! -L "$zsh_alias" ]] || [[ ! -e "$zsh_alias" ]]; then
        print_info "zsh alias is missing or broken"
        all_good=false
    fi

    # Check if favorites folder is in dock
    local dock_items=$(defaults read com.apple.dock persistent-apps 2>/dev/null || echo "")
    local favorites_in_dock=false

    if [[ -n "$dock_items" ]] && echo "$dock_items" | grep -q "$favorites_dir"; then
        favorites_in_dock=true
    fi

    if [[ "$favorites_in_dock" == false ]]; then
        print_info "Favorites folder is not in dock"
        all_good=false
    fi

    if [[ "$all_good" == true ]]; then
        print_success "Favorites folder is properly configured"
        return 0
    else
        print_info "Favorites folder needs to be set up"
        return 1
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

    if [[ "$check_only" == true ]]; then
        check_favorites_status
        exit $?
    fi

    print_info "Setting up favorites folder..."

    setup_favorites_folder
    add_favorites_to_dock

    print_success "Favorites folder setup complete!"
    print_info "The favorites folder contains aliases to Documents, Desktop, and zsh directories"
    print_info "The folder has been added to your dock for easy access"
}

main "$@"
