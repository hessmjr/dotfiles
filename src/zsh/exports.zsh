# set editors to Nano
export VISUAL="nano"
export EDITOR="nano"

# Turn off homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# asdf configuration
if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    . "$HOME/.asdf/asdf.sh"
fi

# asdf completions
if [[ -f "$HOME/.asdf/completions/asdf.bash" ]]; then
    . "$HOME/.asdf/completions/asdf.bash"
fi
