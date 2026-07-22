#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

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

    if [[ ! -f "$SCRIPT_DIR/zsh/setup.sh" ]]; then
        print_error "Zsh setup script not found at $SCRIPT_DIR/zsh/setup.sh"
        return 1
    fi

    if [[ ! -f "$SCRIPT_DIR/agents/setup.sh" ]]; then
        print_error "AI agent setup script not found at $SCRIPT_DIR/agents/setup.sh"
        return 1
    fi

    if [[ ! -f "$SCRIPT_DIR/macos/setup.sh" ]]; then
        print_error "macOS setup script not found at $SCRIPT_DIR/macos/setup.sh"
        return 1
    fi

    if "$SCRIPT_DIR/zsh/setup.sh" --check-only 2>/dev/null; then
        print_info "Zsh configuration is up to date"
    else
        print_info "Zsh configuration updates needed"
        needs_update=true
    fi

    if "$SCRIPT_DIR/agents/setup.sh" --check-only 2>/dev/null; then
        print_info "AI agent configuration is up to date"
    else
        print_info "AI agent configuration updates needed"
        needs_update=true
    fi

    if "$SCRIPT_DIR/macos/setup.sh" --check-only 2>/dev/null; then
        print_info "macOS preferences are up to date"
    else
        print_info "macOS preferences updates needed"
        needs_update=true
    fi

    if [[ "$needs_update" == true ]]; then
        print_info "Updates needed - proceeding with installation/update"
        return 1
    else
        print_success "Zsh, AI agent, and macOS configurations are properly configured and up to date!"
        print_info "No installation needed - everything is already set up correctly."
        return 0
    fi
}

execute_setup() {
    print_info "Setting up dotfiles..."

    # Helper function to run scripts safely (prevents exit from killing parent)
    run_script_safely() {
        local script_path="$1"
        # Run in subshell with set +e to prevent exit from killing parent
        (set +e; "$script_path")
        local exit_code=$?
        return $exit_code
    }

    if [[ -f "$SCRIPT_DIR/zsh/setup.sh" ]]; then
        print_section "Zsh Configuration Setup"
        print_info "This will configure your zsh shell with custom aliases, functions, and prompt settings."
        print_info ""
        print_info "Checking current zsh configuration..."

        # Run check to show current state
        "$SCRIPT_DIR/zsh/setup.sh" --check-only 2>/dev/null || true

        print_info ""
        if ask_for_confirmation "Would you like to set up/update zsh configuration?" "y"; then
            print_info "Running zsh configuration setup..."
            if ! run_script_safely "$SCRIPT_DIR/zsh/setup.sh"; then
                print_warning "Zsh configuration setup failed, continuing with other sections..."
            fi
        else
            print_info "Skipping zsh configuration setup"
        fi
    else
        print_error "Zsh setup script not found"
        exit 1
    fi

    if [[ -f "$SCRIPT_DIR/agents/setup.sh" ]]; then
        print_section "AI Agent Configuration Setup"
        print_info "This will install shared agent instructions and configure Claude Code's command environment."
        print_info ""
        "$SCRIPT_DIR/agents/setup.sh" --check-only 2>/dev/null || true

        print_info ""
        if ask_for_confirmation "Would you like to set up/update AI agent configuration?" "y"; then
            if ! run_script_safely "$SCRIPT_DIR/agents/setup.sh"; then
                print_warning "AI agent configuration setup failed, continuing with other sections..."
            fi
        else
            print_info "Skipping AI agent configuration setup"
        fi
    else
        print_error "AI agent setup script not found"
        exit 1
    fi

    if [[ -f "$SCRIPT_DIR/macos/setup.sh" ]]; then
        print_section "macOS System Preferences Setup"
        print_info "This will configure various macOS system preferences including keyboard, trackpad, UI settings, and developer tools."
        print_info ""
        print_info "Checking current macOS preferences..."

        # Run check to show current state
        "$SCRIPT_DIR/macos/setup.sh" --check-only 2>/dev/null || true

        print_info ""
        if ask_for_confirmation "Would you like to set up/update macOS system preferences?" "y"; then
            print_info "Running macOS system preferences setup..."
            if ! run_script_safely "$SCRIPT_DIR/macos/setup.sh"; then
                print_warning "macOS system preferences setup failed, continuing with other sections..."
            fi
        else
            print_info "Skipping macOS system preferences setup"
        fi
    else
        print_error "macOS setup script not found"
        exit 1
    fi
}

# Applications are informational only: show a list of apps the user may want
# to install. Offered on every run, independent of the zsh/macOS status check.
show_apps() {
    if [[ -f "$SCRIPT_DIR/apps/setup.sh" ]]; then
        (set +e; "$SCRIPT_DIR/apps/setup.sh") || true
    fi
}

main() {
    print_info "Starting dotfiles setup..."
    print_section "Dotfiles Setup Overview"
    print_info "This setup covers four areas:"
    print_info "1. Zsh Configuration - Shell aliases, functions, and prompt"
    print_info "2. AI Agent Configuration - Shared instructions and Claude command environment"
    print_info "3. macOS Preferences - System settings, keyboard, trackpad, UI"
    print_info "4. Applications - A list of apps you may want to install"
    print_info ""
    print_info "You will be prompted for each major step. You can choose to complete or skip each section."

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    check_os

    if check_status; then
        print_info "Zsh, AI agents, and macOS already configured - no changes needed."
    else
        execute_setup
    fi

    # Applications are informational; always offer the list.
    show_apps

    print_section "Setup Summary"
    print_success "Dotfiles setup complete!"
    print_info "You may need to restart your terminal or run 'source ~/.zshrc' for changes to take effect"
    print_info ""
    print_info "Next steps:"
    print_info "- Restart your terminal to see zsh changes"
    print_info "- Restart Claude Code to load agent environment changes"
    print_info "- Check System Preferences for macOS changes"
}

main "$@"
