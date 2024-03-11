# COMMON ALIASES NEEDED

# I like quick access to my .zshrc file
alias edit_zshrc="open -a TextEdit ~/.zshrc"
alias source_zsh="source ~/.zshrc"

# docker alias
alias dc="docker-compose"
alias dps="docker ps"

# kubernetes
alias k="kubectl"
alias kctx="kubectx"

# python source fast
alias svenv="source venv/bin/activate"

# Get IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' \
                | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
