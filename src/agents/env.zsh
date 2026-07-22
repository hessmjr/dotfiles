# Shared shell environment for AI agents.
# Load command-useful configuration without interactive prompts or completions.

if [[ -z "${MARKHESS_AGENT_ENV_LOADED:-}" ]]; then
    MARKHESS_AGENT_ENV_LOADED=1

    [ -f "$HOME/.zsh/exports.zsh" ]   && source "$HOME/.zsh/exports.zsh"
    [ -f "$HOME/.zsh/aliases.zsh" ]   && source "$HOME/.zsh/aliases.zsh"
    [ -f "$HOME/.zsh/functions.zsh" ] && source "$HOME/.zsh/functions.zsh"
    [ -f "$HOME/.zsh/private.zsh" ]   && source "$HOME/.zsh/private.zsh"
fi
