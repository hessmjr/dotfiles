#!/bin/bash


cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"


print_in_purple "\n   Privacy\n\n"


# Prevent the internet from knowing what you're searching
execute "gsettings set com.canonical.Unity.Lenses remote-content-search 'none'" \
    "Turn off 'Remote Search' so that search terms in Dash do not get sent over the internet"


# Turn off more suggestions as well
execute "gsettings set com.canonical.Unity.ApplicationsLens display-available-apps false" \
    "Disable Dash 'More suggestions' section"
