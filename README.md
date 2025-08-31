# Dotfiles

Personal dotfiles configuration for macOS, featuring zsh customization and shell utilities.

## Introduction

This repository contains my personal dotfiles configuration for macOS. It includes zsh aliases, functions, exports, and prompt customization to enhance the terminal experience and productivity.

## How to Setup

### Quick Install

**Using cURL:**
```bash
curl -fsSL https://raw.githubusercontent.com/hessmjr/dotfiles/main/install.sh | bash
```

**Using Wget:**
```bash
wget -O - https://raw.githubusercontent.com/hessmjr/dotfiles/main/install.sh | bash
```

The install script will:
- Verify you're running macOS
- Create symbolic links for all configuration files
- Back up any existing dotfiles to `~/.dotfiles_backup/`
- Set up your zsh configuration

### Post-Install

After installation, you may need to:
- Restart your terminal
- Or run `source ~/.zshrc` to reload the configuration

## Details

### Current Features

- **Zsh Configuration**: Custom aliases, functions, exports, and prompt
- **macOS Optimized**: Tailored specifically for macOS systems
- **Safe Installation**: Automatic backup of existing dotfiles
- **Easy Updates**: Simple git pull and re-run install script

*This section will expand as we add more features and configurations to the repository.*
