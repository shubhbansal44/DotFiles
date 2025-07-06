#!/bin/bash

# Get the path to the root of the dotfiles repository
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
INSTALLER_DIR="$DOTFILES_DIR/installer"
LOG_FILE="$DOTFILES_DIR/dotfiles_install.log"

# Source color definitions for output styling
source "$INSTALLER_DIR/core/colors.sh"

# Draw a styled separator line, optionally with a label
separator() {
  local line_color="${1:-$BASH_COLOR_Cyan}"
  local char="${2:--}"
  local width="${3:-120}"
  local label="${4:-}"
  local label_color="${5:-$BASH_COLOR_Yellow}"

  if [[ -n "$label" ]]; then
    local label_text="[ $label ]"
    local rendered_label="${label_color}${label_text}${line_color}"

    local padding=$(( (width - ${#label_text}) / 2 ))
    local remainder=$(( width - (padding * 2 + ${#label_text}) ))

    local left_side="  $(printf "%*s" "$padding" "" | tr ' ' "$char")"
    local right_side="$(printf "%*s" "$((padding + remainder))" "" | tr ' ' "$char")"

    echo -e "${line_color}${left_side}${rendered_label}${right_side}${BASH_COLOR_NC}"
  else
    echo -e "${line_color}  $(printf "%${width}s" "" | tr ' ' "$char")${BASH_COLOR_NC}"
  fi
}

# Log messages with a timestamp
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Print error message in red and log it
print_error() {
  echo -e "  ${BASH_COLOR_Red}[✖] $1${BASH_COLOR_NC}\n"
  log "[ERROR] $1"
}

# Print success message in green and log it
print_success() {
  echo -e "  ${BASH_COLOR_Green}[✔] $1${BASH_COLOR_NC}\n"
  log "[SUCCESS] $1"
}

# Print warning message in purple and log it
print_warning() {
  echo -e "  ${BASH_COLOR_Purple}[!] $1${BASH_COLOR_NC}\n"
  log "[WARN] $1"
}

# Print info message in blue
print_info() {
  echo -e "  ${BASH_COLOR_Blue}[ℹ] $1${BASH_COLOR_NC}\n"
}

# Ask user for confirmation (Y/n) before proceeding
confirm() {
  echo -ne "  ${BASH_COLOR_Cyan}➤ $1 [Y/n] (Default Yes): ${BASH_COLOR_NC}"
  read -r response

  case "$response" in
    [nN][oO]|[nN])
      print_warning "$1 - declined"
      log "[DECLINED] $1"
      return 1
      ;;
    ""|[yY][eE][sS]|[yY])
      print_success "$1"
      log "[CONFIRMED] $1"
      return 0
      ;;
    *)
      print_error "Invalid input. Please answer y or n."
      confirm "$1"  # Retry on invalid input
      ;;
  esac
}

# Check if script is running as root, exit otherwise
check_root() {
  if [[ $EUID -ne 0 ]]; then
    print_error "Please run this script as root (use sudo)"
    log "Not run as root. Exiting."
    exit 1
  fi

  # Capture the invoking user
  export SUDO_USER=$(logname 2>/dev/null || echo "$USER")

  print_success "Sudo access granted as $SUDO_USER"
  log "Running as root, original user: $SUDO_USER"
}


# Verify if the system is Arch Linux
check_arch() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" != "arch" ]]; then
      print_warning "This script is meant for Arch Linux. Detected: $PRETTY_NAME"
      confirm "Continue anyway?" || {
        log "User declined to continue on non-Arch OS."
        exit 1
      }
    else
      print_success "Arch Linux Detected."
      log "Arch Linux verified."
    fi
  else
    print_warning "Cannot verify OS. /etc/os-release not found."
    confirm "Continue anyway?" || {
      log "User declined to continue with unknown OS."
      exit 1
    }
  fi
}

# Run a shell command with optional confirmation and sudo
run_command() {
  local cmd="$1"
  local description="$2"
  local confirm_first="${3:-yes}"  # Ask before executing
  local use_sudo="${4:-no}"        # Use sudo?

  local full_cmd=""

  # Decide command execution mode
  if [[ "$use_sudo" == "yes" ]]; then
    full_cmd="sudo $cmd"
  else
    full_cmd="sudo -u $SUDO_USER $cmd"
  fi

  print_info "Command: $full_cmd"
  log "Preparing to run: $description"
  log "Command: $full_cmd"

  if [[ "$confirm_first" == "yes" ]]; then
    if ! confirm "$description"; then
      log "User skipped: $description"
      return 1
    fi
  fi

  # Try running command, retry on failure
  while ! eval "$full_cmd"; do
    print_error "$description failed."
    log "Command failed: $cmd"
    if confirm "Retry $description?"; then
      continue
    else
      log "User skipped retry for: $description"
      return 1
    fi
  done

  print_success "$description completed."
  log "$description completed successfully."
  return 0
}

# Run a script with confirmation and retries
run_script() {
  local script_path="$1"
  local description="$2"

  if [[ ! -f "$script_path" ]]; then
    print_error "Script not found: $script_path"
    log "Missing script: $script_path"
    return 1
  fi

  print_info "Executing: $description"
  log "Attempting to run script: $description"

  if ! confirm "Run script: $description"; then
    log "User skipped: $description"
    return 1
  fi

  while ! bash "$script_path"; do
    print_error "$description failed."
    log "Script failed: $script_path"
    if confirm "Retry $description?"; then
      continue
    else
      log "User declined retry for: $description"
      return 1
    fi
  done

  print_success "$description completed."
  log "$description script executed successfully."
  return 0
}
