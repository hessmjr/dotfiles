# Agent Skills

Shared [Agent Skills](https://code.claude.com/docs/en/skills) for local AI
coding agents. `~/.agents/skills` is the single source of truth; every tool
reads it through a symlink, so a skill written once is available everywhere.

## Layout

```
~/.agents/skills/
├── README.md          → symlink into the repository
├── hess-do-better/    → symlink into the repository
└── <skill-name>/      machine-local skill, not tracked
    └── SKILL.md
```

A skill tracked in this repository is symlinked into the shared directory, the
same way `env.zsh` is, so committing one carries it to every machine. A skill
created directly in `~/.agents/skills` is a plain directory and stays on the
machine that made it. Promote a local skill by moving it into
`src/agents/skills/` and committing; setup replaces the copy with a symlink.

Each skill is a directory containing a `SKILL.md` with YAML frontmatter:

```markdown
---
name: my-skill
description: One line telling the agent when to use this skill.
---

Instructions for the agent.
```

The `description` is what the agent matches against, so describe the trigger,
not just the behavior.

## Linked tools

- `~/.claude/skills` → Claude Code
- `~/.codex/skills` → Codex
- `~/.cursor/skills` → Cursor

Tool-managed skill directories are left alone: Codex writes its own built-ins
to `.system/` and Cursor keeps its own in `~/.cursor/skills-cursor/`. Neither
is tracked here.

Claude Desktop is not linked. It syncs skills from your Claude account into
`~/Library/Application Support/Claude/`, which is managed by the app rather
than by dotfiles, so a skill needed there has to be added through the account.

## Machine-local skills

Setup never moves existing skills on its own. A tool directory that is missing
or empty is linked straight away; one that already holds skills is listed and
confirmed first, and declining leaves it untouched. Hidden entries such as
Codex's `.system/` are never moved.
