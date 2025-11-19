#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is intended for macOS only"
        exit 1
    fi

    local os_version=$(sw_vers -productVersion)
    local min_version="10.10"

    if [[ "$(echo "$os_version $min_version" | tr " " "\n" | sort -V | head -n1)" != "$min_version" ]]; then
        print_error "This script requires macOS $min_version or later (current: $os_version)"
        exit 1
    fi

    print_success "Detected macOS $os_version"
}

close_system_preferences() {
    print_info "Closing System Preferences to avoid conflicts..."
    osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
}

run_macos_setup() {
    print_info "Running macOS preference setup scripts..."

    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    close_system_preferences

    # Helper function to run scripts safely (prevents exit from killing parent)
    run_script_safely() {
        local script_path="$1"
        local script_name="$2"
        # Run in subshell with set +e to prevent exit from killing parent
        (set +e; "$script_path")
        local exit_code=$?
        return $exit_code
    }

    if ask_for_confirmation "Set up Dashboard preferences?" "y"; then
        print_info "Setting up Dashboard preferences..."
        if ! run_script_safely "$script_dir/dashboard.sh" "Dashboard"; then
            print_warning "Dashboard preferences setup failed, continuing..."
        fi
    else
        print_info "Skipping Dashboard preferences"
    fi

    if ask_for_confirmation "Set up Keyboard preferences?" "y"; then
        print_info "Setting up Keyboard preferences..."
        if ! run_script_safely "$script_dir/keyboard.sh" "Keyboard"; then
            print_warning "Keyboard preferences setup failed, continuing..."
        fi
    else
        print_info "Skipping Keyboard preferences"
    fi

    if ask_for_confirmation "Set up Trackpad preferences?" "y"; then
        print_info "Setting up Trackpad preferences..."
        if ! run_script_safely "$script_dir/trackpad.sh" "Trackpad"; then
            print_warning "Trackpad preferences setup failed, continuing..."
        fi
    else
        print_info "Skipping Trackpad preferences"
    fi

    if ask_for_confirmation "Set up UI & UX preferences?" "y"; then
        print_info "Setting up UI & UX preferences..."
        if ! run_script_safely "$script_dir/ui_and_ux.sh" "UI & UX"; then
            print_warning "UI & UX preferences setup failed, continuing..."
        fi
    else
        print_info "Skipping UI & UX preferences"
    fi

    if ask_for_confirmation "Set up System Updates preferences?" "y"; then
        print_info "Setting up System Updates preferences..."
        if ! run_script_safely "$script_dir/system_updates.sh" "System Updates"; then
            print_warning "System Updates preferences setup failed, continuing..."
        fi
    else
        print_info "Skipping System Updates preferences"
    fi

    if ask_for_confirmation "Set up Developer Tools (Xcode Command Line Tools)?" "y"; then
        print_info "Setting up Developer Tools..."
        if ! run_script_safely "$script_dir/developer_tools.sh" "Developer Tools"; then
            print_warning "Developer Tools setup failed, continuing..."
        fi
    else
        print_info "Skipping Developer Tools"
    fi

    if ask_for_confirmation "Set up Oh My Zsh?" "y"; then
        print_info "Setting up Oh My Zsh..."
        if ! run_script_safely "$script_dir/oh_my_zsh.sh" "Oh My Zsh"; then
            print_warning "Oh My Zsh setup failed, continuing..."
        fi
    else
        print_info "Skipping Oh My Zsh"
    fi

    if ask_for_confirmation "Set up Homebrew Development Environment?" "y"; then
        print_info "Setting up Homebrew Development Environment..."
        if ! run_script_safely "$script_dir/homebrew.sh" "Homebrew"; then
            print_warning "Homebrew Development Environment setup failed, continuing..."
        fi
    else
        print_info "Skipping Homebrew Development Environment"
    fi

    if ask_for_confirmation "Set up asdf Version Manager?" "y"; then
        print_info "Setting up asdf Version Manager..."
        if ! run_script_safely "$script_dir/asdf.sh" "asdf"; then
            print_warning "asdf Version Manager setup failed, continuing..."
        fi
    else
        print_info "Skipping asdf Version Manager"
    fi

    if ask_for_confirmation "Set up Favorites folder?" "y"; then
        print_info "Setting up Favorites folder..."
        if ! run_script_safely "$script_dir/favorites.sh" "Favorites"; then
            print_warning "Favorites folder setup failed, continuing..."
        fi
    else
        print_info "Skipping Favorites folder"
    fi

    print_success "macOS preference setup completed!"
}

check_macos_status() {
    print_info "Checking current macOS preferences status..."

    local needs_update=false
    local checked_count=0
    local total_checks=0

    # Check Dashboard preferences
    ((total_checks++))
    local dashboard_disabled=$(defaults read com.apple.dashboard mcx-disabled 2>/dev/null || echo "not_set")
    if [[ "$dashboard_disabled" == "1" ]]; then
        print_success "Dashboard is already disabled"
    else
        print_info "Dashboard needs to be disabled"
        needs_update=true
    fi
    ((checked_count++))

    # Check Keyboard preferences
    ((total_checks++))
    local keyboard_ui_mode=$(defaults read -g AppleKeyboardUIMode 2>/dev/null || echo "not_set")
    if [[ "$keyboard_ui_mode" == "3" ]]; then
        print_success "Full keyboard access is already enabled"
    else
        print_info "Full keyboard access needs to be enabled"
        needs_update=true
    fi
    ((checked_count++))

    # Check Trackpad preferences
    ((total_checks++))
    local tap_click=$(defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking 2>/dev/null || echo "not_set")
    if [[ "$tap_click" == "1" ]]; then
        print_success "Tap to click is already enabled"
    else
        print_info "Tap to click needs to be enabled"
        needs_update=true
    fi
    ((checked_count++))

    # Check UI/UX preferences
    ((total_checks++))
    local ds_store_network=$(defaults read com.apple.desktopservices DSDontWriteNetworkStores 2>/dev/null || echo "not_set")
    if [[ "$ds_store_network" == "1" ]]; then
        print_success "Network .DS_Store creation is already disabled"
    else
        print_info "Network .DS_Store creation needs to be disabled"
        needs_update=true
    fi
    ((checked_count++))

    # Check System Updates preferences
    ((total_checks++))
    local auto_check=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled 2>/dev/null || echo "not_set")
    if [[ "$auto_check" == "0" ]]; then
        print_success "Automatic system updates are already disabled"
    else
        print_info "Automatic system updates need to be disabled"
        needs_update=true
    fi
    ((checked_count++))

    # Check Developer Tools
    ((total_checks++))
    if xcode-select -p &> /dev/null; then
        print_success "Xcode Command Line Tools are already installed"
    else
        print_info "Xcode Command Line Tools need to be installed"
        needs_update=true
    fi
    ((checked_count++))

    # Check Homebrew
    ((total_checks++))
    if command -v brew &> /dev/null; then
        print_success "Homebrew is already installed"
    else
        print_info "Homebrew needs to be installed"
        needs_update=true
    fi
    ((checked_count++))

    # Check asdf
    ((total_checks++))
    if command -v asdf &> /dev/null; then
        print_success "asdf is already installed"
    else
        print_info "asdf needs to be installed"
        needs_update=true
    fi
    ((checked_count++))

    # Check Oh My Zsh
    ((total_checks++))
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_success "Oh My Zsh is already installed"
    else
        print_info "Oh My Zsh needs to be installed"
        needs_update=true
    fi
    ((checked_count++))

    # Check Favorites folder
    ((total_checks++))
    if "$script_dir/favorites.sh" --check-only 2>/dev/null; then
        print_success "Favorites folder is properly configured"
    else
        print_info "Favorites folder needs to be set up"
        needs_update=true
    fi
    ((checked_count++))

    print_info "macOS preferences status: $checked_count/$total_checks checks completed"

    if [[ "$needs_update" == true ]]; then
        print_info "Some macOS preferences need to be updated"
        return 1
    else
        print_success "All macOS preferences are already configured correctly"
        return 0
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

    print_info "Starting macOS system preferences setup..."

    check_macos

    if check_macos_status; then
        if [[ "$check_only" == true ]]; then
            exit 0
        else
            print_info "macOS preferences check complete - no action needed."
            exit 0
        fi
    fi

    if [[ "$check_only" == true ]]; then
        exit 1
    fi

    run_macos_setup

    print_success "macOS system preferences setup complete!"
    print_info "Some changes may require a restart to take full effect"
}

main "$@"
