# set editors to Nano
export VISUAL="nano"
export EDITOR="nano"

# Turn off homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# asdf configuration
# Cache the asdf prefix once. Calling `brew --prefix asdf` here would fork brew
# on every interactive and agent shell startup, so use the standard Homebrew
# symlink with an Intel fallback.
ASDF_PREFIX="/opt/homebrew/opt/asdf"
[[ -d "$ASDF_PREFIX" ]] || ASDF_PREFIX="/usr/local/opt/asdf"

# Source asdf shell integration if present (older asdf versions)
if [[ -f "$ASDF_PREFIX/libexec/asdf.sh" ]]; then
    . "$ASDF_PREFIX/libexec/asdf.sh"
fi

export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"

# Keep asdf shims ahead of system runtimes. Remove only duplicate shim entries;
# preserve the ordering of every other PATH entry.
path=(${path:#"$ASDF_DATA_DIR/shims"})
path=("$ASDF_DATA_DIR/shims" $path)
export PATH

# asdf completions (zsh-specific). fpath is set here (before .zshrc's compinit).
if [[ -d "$ASDF_PREFIX/share/zsh/site-functions" ]]; then
    fpath=($ASDF_PREFIX/share/zsh/site-functions $fpath)
fi
