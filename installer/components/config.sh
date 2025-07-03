#!/bin/bash

# Get the dotfiles directory (two levels up from this script)
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
INSTALLER_DIR="$DOTFILES_DIR/installer"

# Source utility functions (print_info, run_command, etc.)
source "$INSTALLER_DIR/core/utils.sh"

# Log the beginning of config setup
log "Starting config setup"
print_info "Installing/copying all user configurations..."

# Declare an associative array that maps dotfiles config paths to user config destinations
declare -A CONFIG_MAPPINGS=(
  ["$DOTFILES_DIR/config/kitty"]="$HOME/.config/kitty"
  ["$DOTFILES_DIR/config/nwg-look"]="$HOME/.config/nwg-look"
  ["$DOTFILES_DIR/config/cava"]="$HOME/.config/cava"
  ["$DOTFILES_DIR/config/dunst"]="$HOME/.config/dunst"
  ["$DOTFILES_DIR/config/fastfetch"]="$HOME/.config/fastfetch"
  ["$DOTFILES_DIR/config/htop"]="$HOME/.config/htop"
  ["$DOTFILES_DIR/config/hypr"]="$HOME/.config/hypr"
  ["$DOTFILES_DIR/config/ollama"]="$HOME/.config/ollama"
  ["$DOTFILES_DIR/config/qt5ct"]="$HOME/.config/qt5ct"
  ["$DOTFILES_DIR/config/qt6ct"]="$HOME/.config/qt6ct"
  ["$DOTFILES_DIR/config/rofi"]="$HOME/.config/rofi"
  ["$DOTFILES_DIR/config/starship/starship.toml"]="$HOME/.config/starship/starship.toml"
  ["$DOTFILES_DIR/config/waybar"]="$HOME/.config/waybar"
  ["$DOTFILES_DIR/config/wlogout"]="$HOME/.config/wlogout"
  ["$DOTFILES_DIR/config/xsettingsd"]="$HOME/.config/xsettingsd"
)

# Add extra config mappings outside of initial declaration
CONFIG_MAPPINGS["$DOTFILES_DIR/config/gtk-3.0"]="$HOME/.config/gtk-3.0"
CONFIG_MAPPINGS["$DOTFILES_DIR/config/gtk-4.0"]="$HOME/.config/gtk-4.0"
CONFIG_MAPPINGS["$DOTFILES_DIR/config/systemd/user"]="$HOME/.config/systemd/user"

# Asset directories (e.g., lock screen, logout screen)
CONFIG_MAPPINGS["$DOTFILES_DIR/config/assets/hyprlock"]="$HOME/.config/assets/hyprlock"
CONFIG_MAPPINGS["$DOTFILES_DIR/config/assets/wlogout"]="$HOME/.config/assets/wlogout"

# Loop through each source-destination mapping and copy the files
for src in "${!CONFIG_MAPPINGS[@]}"; do
  dest="${CONFIG_MAPPINGS[$src]}"
  run_command "mkdir -p $(dirname "$dest") && cp -r \"$src\" \"$dest\"" "Copying $(basename "$src") → $(basename "$dest")" "no" "no"
done
