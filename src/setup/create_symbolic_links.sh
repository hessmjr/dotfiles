#!/bin/bash


cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"


create_symlinks() {

    declare -a FILES_TO_SYMLINK=(
        "bash/aliases/bash_aliases"
        "bash/autocomplete/$(get_os)/bash_autocomplete"
        "bash/bash_exports"
        "bash/bash_logout"
        "bash/bash_options"
        "bash/bash_profile"
        "bash/bash_prompt"
        "bash/bashrc"
        "bash/curlrc"
        "bash/hushlogin"
    )

    local i=""
    local sourceFile=""
    local targetFile=""
    local backupFile="$HOME/.backups"

    for i in "${FILES_TO_SYMLINK[@]}"; do

        sourceFile="$(cd .. && pwd)/$i"
        targetFile="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

        if [ ! -e "$targetFile" ]; then

            execute \
                "ln -fs $sourceFile $targetFile" \
                "$targetFile → $sourceFile"

        elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
            print_success "$targetFile → $sourceFile"

        # target file already exists and need to confirm moving it to backups
        else
            ask_for_confirmation "'$targetFile' already exists, backup or keep?"
            if answer_is_yes; then

                # create backup directory if doesn't exist
                if [ ! -e "$backupFile" ]; then
                    mkd "$backupFile"
                fi

                # move existing file
                mv "$targetFile" "$backupFiles"

                execute \
                    "ln -fs $sourceFile $targetFile" \
                    "$targetFile → $sourceFile"

            else
                print_error "$targetFile → $sourceFile"
            fi
        fi

    done
}


main() {
    print_in_purple "\n • Create symbolic links\n\n"
    create_symlinks "$@"
}


main "$@"
