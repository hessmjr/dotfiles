# Zsh Configuration

This directory contains zsh configuration files that enhance your terminal experience on macOS.

## Configuration Files

- **`aliases.zsh`**: Custom command aliases for common tasks
- **`exports.zsh`**: Environment variables and exports
- **`functions.zsh`**: Custom shell functions
- **`prompt.zsh`**: Custom zsh prompt configuration

## Installation

These files are automatically installed when you run the main install script. They create symbolic links in your home directory:

- `~/.aliases.zsh` → `src/zsh/aliases.zsh`
- `~/.exports.zsh` → `src/zsh/exports.zsh`
- `~/.functions.zsh` → `src/zsh/functions.zsh`
- `~/.prompt.zsh` → `src/zsh/prompt.zsh`

## Usage

After installation, you can:
- Restart your terminal for changes to take effect
- Or run `source ~/.aliases.zsh` (and other files) to reload specific configurations
- Customize any of these files to match your preferences

## Customization

Feel free to modify these files to add your own aliases, functions, and configurations. The install script will preserve your changes when you update the repository.
