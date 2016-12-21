#!/bin/bash


cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"


install_apps() {
    # Install tools for compiling/building software from source.
    install_package "Build Essential" "build-essential"

    # GnuPG archive keys of the Debian archive.
    install_package "GnuPG archive keys" "debian-archive-keyring"

    # Software which is not included by default
    # in Ubuntu due to legal or copyright reasons.
    printf "\n"

    install_package "cURL" "curl"
    install_package "Git" "git"
    install_package "GNOME Vim" "vim-gnome"
    install_package "tmux" "tmux"
}


main() {
    print_in_purple "   Miscellaneous\n\n"

    update
    upgrade
    printf "\n"
    install_apps
    printf "\n"
    autoremove
}


main
