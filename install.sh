#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

is_standalone() {
    [[ ! -f "./src/main.sh" ]]
}

download_repo() {
    print_info "Downloading full dotfiles repository..."

    local temp_dir=$(mktemp -d)
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
        ./src/main.sh "$@"
    else
        print_error "Failed to download repository properly"
        exit 1
    fi
}

main() {
    if is_standalone; then
        print_info "Running in standalone mode - downloading full repository..."
        download_repo "$@"
    else
        print_info "Running from repository - executing main script..."
        # We're in the repo, just run the main script
        ./src/main.sh "$@"
    fi
}

main "$@"
