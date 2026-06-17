# set editors to Nano
export VISUAL="nano"
export EDITOR="nano"

# Turn off homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# asdf configuration
# Cache the asdf prefix once. This file is sourced from ~/.zshenv (every shell),
# so calling `brew --prefix asdf` here would fork brew on every startup. Hardcode
# the standard Homebrew symlink instead, with an Intel fallback.
ASDF_PREFIX="/opt/homebrew/opt/asdf"
[[ -d "$ASDF_PREFIX" ]] || ASDF_PREFIX="/usr/local/opt/asdf"

# Source asdf shell integration if present (older asdf versions)
if [[ -f "$ASDF_PREFIX/libexec/asdf.sh" ]]; then
    . "$ASDF_PREFIX/libexec/asdf.sh"
fi

export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"

# Add asdf shims to PATH. Guard against duplicates since .zshenv runs per shell.
if [[ ":$PATH:" != *":$ASDF_DATA_DIR/shims:"* ]]; then
    export PATH="$ASDF_DATA_DIR/shims:$PATH"
fi

# asdf completions (zsh-specific). fpath is set here (before .zshrc's compinit).
if [[ -d "$ASDF_PREFIX/share/zsh/site-functions" ]]; then
    fpath=($ASDF_PREFIX/share/zsh/site-functions $fpath)
fi
