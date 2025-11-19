#!/bin/bash

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Minimal inline functions for bootstrapping
# (Full utilities are in src/utils.sh, loaded by src/main.sh)
print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

create_temp_dir() {
    local temp_dir
    temp_dir=$(mktemp -d)
    echo "$temp_dir"
}

is_standalone() {
    [[ ! -f "$SCRIPT_DIR/src/main.sh" ]]
}

download_repo() {
    print_info "Downloading full dotfiles repository..."

    local temp_dir=$(create_temp_dir)
    cd "$temp_dir" || exit 1

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://github.com/hessmjr/dotfiles/tarball/main | tar -xz --strip-components 1 --exclude='{*.md,.git*,LICENSE,old/*}'
    elif command -v wget >/dev/null 2>&1; then
        wget -O - https://github.com/hessmjr/dotfiles/tarball/main | tar -xz --strip-components 1 --exclude='{*.md,.git*,LICENSE,old/*}'
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
        "$SCRIPT_DIR/src/main.sh"
    fi
}

main "$@"
