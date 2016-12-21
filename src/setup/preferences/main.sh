#!/bin/bash


cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"


print_in_purple "\n • Preferences\n\n"
ask_for_confirmation "Proceed with installing preferences?"


if answer_is_yes; then
    printf "\n"
    "./$(get_os)/main.sh"
fi
