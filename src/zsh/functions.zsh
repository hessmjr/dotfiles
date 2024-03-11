
# Empty the Trash and clean up the system
clean_up_trash() {
    # Empty the Trash on all mounted volumes and the main HDD
    echo "Emptying the Trash on all mounted volumes and the main HDD..."
    sudo rm -frv /Volumes/*/.Trashes
    sudo rm -frv ~/.Trash

    # Clear Apple's System Logs to improve shell startup speed
    echo "Clearing Apple's System Logs..."
    sudo rm -frv /private/var/log/asl/*.asl

    # Clear download history from quarantine
    echo "Clearing download history from quarantine..."
    sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'

    # Recursively delete `.DS_Store` files from the home directory
    echo "Removing .DS_Store files from the home directory..."
    find ~ -type f -name '*.DS_Store' -delete

    # Clear DNS cache
    echo "Clearing DNS cache..."
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder

    echo "Cleanup completed."
}


show_files() {
    defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder
}


hide_files() {
    defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder
}
