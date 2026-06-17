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
- **`prompt.zsh`**: Oh My Zsh theme customizations and overrides
- **`private.zsh`**: Template for personal secrets, API keys, and sensitive configurations

## Installation

These files are installed automatically when you run the setup script. It:

1. Creates a `~/.zsh/` directory and symlinks each config file into it:
   - `~/.zsh/aliases.zsh` → `src/zsh/aliases.zsh`
   - `~/.zsh/exports.zsh` → `src/zsh/exports.zsh`
   - `~/.zsh/functions.zsh` → `src/zsh/functions.zsh`
   - `~/.zsh/prompt.zsh` → `src/zsh/prompt.zsh`
   - creates `~/.zsh/private.zsh` (template, not tracked in git)
2. Wires the sourcing automatically (no manual editing required) by appending
   managed blocks to `~/.zshenv` and `~/.zshrc`.

### Where each file is sourced (env vs rc)

Sourcing is split by **shell type**, not lumped into `.zshrc`:

| File | Sourced from | Why |
|------|--------------|-----|
| `exports.zsh` | `~/.zshenv` | Environment vars + `PATH` + asdf. `.zshenv` loads for **every** shell — interactive, scripts, cron, `ssh host cmd` — so these are always available. |
| `aliases.zsh` | `~/.zshrc` | Interactive-only convenience. |
| `functions.zsh` | `~/.zshrc` | Interactive-only convenience. |
| `prompt.zsh` | `~/.zshrc` | Needs `$PROMPT` from Oh My Zsh, so it must load **after** Oh My Zsh. |
| `private.zsh` | `~/.zshrc` | Secrets/aliases for interactive use. |

The `.zshrc` block is appended to the **end** of the file so it runs after
`source $ZSH/oh-my-zsh.sh`. The blocks are idempotent — re-running setup detects
the markers (`# >>> dotfiles ... >>>`) and won't add duplicates.

> **Note:** `exports.zsh` is sourced on every shell, so it must never print to
> stdout (that would corrupt `scp`/`rsync`/`ssh host cmd`). It uses a hardcoded
> asdf prefix and a `PATH` de-dupe guard to stay fast and side-effect-free.

## Usage

After manual setup, you can:
- Restart your terminal for changes to take effect
- Or run `source ~/.zshrc` to reload all configurations
- Customize any of these files to match your preferences
- Change Oh My Zsh themes by editing `~/.zsh/prompt.zsh`

## Customization

- **Aliases & Functions**: Modify `aliases.zsh` and `functions.zsh` to add your own shortcuts
- **Environment Variables**: Add custom exports in `exports.zsh`
- **Prompt Themes**: Change Oh My Zsh themes by uncommenting and modifying the `ZSH_THEME` line in `prompt.zsh`
- **Private Configuration**: Use `private.zsh` for sensitive data like API keys, passwords, and personal secrets. This file is created as a template during setup and is not tracked in git, making it safe for storing confidential information. You can edit it using the `edit_zsh_private` alias.

## Troubleshooting

- **Files not loading?** Confirm the managed blocks exist — `grep dotfiles ~/.zshenv ~/.zshrc` — and re-run setup if missing
- **Env vars missing in scripts/cron?** Those come from `~/.zshenv` (`exports.zsh`); make sure that block is present
- **Oh My Zsh conflicts?** The `.zshrc` block is appended after `source $ZSH/oh-my-zsh.sh`; don't move it above that line
- **Permission issues?** Verify the symbolic links are created correctly in the `~/.zsh/` directory
- **Prompt not working?** Make sure Oh My Zsh is installed and the theme is set in `prompt.zsh`
- **Private file not loading?** Ensure `~/.zsh/private.zsh` exists and contains your personal configurations
