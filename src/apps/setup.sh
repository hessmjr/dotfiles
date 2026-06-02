#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Directory of this script (holds apps.txt)
APPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_FILE="$APPS_DIR/apps.txt"

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"  # leading
    s="${s%"${s##*[![:space:]]}"}"  # trailing
    echo "$s"
}

list_apps() {
    if [[ ! -f "$APPS_FILE" ]]; then
        print_error "App list not found: $APPS_FILE"
        return 1
    fi

    print_section "Applications you may want to install"

    while IFS='|' read -r name use; do
        name="$(trim "$name")"
        # Skip blank lines and comments
        [[ -z "$name" ]] && continue
        [[ "${name:0:1}" == "#" ]] && continue
        use="$(trim "$use")"
        printf "  • %-20s %s\n" "$name" "$use"
    done < "$APPS_FILE"

    print_info "Install whichever you want manually from their official sources."
}

main() {
    print_info "Applications"

    if ask_for_confirmation "Show the list of applications you may want to install?" "y"; then
        list_apps
    else
        print_info "Skipping application list"
    fi
}

main "$@"
