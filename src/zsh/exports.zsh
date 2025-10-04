# set editors to Nano
export VISUAL="nano"
export EDITOR="nano"

# Turn off homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# asdf configuration (Homebrew installation)
if command -v brew >/dev/null 2>&1 && [[ -f "$(brew --prefix asdf)/libexec/asdf.sh" ]]; then
    . "$(brew --prefix asdf)/libexec/asdf.sh"
fi

# asdf completions (zsh-specific)
if command -v brew >/dev/null 2>&1 && [[ -d "$(brew --prefix asdf)/share/zsh/site-functions" ]]; then
    fpath=($(brew --prefix asdf)/share/zsh/site-functions $fpath)
fi
