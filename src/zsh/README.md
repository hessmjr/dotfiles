# Zsh Configuration

This directory contains zsh configuration files that enhance your terminal experience on macOS. These files work best with Oh My Zsh and provide a solid foundation for shell customization.

## Prerequisites

### Oh My Zsh Installation

Before using these configuration files, ensure you have Oh My Zsh installed:

```bash
# Install Oh My Zsh (if not already installed)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

**Note**: If you already have Oh My Zsh installed, you can skip this step.

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

## Manual Setup Required

**Important**: After the files are installed, you need to manually add the following lines to your `~/.zshrc` file to source the custom configurations:

```bash
# Load custom configurations
source ~/.aliases.zsh
source ~/.exports.zsh
source ~/.functions.zsh
source ~/.prompt.zsh
```

### How to Add These Lines:

1. **Open your `.zshrc` file:**
   ```bash
   nano ~/.zshrc
   # or
   code ~/.zshrc
   ```

2. **Add the source lines at the end of the file**

3. **Save and reload:**
   ```bash
   source ~/.zshrc
   ```

## Usage

After manual setup, you can:
- Restart your terminal for changes to take effect
- Or run `source ~/.zshrc` to reload all configurations
- Customize any of these files to match your preferences

## Customization

Feel free to modify these files to add your own aliases, functions, and configurations. The install script will preserve your changes when you update the repository.

## Troubleshooting

- **Files not loading?** Check that the source lines are correctly added to `~/.zshrc`
- **Oh My Zsh conflicts?** Ensure the source lines are added after Oh My Zsh loads
- **Permission issues?** Verify the symbolic links are created correctly
