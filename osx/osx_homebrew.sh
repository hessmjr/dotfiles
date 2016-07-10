# Scripts for installing homebrew and install wanted stuff

###############################################################################
# Homebrew Setup                                                              #
###############################################################################

# Install Homebrew from GitHub server
if [[ ! "$(type -P brew)" ]]; then
  true | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Exit if, for some reason, Homebrew is not installed
[[ ! "$(type -P brew)" ]] && return 1

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
