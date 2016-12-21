#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"


print_in_purple "\n   UI & UX\n\n"


# Doesn't create DS store files on drives not part of this computer
execute "defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true && \
         defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true" \
   "Avoid creating '.DS_Store' files on network or USB volumes"


# Crash reports are notifications instead of prompts
execute "defaults write com.apple.CrashReporter UseUNC 1" \
    "Make crash reports appear as notifications"


execute "defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true" \
    "Automatically quit the printer app once the print jobs are completed"


# Disables shadoes that appear in applications when taking screen shots
execute "defaults write com.apple.screencapture disable-shadow -bool true" \
    "Disable shadow in screenshots"


# Restart the system UI to let changes take affect
killall "SystemUIServer" &> /dev/null
