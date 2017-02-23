#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"


install_apps() {
    brew_install "Git" "git"
    brew_install "Tree" "tree"
}


main() {
    print_in_purple "\n   Miscellaneous\n\n"

    install_apps
    printf "\n"
    brew_cleanup
}


main
