# COMMON ALIASES NEEDED

# shorten changing moving up directories commands
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cd..="cd .."

# quick open
alias open="open ."

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # OS X `ls`
	colorflag="-G"
fi

# List files colorized
alias l="ls -x ${colorflag}"

# List most files in color
alias la="ls -A ${colorflag}"

# List all files colorized, including dot files
alias lsa="ls -ah ${colorflag}"

# List non-hidden files colorized in long format, including dot files convert sizes to human readable
alias ll="ls -lh ${colorflag}"

# List all files colorized in long format, including dot files convert sizes to human readable
alias lla="ls -alh ${colorflag}"

# List only directories
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

# Always use color output for `ls`
alias ls="command ls ${colorflag}"

# Always enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
