#!/bin/bash

# Get the root directory of the dotfiles repository
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
INSTALLER_DIR="$DOTFILES_DIR/installer"

# Source utility functions (log, print_info, run_command, etc.)
source "$INSTALLER_DIR/core/utils.sh"

# Start log entry
log "Starting asset setup"
print_info "Loading wallpapers and other assets..."

# Define source and destination paths for wallpapers
WALLPAPER_SRC="$DOTFILES_DIR/assets/Wallpapers"
WALLPAPER_DEST="$HOME/Pictures/Wallpapers"

# Create destination directory and copy all wallpapers
run_command "mkdir -p \"$WALLPAPER_DEST\" && cp -r \"$WALLPAPER_SRC\"/* \"$WALLPAPER_DEST\"" \
  "Copying wallpapers to Pictures folder" "no" "no"

# Define path to cache directory and ensure it exists
CACHE_DIR="$HOME/.cache"

# Paths for help JSON file (used by help-bash)
HELP_JSON_SRC="$DOTFILES_DIR/assets/help-bash-descriptions.json"
HELP_JSON_DEST="$CACHE_DIR/help-bash-descriptions.json"

# Path for wallpaper index tracking (custom logic)
WALLPAPER_INDEX_SRC="$DOTFILES_DIR/assets/current_wallpaper_index"
WALLPAPER_INDEX_DEST="$CACHE_DIR/current_wallpaper_index"

# Create the cache directory if missing
mkdir -p "$CACHE_DIR"

# Copy help JSON and wallpaper index to cache
cp "$HELP_JSON_SRC" "$HELP_JSON_DEST"
cp "$WALLPAPER_INDEX_SRC" "$WALLPAPER_INDEX_DEST"
