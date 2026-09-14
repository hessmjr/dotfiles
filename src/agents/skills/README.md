# Agent Skills

Skills live in `~/.agents/skills`. Each tool reads it through a symlink, so a
skill is written once.

- `~/.claude/skills` → Claude Code
- `~/.codex/skills` → Codex
- `~/.cursor/skills` → Cursor

A skill is a directory with a `SKILL.md`:

```markdown
---
name: my-skill
description: When to use this skill.
---

Instructions for the agent.
```

## Tracked vs local

Skills in `src/agents/skills/` are symlinked in and follow the dotfiles to
every machine. Skills made directly in `~/.agents/skills` stay on that
machine. To share a local one, move it into `src/agents/skills/` and commit.

## Setup

Setup never moves existing skills on its own. An empty tool directory is
linked right away; one with skills is listed and confirmed first. Pass
`--migrate-skills` to skip the prompt.

Tool-owned skills are left alone: Codex's `.system/` and
`~/.cursor/skills-cursor/`. Claude Desktop is not linked; it syncs skills from
your account.
