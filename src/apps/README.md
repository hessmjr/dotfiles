# Applications Setup

This directory contains the applications setup system that installs all necessary applications for every computer.

## What It Installs

The apps setup script automatically installs the following applications directly from their official sources:

### Development Tools
- **Visual Studio Code** - Code editor
- **Cursor** - AI-powered code editor
- **Sublime Text** - Fast text editor
- **Git Tower** - Git GUI client
- **iTerm2** - Terminal emulator

### Productivity
- **Standard Notes** - Secure note-taking
- **1Password** - Password manager
- **Tiles** - Window management

### Development & Tools
- **Docker** - Containerization platform

### Browsers
- **Firefox** - Web browser
- **Google Chrome** - Web browser

## Features

- **Smart Detection**: Checks if applications are already installed before downloading
- **Direct Downloads**: Downloads latest versions directly from official sources
- **Batch Installation**: Installs all applications in one command
- **Error Handling**: Continues installation even if individual apps fail
- **Status Checking**: Can check what's installed without making changes
- **Automatic Cleanup**: Removes temporary files after installation

## How It Works

The main setup script (`main.sh`) dynamically discovers all `.sh` files in the `installers/` directory and runs them automatically. This means:

- **Add new apps**: Simply create a new `.sh` script in the `installers/` directory
- **Remove apps**: Delete the corresponding `.sh` script
- **Modify apps**: Edit the individual script without touching the main system
- **Reorganize**: Move scripts around without breaking the main setup

## Installation

The apps setup is automatically run when you execute the main install script. It will:

1. Verify you're running macOS
2. Check which applications are already installed
3. Download and install missing applications from official sources
4. Provide status updates throughout the process

## Manual Usage

You can also run the apps setup independently:

```bash
# Run the complete apps setup
./src/apps/main.sh

# Check what applications are installed
./src/apps/main.sh --check-only
```

## Requirements

- macOS (required for applications)
- Internet connection for downloading applications
- Administrative privileges for application installation

## File Structure

```
src/apps/
├── main.sh              # Main orchestrator script
├── README.md            # This documentation
└── installers/          # Individual app installer scripts
    ├── vscode.sh        # Visual Studio Code
    ├── cursor.sh        # Cursor editor
    ├── sublime_text.sh  # Sublime Text
    ├── git_tower.sh     # Git Tower
    ├── 1password.sh     # 1Password
    ├── docker.sh        # Docker Desktop
    ├── firefox.sh       # Firefox browser
    ├── tiles.sh         # Tiles window manager
    ├── google_chrome.sh # Google Chrome
    ├── standard_notes.sh # Standard Notes
    └── iterm2.sh        # iTerm2 terminal
```

## Standard Script Pattern

Each installer script follows this structure:

```bash
#!/bin/bash

# App Name Setup Script
# Brief description

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Download and install app
install_app() {
    print_section "App Name"

    local app_path="/Applications/AppName.app"
    if is_app_installed "$app_path"; then
        print_success "App Name is already installed, skipping..."
        return 0
    fi

    print_info "Downloading App Name..."

    # Create temporary directory
    local temp_dir=$(create_temp_dir)
    cd "$temp_dir"

    # Download and install logic here
    # Use shared utility functions for common operations

    # Clean up
    cleanup_temp_dir "$temp_dir"
}

# Main function
main() {
    install_app
}

# Run main function
main "$@"
```

## Shared Utilities

All installer scripts automatically have access to shared utilities from `src/utils.sh`:

### **Print Functions:**
- `print_info()`, `print_success()`, `print_section()`, `print_warning()`, `print_error()`

### **Common Operations:**
- `create_temp_dir()` - Creates and returns temporary directory path
- `cleanup_temp_dir()` - Safely removes temporary directory
- `download_file()` - Downloads file with error handling
- `extract_zip()` - Extracts ZIP files with error handling
- `mount_dmg()` - Mounts DMG files and returns mount point
- `unmount_dmg()` - Safely unmounts DMG files
- `install_app_to_applications()` - Copies app to Applications directory
- `is_app_installed()` - Checks if app is already installed

## Adding New Apps

1. Create a new `.sh` script in the `installers/` directory
2. Follow the standard pattern above
3. Make it executable: `chmod +x newapp.sh`
4. The main setup will automatically discover and run it

## Removing Apps

1. Delete the corresponding `.sh` script from the `installers/` directory
2. The main setup will no longer install that app
3. No other changes needed

## Modifying Apps

1. Edit the individual script directly in the `installers/` directory
2. Changes take effect immediately
3. No need to modify the main setup script

## Benefits

- **Modular**: Each app is completely independent
- **Maintainable**: Easy to manage individual apps
- **Extensible**: Simple to add new apps
- **Clean**: No hardcoded app lists in main script
- **Flexible**: Can easily reorganize or customize
- **Latest Versions**: Always downloads the most recent versions from official sources

## Notes

- Some applications may require manual setup after installation
- Docker may require additional configuration for your use case
- 1Password may require account setup and login
- Applications are downloaded directly from official sources for the latest versions
