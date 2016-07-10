# Added this line from bash profile
echo -n "Configuring bash..."

# Change home computer's user to my name
export USER="Mark"

# Turn off homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# Add prompt specification if file exists
if [ -f ~/.bash_prompt ]; then
    source ~/.bash_prompt
fi

# Add aliases if file exists
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# Inform user configuation complete
echo "complete."
