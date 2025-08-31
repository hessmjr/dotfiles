#!/bin/bash

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/src/utils.sh"

is_standalone() {
    [[ ! -f "./src/main.sh" ]]
}

download_repo() {
    print_info "Downloading full dotfiles repository..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir" || exit 1

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://github.com/yourusername/dotfiles/tarball/main | tar -xz --strip-components 1 --exclude='{*.md,.git*,LICENSE,old/*}'
    elif command -v wget >/dev/null 2>&1; then
        wget -O - https://github.com/yourusername/dotfiles/tarball/main | tar -xz --strip-components 1 --exclude='{*.md,.git*,LICENSE,old/*}'
    else
        print_error "Neither curl nor wget found. Please install one and try again."
        exit 1
    fi

    if [[ -f "./src/main.sh" ]]; then
        print_success "Repository downloaded successfully"
        ./src/main.sh
    else
        print_error "Failed to download repository properly"
        exit 1
    fi
}

main() {
    if is_standalone; then
        print_info "Running in standalone mode - downloading full repository..."
        download_repo
    else
        print_info "Running from repository - executing main script..."
        # We're in the repo, just run the main script
        ./src/main.sh
    fi
}

main "$@"
