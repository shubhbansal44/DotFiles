#!/bin/bash

# Get the dotfiles root directory (two levels above this script)
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
INSTALLER_DIR="$DOTFILES_DIR/installer"

# Source utility functions (log, print_info, etc.)
source "$INSTALLER_DIR/core/utils.sh"

# Start logging
log "Starting script setup"
print_info "Compiling user scripts..."

# Target directory to install user's scripts
LOCAL_BIN="$HOME/.local/bin/new"

# Source location for user scripts in the dotfiles repo
SCRIPTS_SRC="$DOTFILES_DIR/scripts"

# Create the destination directory if it doesn't exist
mkdir -p "$LOCAL_BIN"

# Copy all .sh files from the source to the target, and make them executable
for script in "$SCRIPTS_SRC"/*.sh; do
  script_name=$(basename "$script")                  # Get script filename
  cp "$script" "$LOCAL_BIN/$script_name"             # Copy script to target
  chmod +x "$LOCAL_BIN/$script_name"                 # Make it executable
  log "Installed script: $script_name"               # Log installation
done
