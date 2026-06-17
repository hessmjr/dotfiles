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

# Permanent install location for remote (curl|bash) installs.
# Must NOT be a temp dir: setup symlinks ~/.zsh/*.zsh back into this repo,
# so it has to persist after the installer exits (see issue #9).
DOTFILES_DIR="$HOME/.dotfiles"

is_remote() {
    [[ ! -f "$SCRIPT_DIR/src/main.sh" ]]
}

download_repo() {
    print_info "Installing dotfiles to $DOTFILES_DIR ..."

    # If a previous install exists, move it aside rather than clobbering it.
    if [[ -d "$DOTFILES_DIR" ]]; then
        local backup="${DOTFILES_DIR}.backup_$(date +%Y%m%d_%H%M%S)"
        print_info "Existing $DOTFILES_DIR found; moving it to $backup"
        mv "$DOTFILES_DIR" "$backup"
    fi

    mkdir -p "$DOTFILES_DIR"

    # Bootstrap with curl/wget + tar only (git is not guaranteed on a fresh Mac).
    local url="https://github.com/hessmjr/dotfiles/tarball/main"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" | tar -xz --strip-components 1 -C "$DOTFILES_DIR"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO - "$url" | tar -xz --strip-components 1 -C "$DOTFILES_DIR"
    else
        print_error "Neither curl nor wget found. Please install one and try again."
        exit 1
    fi

    if [[ -f "$DOTFILES_DIR/src/main.sh" ]]; then
        print_success "Repository installed to $DOTFILES_DIR"
        # Redirect stdin from /dev/tty to allow interactive prompts when piped
        "$DOTFILES_DIR/src/main.sh" < /dev/tty
    else
        print_error "Failed to download repository properly"
        exit 1
    fi
}

main() {
    if is_remote; then
        print_info "Running in remote mode - installing to $DOTFILES_DIR ..."
        download_repo
    else
        print_info "Running from local directory - executing main script..."
        "$SCRIPT_DIR/src/main.sh"
    fi
}

main "$@"
