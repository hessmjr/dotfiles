#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

AGENTS_SOURCE_DIR="$SCRIPT_DIR/agents"
AGENTS_TARGET_DIR="$HOME/.agents"
AGENTS_INSTRUCTIONS_TEMPLATE="$AGENTS_SOURCE_DIR/instructions.example.md"
AGENTS_SKILLS_SOURCE="$AGENTS_SOURCE_DIR/skills"
AGENTS_SKILLS_DIR="$AGENTS_TARGET_DIR/skills"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
CLAUDE_ENV_PATH="$AGENTS_TARGET_DIR/env.zsh"

# Tool directories that become symlinks to the shared skills directory.
SKILL_LINK_TARGETS=(
    "$HOME/.claude/skills|claude-skills"
    "$HOME/.codex/skills|codex-skills"
    "$HOME/.cursor/skills|cursor-skills"
)

backup_dir=""
migrate_skills_opt_in=false

ensure_backup_dir() {
    if [[ -z "$backup_dir" ]]; then
        backup_dir="$HOME/.dotfiles_backup/$(date +"%Y%m%d_%H%M%S")/agents"
        mkdir -p "$backup_dir"
        print_info "Backup directory: $backup_dir"
    fi
}

backup_target() {
    local target="$1"
    local backup_name="$2"

    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        ensure_backup_dir
        mv "$target" "$backup_dir/$backup_name"
        print_warning "Backed up $target"
    fi
}

ensure_link() {
    local source="$1"
    local target="$2"
    local backup_name="$3"

    if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
        print_info "$target is already linked correctly"
        return 0
    fi

    mkdir -p "$(dirname "$target")"
    backup_target "$target" "$backup_name"
    ln -s "$source" "$target"
    print_success "Linked $target → $source"
}

ensure_local_instructions() {
    local target="$AGENTS_TARGET_DIR/instructions.md"

    mkdir -p "$AGENTS_TARGET_DIR"

    if [[ -f "$target" ]] && [[ ! -L "$target" ]]; then
        print_info "$target is local and will not be overwritten"
        return 0
    fi

    # Migrate an older readable symlink to a machine-local regular file.
    if [[ -L "$target" ]] && [[ -r "$target" ]]; then
        local preserved="$AGENTS_TARGET_DIR/.instructions.md.migrate.$$"
        cp -p "$target" "$preserved"
        backup_target "$target" "instructions.md"
        mv "$preserved" "$target"
        print_success "Migrated $target to a machine-local file"
        return 0
    fi

    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        backup_target "$target" "instructions.md"
    fi

    cp "$AGENTS_INSTRUCTIONS_TEMPLATE" "$target"
    print_success "Created machine-local $target from the example"
}

# Tracked skills are linked in. Everything else there is machine-local.
link_repo_skills() {
    local entry name

    for entry in "$AGENTS_SKILLS_SOURCE"/*; do
        [[ -e "$entry" ]] || continue
        name="$(basename "$entry")"
        ensure_link "$entry" "$AGENTS_SKILLS_DIR/$name" "skills-$name"
    done
}

ensure_skills_dir() {
    mkdir -p "$AGENTS_SKILLS_DIR"
    link_repo_skills
}

# Skills that would move out of a tool directory. The glob skips hidden
# entries, so tool-owned content like Codex's .system/ stays put.
list_movable_skills() {
    local source_dir="$1"
    local entry

    if [[ ! -d "$source_dir" ]] || [[ -L "$source_dir" ]]; then
        return 0
    fi

    for entry in "$source_dir"/*; do
        [[ -e "$entry" ]] || continue
        basename "$entry"
    done
}

# Moving skills is opt-in. Nothing to move means no prompt.
confirm_skills_migration() {
    local target="$1"
    local skills name

    skills="$(list_movable_skills "$target")"
    if [[ -z "$skills" ]]; then
        return 0
    fi

    print_warning "$target already contains skills:"
    while IFS= read -r name; do
        print_info "  - $name"
    done <<< "$skills"
    print_info "Moving them into $AGENTS_SKILLS_DIR shares them with every linked tool."
    print_info "Declining leaves $target untouched."

    if [[ "$migrate_skills_opt_in" == true ]]; then
        print_info "Moving them because --migrate-skills was given"
        return 0
    fi

    ask_for_confirmation "Move these skills and link $target?" "n"
}

migrate_skills() {
    local source_dir="$1"
    local name target

    while IFS= read -r name; do
        [[ -n "$name" ]] || continue
        target="$AGENTS_SKILLS_DIR/$name"

        if [[ -e "$target" ]]; then
            print_info "$name already exists in $AGENTS_SKILLS_DIR; keeping it"
            continue
        fi

        cp -R "$source_dir/$name" "$target"
        print_success "Migrated $name into $AGENTS_SKILLS_DIR"
    done <<< "$(list_movable_skills "$source_dir")"
}

setup_skills() {
    ensure_skills_dir

    local entry target backup_name
    for entry in "${SKILL_LINK_TARGETS[@]}"; do
        target="${entry%%|*}"
        backup_name="${entry#*|}"

        if ! confirm_skills_migration "$target"; then
            print_info "Skipping $target"
            continue
        fi

        migrate_skills "$target"
        ensure_link "$AGENTS_SKILLS_DIR" "$target" "$backup_name"
    done
}

claude_env_value() {
    if [[ -f "$CLAUDE_SETTINGS" ]]; then
        /usr/bin/plutil -extract env.CLAUDE_ENV_FILE raw "$CLAUDE_SETTINGS" 2>/dev/null || true
    fi
}

check_agents_status() {
    local needs_update=false

    local links=(
        "$AGENTS_SOURCE_DIR/env.zsh|$AGENTS_TARGET_DIR/env.zsh"
        "$AGENTS_TARGET_DIR/instructions.md|$HOME/.codex/AGENTS.md"
        "$AGENTS_TARGET_DIR/instructions.md|$HOME/.claude/CLAUDE.md"
    )

    local entry source target name
    for entry in "$AGENTS_SKILLS_SOURCE"/*; do
        [[ -e "$entry" ]] || continue
        name="$(basename "$entry")"
        links+=("$entry|$AGENTS_SKILLS_DIR/$name")
    done

    for entry in "${SKILL_LINK_TARGETS[@]}"; do
        links+=("$AGENTS_SKILLS_DIR|${entry%%|*}")
    done

    for entry in "${links[@]}"; do
        source="${entry%%|*}"
        target="${entry#*|}"
        if [[ ! -L "$target" ]] || [[ "$(readlink "$target" 2>/dev/null)" != "$source" ]]; then
            print_info "$target needs to be linked"
            needs_update=true
        fi
    done

    if [[ ! -f "$AGENTS_TARGET_DIR/instructions.md" ]] || [[ -L "$AGENTS_TARGET_DIR/instructions.md" ]]; then
        print_info "$AGENTS_TARGET_DIR/instructions.md needs to be machine-local"
        needs_update=true
    fi

    if [[ "$(claude_env_value)" != "$CLAUDE_ENV_PATH" ]]; then
        print_info "Claude Code needs CLAUDE_ENV_FILE configured"
        needs_update=true
    fi

    if [[ "$needs_update" == true ]]; then
        return 1
    fi

    print_success "AI agent configuration is up to date!"
    return 0
}

configure_claude_env() {
    local current_value
    current_value="$(claude_env_value)"

    if [[ "$current_value" == "$CLAUDE_ENV_PATH" ]]; then
        print_info "Claude Code already uses $CLAUDE_ENV_PATH"
        return 0
    fi

    mkdir -p "$(dirname "$CLAUDE_SETTINGS")"

    local settings_json=""
    if [[ -f "$CLAUDE_SETTINGS" ]]; then
        # plutil -lint rejects JSON on some releases. Converting validates it
        # and gives back the normalized contents.
        if ! settings_json="$(/usr/bin/plutil -convert json -o - "$CLAUDE_SETTINGS" 2>/dev/null)"; then
            print_error "Claude settings are not valid JSON: $CLAUDE_SETTINGS"
            return 1
        fi

        if [[ "$settings_json" != "{"* ]]; then
            print_error "Claude settings are not a JSON object: $CLAUDE_SETTINGS"
            return 1
        fi

        ensure_backup_dir
        cp -p "$CLAUDE_SETTINGS" "$backup_dir/claude-settings.json"
        print_warning "Backed up $CLAUDE_SETTINGS"
    fi

    # plutil cannot rewrite a file that is an empty dictionary: it detects no
    # format and fails. Nothing to keep in one, so write the env dict directly.
    if [[ ! -f "$CLAUDE_SETTINGS" ]] || [[ "$settings_json" == "{}" ]]; then
        printf '{"env":{}}\n' > "$CLAUDE_SETTINGS"
    fi

    local env_type
    env_type="$(/usr/bin/plutil -type env "$CLAUDE_SETTINGS" 2>/dev/null || true)"
    if [[ -z "$env_type" ]]; then
        /usr/bin/plutil -insert env -json '{}' "$CLAUDE_SETTINGS"
    elif [[ "$env_type" != "dictionary" ]]; then
        print_error "The env value in $CLAUDE_SETTINGS is not a dictionary"
        return 1
    fi

    if /usr/bin/plutil -extract env.CLAUDE_ENV_FILE raw "$CLAUDE_SETTINGS" >/dev/null 2>&1; then
        /usr/bin/plutil -replace env.CLAUDE_ENV_FILE -string "$CLAUDE_ENV_PATH" "$CLAUDE_SETTINGS"
    else
        /usr/bin/plutil -insert env.CLAUDE_ENV_FILE -string "$CLAUDE_ENV_PATH" "$CLAUDE_SETTINGS"
    fi

    print_success "Configured Claude Code to use $CLAUDE_ENV_PATH"
}

setup_agents() {
    ensure_link "$AGENTS_SOURCE_DIR/env.zsh" "$AGENTS_TARGET_DIR/env.zsh" "env.zsh"
    ensure_local_instructions
    ensure_link "$AGENTS_TARGET_DIR/instructions.md" "$HOME/.codex/AGENTS.md" "codex-AGENTS.md"
    ensure_link "$AGENTS_TARGET_DIR/instructions.md" "$HOME/.claude/CLAUDE.md" "claude-CLAUDE.md"
    setup_skills
    configure_claude_env
}

main() {
    local check_only=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --check-only) check_only=true ;;
            --migrate-skills) migrate_skills_opt_in=true ;;
            *)
                print_error "Usage: $0 [--check-only] [--migrate-skills]"
                exit 1
                ;;
        esac
        shift
    done

    print_info "Checking AI agent configuration..."
    if check_agents_status; then
        exit 0
    fi

    if [[ "$check_only" == true ]]; then
        exit 1
    fi

    setup_agents
    print_success "AI agent configuration setup complete!"
    print_info "Restart Claude Code for CLAUDE_ENV_FILE to take effect"
}

main "$@"
