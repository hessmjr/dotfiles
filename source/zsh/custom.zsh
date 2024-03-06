# Personal customizations

alias edit_zshrc="open -a TextEdit ~/.zshrc"
alias source_zsh="source ~/.zshrc"
export VISUAL="nano"
export EDITOR="nano"

# docker alias
alias dc="docker-compose"
alias dps="docker ps"

# kubernetes
alias k="kubectl"
alias kctx="kubectx"

# python
alias svenv="source venv/bin/activate"

# mongo db stuff
alias mongo_start="brew services start mongodb-community"
alias mongo_stop="brew services stop mongodb-community"
alias mongo_restart="brew services restart mongodb-community"

# asdf install
. "$HOME/.asdf/asdf.sh"
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

# Load rbenv automatically by appending
# the following to ~/.zshrc:

eval "$(rbenv init - zsh)"

# ensure terminal is running in arm64
if [[ $(arch) == "i386" ]];
then
  exec arch -arm64 $SHELL
fi

# VS CODE specific
if [[ $TERM_PROGRAM == "vscode" ]] && [[ $(arch) == "i386" ]];
then
  exec arch -arm64 $SHELL
fi

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# add Sublime Text to the path
# export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
