#!/bin/bash

# macOS Developer Tools Setup Script
# Ensures Xcode Command Line Tools are installed and up to date

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Check if Xcode Command Line Tools are installed
check_xcode_tools() {
    print_info "Checking Xcode Command Line Tools installation..."

    if xcode-select -p &> /dev/null; then
        local tools_path=$(xcode-select -p)
        print_success "Xcode Command Line Tools found at: $tools_path"
        return 0
    else
        print_warning "Xcode Command Line Tools not found"
        return 1
    fi
}

# Check if Xcode Command Line Tools are up to date
check_xcode_tools_updates() {
    print_info "Checking for Xcode Command Line Tools updates..."

    if softwareupdate -l 2>&1 | grep -q "Command Line Tools"; then
        print_warning "Updates available for Xcode Command Line Tools"
        return 1
    else
        print_success "Xcode Command Line Tools are up to date"
        return 0
    fi
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    print_section "Xcode Command Line Tools Installation"

    print_info "Installing Xcode Command Line Tools..."
    print_warning "This may take several minutes and requires an internet connection"

    # Create a temporary file to trigger the installation
    local temp_file="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    touch "$temp_file"

    # Get the identifier for Command Line Tools
    local product_id=$(softwareupdate -l 2>&1 | grep "\*.*Command Line Tools" | tail -1 | sed 's/^[^C]* //')

    if [[ -n "$product_id" ]]; then
        print_info "Installing: $product_id"

        # Install the Command Line Tools
        if softwareupdate -i "$product_id" --verbose; then
            print_success "Xcode Command Line Tools installed successfully"

            # Clean up temporary file
            rm -f "$temp_file"

            # Verify installation
            if check_xcode_tools; then
                print_success "Installation verified successfully"
                return 0
            else
                print_error "Installation verification failed"
                return 1
            fi
        else
            print_error "Failed to install Xcode Command Line Tools"
            rm -f "$temp_file"
            return 1
        fi
    else
        print_error "Could not find Command Line Tools product identifier"
        rm -f "$temp_file"
        return 1
    fi
}

# Update Xcode Command Line Tools
update_xcode_tools() {
    print_section "Xcode Command Line Tools Update"

    print_info "Updating Xcode Command Line Tools..."

    if softwareupdate -i --all --include-config-data; then
        print_success "Xcode Command Line Tools updated successfully"
        return 0
    else
        print_warning "Failed to update Xcode Command Line Tools"
        return 1
    fi
}

# Accept Xcode license agreement
accept_xcode_license() {
    print_info "Accepting Xcode license agreement..."

    if xcodebuild -license accept 2>/dev/null; then
        print_success "Xcode license accepted"
        return 0
    else
        print_warning "Could not accept Xcode license (may already be accepted)"
        return 0
    fi
}

# Main developer tools setup function
setup_developer_tools() {
    print_section "Developer Tools Setup"

    # Check if tools are installed
    if check_xcode_tools; then
        print_info "Xcode Command Line Tools are already installed"

        # Check for updates
        if check_xcode_tools_updates; then
            print_info "No updates needed"
        else
            if ask_for_confirmation "Updates are available. Install them now?" "y"; then
                update_xcode_tools
            else
                print_info "Skipping updates"
            fi
        fi
    else
        print_info "Xcode Command Line Tools need to be installed"

        if ask_for_confirmation "Install Xcode Command Line Tools now?" "y"; then
            install_xcode_tools
        else
            print_error "Xcode Command Line Tools are required for development"
            print_info "You can install them manually later with: xcode-select --install"
            return 1
        fi
    fi

    # Accept license agreement
    accept_xcode_license

    # Verify final installation
    if check_xcode_tools; then
        print_success "Developer tools setup completed successfully"
        print_info "You can now use: git, gcc, make, and other development tools"
        return 0
    else
        print_error "Developer tools setup failed"
        return 1
    fi
}

# Main function
main() {
    setup_developer_tools
}

# Run main function
main "$@"
