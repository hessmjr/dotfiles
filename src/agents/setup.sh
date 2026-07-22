#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

AGENTS_SOURCE_DIR="$SCRIPT_DIR/agents"
AGENTS_TARGET_DIR="$HOME/.agents"
AGENTS_INSTRUCTIONS_TEMPLATE="$AGENTS_SOURCE_DIR/instructions.example.md"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
CLAUDE_ENV_PATH="$AGENTS_TARGET_DIR/env.zsh"

backup_dir=""

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

    local entry source target
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

    if [[ -f "$CLAUDE_SETTINGS" ]]; then
        # macOS plutil can edit JSON but its lint mode only accepts plist
        # formats on some releases. A no-output JSON conversion validates both.
        if ! /usr/bin/plutil -convert json -o /dev/null "$CLAUDE_SETTINGS" >/dev/null 2>&1; then
            print_error "Claude settings are not valid JSON: $CLAUDE_SETTINGS"
            return 1
        fi
        ensure_backup_dir
        cp -p "$CLAUDE_SETTINGS" "$backup_dir/claude-settings.json"
        print_warning "Backed up $CLAUDE_SETTINGS"
    else
        printf '{}\n' > "$CLAUDE_SETTINGS"
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
    configure_claude_env
}

main() {
    local check_only=false

    if [[ "${1:-}" == "--check-only" ]]; then
        check_only=true
    elif [[ $# -gt 0 ]]; then
        print_error "Usage: $0 [--check-only]"
        exit 1
    fi

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
