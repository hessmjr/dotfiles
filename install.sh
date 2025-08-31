#!/bin/bash

# Dotfiles Install Script
# This script handles both standalone installation and repo-based installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if we're running in a full repo or standalone
is_standalone() {
    [[ ! -f "./src/main.sh" ]]
}

# Download and extract the full repository
download_repo() {
    print_info "Downloading full dotfiles repository..."

    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || exit 1

    # Download and extract the repository, excluding unnecessary files
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://github.com/yourusername/dotfiles/tarball/main | tar -xz --strip-components 1 --exclude='{*.md,.git*,LICENSE,old/*}'
    elif command -v wget >/dev/null 2>&1; then
        wget -O - https://github.com/yourusername/dotfiles/tarball/main | tar -xz --strip-components 1 --exclude='{*.md,.git*,LICENSE,old/*}'
    else
        print_error "Neither curl nor wget found. Please install one and try again."
        exit 1
    fi

    # Move to the extracted directory and run the install
    if [[ -f "./src/main.sh" ]]; then
        print_success "Repository downloaded successfully"
        ./src/main.sh "$@"
    else
        print_error "Failed to download repository properly"
        exit 1
    fi
}

# Main execution logic
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

# Run main function
main "$@"
