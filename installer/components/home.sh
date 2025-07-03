#!/bin/bash

# Get the root path of the dotfiles repository
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
INSTALLER_DIR="$DOTFILES_DIR/installer"

# Load utility functions (log, print_info, etc.)
source "$INSTALLER_DIR/core/utils.sh"

# Start logging
log "Starting home directory setup"
print_info "Copying dotfiles to $HOME..."

# Path to the source dotfiles intended for $HOME (usually non-config dotfiles like .bashrc, .zshrc, etc.)
HOME_SRC="$DOTFILES_DIR/home"

# Enable 'dotglob' so hidden files (dotfiles) are included in the copy loop
shopt -s dotglob

# Loop through all files in the home folder of the repo and copy them into $HOME
for item in "$HOME_SRC"/*; do
  base_item=$(basename "$item")
  cp -r "$item" "$HOME/$base_item"
  log "Copied: $base_item → $HOME/"
done

# Disable 'dotglob' again after use to avoid side effects
shopt -u dotglob
