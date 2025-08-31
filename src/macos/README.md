# macOS System Preferences

This directory contains macOS-specific system preferences and configurations that enhance your system experience.

## What It Does

The macOS setup script automatically configures various system preferences to optimize your Mac experience:

### Dashboard
- Disables the Dashboard (removes the unused widget layer)

### Keyboard
- Enables full keyboard access for all controls
- Disables press-and-hold in favor of key repeat
- Sets optimal key repeat timing (delay: 10, rate: fast)
- Disables smart quotes and smart dashes

### Trackpad
- Enables tap-to-click functionality
- Configures two-finger right-click
- Optimizes trackpad behavior for productivity

### UI & UX
- Prevents .DS_Store file creation on network/USB volumes
- Sets crash reports to appear as notifications instead of prompts
- Disables shadows in screenshots
- Restarts system services to apply changes

## Installation

The macOS setup is automatically run when you execute the main install script. It will:

1. Verify you're running macOS 10.10 or later
2. Close System Preferences to avoid conflicts
3. Apply all the system preference changes
4. Restart necessary system services

## Manual Usage

You can also run the macOS setup independently:

```bash
# Run the complete macOS setup
./src/macos/setup.sh

# Check if macOS preferences need updating
./src/macos/setup.sh --check-only
```

## Requirements

- macOS 10.10 (Yosemite) or later
- Administrative privileges (for system preference changes)

## Safety

- All changes are made using standard macOS `defaults` commands
- System services are safely restarted to apply changes
- No system files are modified, only user preferences

## Customization

Feel free to modify the preferences in `setup.sh` to match your personal preferences. The script is designed to be easily customizable.
