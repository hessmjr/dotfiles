# Execute first


# First test which OS is running
[[ "$OSTYPE" =~ ^darwin ]] || return 1
[[ "$(cat /etc/issue 2> /dev/null)" =~ Ubuntu ]] || return 1

# based on OS run start script for that OS
# once startup script completes and everything installed remove all unnecessary files
# possibly create status bar?
