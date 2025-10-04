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
- Shows hidden files in Finder
- Shows file extensions in Finder
- Shows path bar and status bar in Finder
- Restarts system services to apply changes

### System Updates
- Disables automatic system updates and downloads
- Disables automatic app updates from the App Store
- Disables automatic security updates and XProtect updates
- Disables automatic Gatekeeper certificate updates
- Disables automatic Time Machine backups
- Disables automatic Spotlight indexing updates
- Disables automatic font validation
- Disables automatic language model updates
- Disables automatic Siri suggestions
- Disables automatic Handoff and Continuity features

### Developer Tools
- Ensures Xcode Command Line Tools are installed
- Checks for and installs updates to Command Line Tools
- Automatically accepts Xcode license agreement
- Provides essential development tools (git, gcc, make, etc.)
- Verifies installation and functionality

### Homebrew Development Environment
- Installs and configures Homebrew package manager
- Installs essential development packages:
  - **git** - Version control system
  - **awscli** - AWS command line interface
  - **kubectx** - Kubernetes context switcher
  - **kubernetes-cli** - Kubernetes command line tools
  - **sops** - Secrets management
  - **terraform** - Infrastructure as code
- Updates and upgrades existing packages
- Configures Homebrew analytics and completions
- Verifies all package installations

### asdf Version Manager
- Installs asdf via Homebrew
- Adds common plugins (nodejs, python, ruby, golang)
- Prompts to install latest versions of Node.js, Python, and Ruby
- Configures shell integration for immediate use

### Favorites Folder
- Creates a `favorites` folder in your home directory
- Adds symbolic links (aliases) to frequently accessed directories:
  - **Documents** - Quick access to your Documents folder
  - **Desktop** - Quick access to your Desktop folder
  - **zsh** - Quick access to your zsh configuration directory
- Automatically adds the favorites folder to your dock for easy access
- The aliases appear as normal folders without "alias" in their names

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
- System update preferences require administrative privileges

## Important Notes

### System Updates
The system updates script disables many automatic update mechanisms. This gives you full control over when updates happen, but also means you'll need to manually check for and install important updates, especially security patches.

**To manually check for updates:**
- Go to System Preferences > Software Update
- Or use the command line: `softwareupdate -l`

**To manually install updates:**
- Use System Preferences > Software Update
- Or use the command line: `softwareupdate -i -a`

## Customization

Feel free to modify the preferences in `setup.sh` to match your personal preferences. The script is designed to be easily customizable.
