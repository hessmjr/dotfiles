
# OSX-only stuff. Abort if not OSX.
is_osx || return 1

###############################################################################
# Homebrew Setup                                                              #
###############################################################################

# Install Homebrew from GitHub server
if [[ ! "$(type -P brew)" ]]; then
  e_header "Installing Homebrew"
  true | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Exit if, for some reason, Homebrew is not installed
[[ ! "$(type -P brew)" ]] && e_error "Homebrew failed to install." && return 1

###############################################################################
# Homebrew Recipes                                                            #
###############################################################################

# Check Homebrew and update
brew doctor
brew update

# Execute Homebrew taps and recipes
tap 'caskroom/cask'
tap 'caskroom/versions'
tap 'homebrew/bundle'
tap 'homebrew/core'
tap 'homebrew/dupes'
cask 'java'
brew 'ant'
brew 'gdbm'
brew 'xz'
brew 'git'
brew 'gradle'
brew 'maven'
brew 'openssl'
brew 'mysql'
brew 'pkg-config'
brew 'node'
brew 'readline'
brew 'sqlite'
brew 'homebrew/dupes/tcl-tk'
brew 'python'
brew 'python3'
brew 'redis'

# Do a final Homebrew check and cleanup
brew doctor
brew cleanup
