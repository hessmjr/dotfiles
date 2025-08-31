# Dotfiles

Personal dotfiles configuration for macOS.

## How to Setup

**Using cURL:**
```bash
curl -fsSL https://raw.githubusercontent.com/hessmjr/dotfiles/main/install.sh | bash
```

**Using Wget:**
```bash
wget -O - https://raw.githubusercontent.com/hessmjr/dotfiles/main/install.sh | bash
```

**Files present**
```bash
./install.sh
```

**Installation Features:**
- **Automatic detection** of existing configurations and applications
- **Timestamped backups** (e.g., `~/.dotfiles_backup/20241201_143022/`)
- **Preserves customizations** in organized backup directories
- **Easy restoration** of previous configurations
- **Progress tracking** throughout the entire setup process
- **User prompts** for control over each installation step

### Post-Install

After installation, you may need to:
- Restart your terminal for zsh configuration changes
- Restart Finder for file system preference changes
- Restart SystemUIServer for UI preference changes
- Add Homebrew to your shell profile if not already present

## Details

### Current Features

#### **Core System**
- **Zsh Configuration**: Custom shell setup with aliases, functions, and prompt
- **macOS Optimization**: Comprehensive system preferences and configurations
- **Safe Installation**: Automatic backup system with timestamped directories
- **Easy Updates**: Simple update process for seamless maintenance

#### **System Configuration**
- **macOS Preferences**: Automated system preference management
- **Developer Tools**: Essential development environment setup
- **Package Management**: Development toolchain installation and management

#### **Application Management**
- **Smart Installation**: Automated application installation from official sources
- **Progress Tracking**: Real-time installation progress and user control
- **Modular Design**: Easy customization and management of applications

#### **Development Environment**
- **Version Control**: Git and development workflow tools
- **Language Support**: Multi-language development environment
- **Cloud & DevOps**: Infrastructure and container management tools
- **Security Tools**: Development security and secrets management

#### **User Experience**
- **Interactive Control**: User prompts and confirmation throughout setup
- **Progress Visibility**: Clear feedback on installation progress
- **Error Handling**: Robust error handling and recovery
- **Automation Support**: Non-interactive mode for scripting and automation
