# AI Agent Configuration

This component installs shared instructions and a non-interactive shell
environment for local AI coding agents.

## Installed files

- `~/.agents/instructions.md` → machine-local rules for AI agents
- `~/.agents/env.zsh` → shell configuration used by Claude Code commands
- `~/.codex/AGENTS.md` → shared instructions
- `~/.claude/CLAUDE.md` → shared instructions
- `~/.agents/skills/` → shared agent skills
- `~/.claude/skills`, `~/.codex/skills`, `~/.cursor/skills` → shared skills

The setup also adds this value to `~/.claude/settings.json` while preserving
all other Claude settings:

```json
{
  "env": {
    "CLAUDE_ENV_FILE": "/Users/mark.hess/.agents/env.zsh"
  }
}
```

Claude Code sources `CLAUDE_ENV_FILE` before every Bash-tool command. Codex
already loads the interactive Zsh configuration and only uses the shared
instructions file.

## Machine-local instructions

The repository tracks only `instructions.example.md`. On first setup it is
copied to `~/.agents/instructions.md`; subsequent runs never overwrite that
local file. Customize it independently on each computer. Codex and Claude link
their global instruction entry points to the local file.

## Shared skills

Agent Skills live in `~/.agents/skills`, and each tool's skills directory is a
symlink to it, so one skill is picked up by Claude Code, Codex, and Cursor
alike. Only `skills/README.md` is tracked; the skills themselves are
machine-local, like `instructions.md`.

Moving existing skills is opt-in. A tool directory that is missing or empty is
linked without asking, but one that already holds skills is listed and
confirmed first, and declining leaves that directory untouched.

Directories that a tool manages itself are left alone: Codex keeps built-ins in
`.system/` and Cursor keeps its own in `~/.cursor/skills-cursor/`. Claude
Desktop is not linked, because it syncs skills from your Claude account instead
of reading `~/.claude/skills`.

## Agent shell environment

`env.zsh` loads the command-useful files from the Zsh configuration:

- `exports.zsh` for environment variables, PATH, and asdf
- `aliases.zsh` for command aliases
- `functions.zsh` for reusable shell functions
- `private.zsh` for private environment variables and commands

It intentionally skips `prompt.zsh`, Oh My Zsh initialization, and completion
scripts because those are interactive terminal features.

## Setup

The main dotfiles installer offers this component automatically. It can also be
run independently:

```bash
./src/agents/setup.sh
```

Conflicting files and Claude settings are backed up under
`~/.dotfiles_backup/<timestamp>/agents/` before replacement.
