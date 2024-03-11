#!/bin/bash


verify_os() {
    declare -r MINIMUM_MACOS_VERSION="10.10"

    local os_name=""
    local os_version=""

    os_name="$(uname -s)"

    # Check if the OS is `macOS` and
    # it's above the required version.
    if [ "$os_name" == "Darwin" ]; then

        os_version="$(sw_vers -productVersion)"

        if is_supported_version "$os_version" "$MINIMUM_MACOS_VERSION"; then
            return 0
        else
            printf "Sorry, this script is intended only for macOS %s+" "$MINIMUM_MACOS_VERSION"
        fi

    else
        printf "Sorry, this script is intended only for macOS!"
    fi

    return 1
}


# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------
main() {
    # Ensure that the following actions
    # are made relative to this file's path.
    cd "$(dirname "${BASH_SOURCE[0]}")" \
        || exit 1

    # Load utils
    if [ -x "utils.sh" ]; then
        . "utils.sh" || exit 1
    else
        exit 1
    fi

    # Ensure the OS is supported and
    # it's above the required version.
    verify_os \
        || exit 1

    # get admin approval right away
    ask_for_sudo

    ./create_symbolic_links.sh "$@"
    ./create_local_config_files.sh

    ./install/main.sh
    ./preferences/main.sh

    # finish the setup and return home directory
    print_in_purple "\n • Process complete. \n\n"
    cd "$HOME"
}


main "$@"
