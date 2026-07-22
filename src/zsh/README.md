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
   a managed block to `~/.zshrc`.

### Where each file is sourced

All files load interactively from **`~/.zshrc`**. Command-useful files also
load from `~/.agents/env.zsh` for configured AI agents. Nothing is loaded from
`.zshenv` or `.zprofile`:

| File | Sourced from | Why |
|------|--------------|-----|
| `exports.zsh` | `~/.zshrc`, `~/.agents/env.zsh` | Environment vars + `PATH` + asdf. |
| `aliases.zsh` | `~/.zshrc`, `~/.agents/env.zsh` | Command aliases. |
| `functions.zsh` | `~/.zshrc`, `~/.agents/env.zsh` | Reusable shell functions. |
| `prompt.zsh` | `~/.zshrc` | Needs `$PROMPT` from Oh My Zsh, so it must load **after** Oh My Zsh. |
| `private.zsh` | `~/.zshrc`, `~/.agents/env.zsh` | Private environment and commands. |

The block is appended to the **end** of `~/.zshrc` so it runs after
`source $ZSH/oh-my-zsh.sh`. It's idempotent — re-running setup detects
the marker (`# >>> dotfiles (interactive) >>>`) and won't add duplicates.

> **Note:** Cron jobs, scripts, and `ssh host cmd` remain unaffected. If those
> contexts need `PATH`/asdf, source `~/.zsh/exports.zsh` directly.

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

- **Files not loading?** Confirm the managed block exists — `grep dotfiles ~/.zshrc` — and re-run setup if missing
- **Env vars missing in scripts/cron?** Expected — source `~/.zsh/exports.zsh` explicitly if a script needs it. AI agent shells are configured separately by `src/agents/setup.sh`.
- **Oh My Zsh conflicts?** The `.zshrc` block is appended after `source $ZSH/oh-my-zsh.sh`; don't move it above that line
- **Permission issues?** Verify the symbolic links are created correctly in the `~/.zsh/` directory
- **Prompt not working?** Make sure Oh My Zsh is installed and the theme is set in `prompt.zsh`
- **Private file not loading?** Ensure `~/.zsh/private.zsh` exists and contains your personal configurations
