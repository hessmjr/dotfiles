#!/bin/bash

# Dotfiles Utilities
# Shared functions and formatting for all dotfiles scripts

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_section() {
    echo -e "${PURPLE}[SECTION]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Common utility functions
ask_for_sudo() {
    # Ask for the administrator password upfront
    if sudo -n true 2>/dev/null; then
        # We have sudo access, no need to ask
        return 0
    fi

    print_info "This script requires administrator access to install some components."
    print_info "You may be prompted for your password."

    # Keep-alive: update existing `sudo` time stamp until script has finished
    sudo -v
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
}

# Progress tracking and user interaction functions
ask_for_confirmation() {
    local message="$1"
    local default="${2:-y}"  # Default to 'y' if not specified

    # Check if we're in non-interactive mode
    if [[ "${NON_INTERACTIVE:-false}" == "true" ]]; then
        print_info "Non-interactive mode: using default '$default' for '$message'"
        if [[ "$default" == "y" ]]; then
            return 0
        else
            return 1
        fi
    fi

    # Check if stdin is connected to a terminal
    if [[ ! -t 0 ]]; then
        print_warning "Not running in an interactive terminal. Using default '$default' for '$message'"
        if [[ "$default" == "y" ]]; then
            return 0
        else
            return 1
        fi
    fi

    local prompt
    if [[ "$default" == "y" ]]; then
        prompt="$message (Y/n): "
    else
        prompt="$message (y/N): "
    fi

    while true; do
        read -p "$prompt" -r response
        case "$response" in
            [Yy]|"") return 0 ;;  # Yes or empty (default)
            [Nn]) return 1 ;;     # No
            *) print_warning "Please answer 'y' or 'n'" ;;
        esac
    done
}

ask_for_confirmation_with_details() {
    local title="$1"
    local details="$2"
    local default="${3:-y}"

    print_section "$title"
    if [[ -n "$details" ]]; then
        print_info "$details"
    fi

    ask_for_confirmation "Proceed with this step?" "$default"
}

# Progress tracking
PROGRESS_CURRENT=0
PROGRESS_TOTAL=0

init_progress() {
    PROGRESS_CURRENT=0
    PROGRESS_TOTAL="$1"
    print_info "Starting installation of $PROGRESS_TOTAL components..."
}

update_progress() {
    local step_name="$1"
    PROGRESS_CURRENT=$((PROGRESS_CURRENT + 1))
    local percentage=$((PROGRESS_CURRENT * 100 / PROGRESS_TOTAL))
    print_info "[$PROGRESS_CURRENT/$PROGRESS_TOTAL] ($percentage%) $step_name"
}

# App installation helpers with prompts
prompt_for_app_installation() {
    local app_name="$1"
    local app_path="$2"
    local details="$3"

    print_section "$app_name Installation"

    # Check if app is already installed
    if is_app_installed "$app_path"; then
        print_success "$app_name is already installed at $app_path"
        if ask_for_confirmation "Would you like to reinstall $app_name?" "n"; then
            print_info "Will reinstall $app_name"
            return 0
        else
            print_info "Skipping $app_name installation"
            return 1
        fi
    fi

    # Show installation details and ask for confirmation
    if [[ -n "$details" ]]; then
        print_info "$details"
    fi

    if ask_for_confirmation "Install $app_name?" "y"; then
        print_info "Will install $app_name"
        return 0
    else
        print_info "Skipping $app_name installation"
        return 1
    fi
}

execute() {
    local command="$1"
    local description="$2"

    if [[ -n "$description" ]]; then
        print_info "$description"
    fi

    if eval "$command"; then
        print_success "Command executed successfully"
        return 0
    else
        print_error "Command failed: $command"
        return 1
    fi
}

print_result() {
    local result="$1"
    local message="$2"

    if [[ "$result" -eq 0 ]]; then
        print_success "$message"
    else
        print_error "$message"
    fi
}

get_os() {
    local os="$(uname -s)"
    case "$os" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

check_macos() {
    if [[ "$(get_os)" != "macos" ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi
}

# File and directory utilities
create_backup_dir() {
    local backup_dir="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    echo "$backup_dir"
}

backup_file() {
    local source_file="$1"
    local backup_dir="$2"

    if [[ -f "$source_file" ]] || [[ -d "$source_file" ]]; then
        local filename=$(basename "$source_file")
        local backup_path="$backup_dir/$filename"

        if cp -R "$source_file" "$backup_path" 2>/dev/null; then
            print_success "Backed up $filename"
            return 0
        else
            print_warning "Failed to backup $filename"
            return 1
        fi
    fi
    return 0
}

create_symlink() {
    local source="$1"
    local target="$2"
    local backup_dir="$3"

    # Create backup if target exists
    if [[ -L "$target" ]] || [[ -f "$target" ]] || [[ -d "$target" ]]; then
        if [[ -n "$backup_dir" ]]; then
            backup_file "$target" "$backup_dir"
        fi
        rm -rf "$target"
    fi

    # Create symlink
    if ln -sf "$source" "$target"; then
        print_success "Created symlink: $target -> $source"
        return 0
    else
        print_error "Failed to create symlink: $target -> $source"
        return 1
    fi
}

# macOS specific utilities
close_system_preferences() {
    print_info "Closing System Preferences..."
    osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
}

# Apps installer utilities (moved from apps/installers/utils.sh)
create_temp_dir() {
    local temp_dir=$(mktemp -d)
    echo "$temp_dir"
}

cleanup_temp_dir() {
    local temp_dir="$1"
    if [[ -n "$temp_dir" ]] && [[ -d "$temp_dir" ]]; then
        cd /
        rm -rf "$temp_dir"
    fi
}

mount_dmg() {
    local dmg_file="$1"
    local volume_name="$2"

    if hdiutil attach "$dmg_file" -quiet; then
        print_success "DMG mounted successfully"

        # Find the mounted volume
        local mount_point=$(hdiutil info | grep "/Volumes/$volume_name" | head -1 | awk '{print $3}')

        if [[ -n "$mount_point" ]]; then
            echo "$mount_point"
            return 0
        else
            print_warning "Could not find mounted $volume_name volume"
            return 1
        fi
    else
        print_warning "Failed to mount DMG file"
        return 1
    fi
}

unmount_dmg() {
    local mount_point="$1"
    if [[ -n "$mount_point" ]]; then
        hdiutil detach "$mount_point" -quiet
    fi
}

download_file() {
    local url="$1"
    local filename="$2"

    if curl -L -o "$filename" "$url"; then
        print_success "Download completed"
        return 0
    else
        print_warning "Failed to download file"
        return 1
    fi
}

extract_zip() {
    local zip_file="$1"

    if unzip -q "$zip_file"; then
        print_success "Extraction completed"
        return 0
    else
        print_warning "Failed to extract zip file"
        return 1
    fi
}

install_app_to_applications() {
    local source_app="$1"
    local app_name="$2"

    if cp -R "$source_app" "/Applications/"; then
        print_success "$app_name installed successfully"
        return 0
    else
        print_warning "Failed to copy to Applications directory"
        return 1
    fi
}

is_app_installed() {
    local app_path="$1"

    if [[ -d "$app_path" ]]; then
        return 0  # App is installed
    else
        return 1  # App is not installed
    fi
}
