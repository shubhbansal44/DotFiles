#!/bin/bash

# Get the path to the root of the dotfiles repository
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && cd .. && pwd)"
INSTALLER_DIR="$DOTFILES_DIR/installer"

# Load banner/header (likely ASCII art or project info)
source "$INSTALLER_DIR/components/header.sh"

# Load utility functions (e.g., run_script, log, print_info)
source "$INSTALLER_DIR/core/utils.sh"

# Print a section separator with a label before installation starts
separator "$BASH_COLOR_Cyan" "=" 120 "PREPARING TO INSTALL"

# Ensure script is run as root and on Arch Linux
check_root
check_arch

# Run base system setup script
separator "$BASH_COLOR_Cyan" "-" 120 "STARTING BASE SETUP"
run_script "$INSTALLER_DIR/components/base.sh" "Base Setup"
separator "$BASH_COLOR_Cyan" "#" 120

# Run config file copying/setup
separator "$BASH_COLOR_Cyan" "-" 120 "STARTING CONFIG SETUP"
run_script "$INSTALLER_DIR/components/config.sh" "Config Setup"
separator "$BASH_COLOR_Cyan" "#" 120

# Run asset (wallpaper, cache files) installation
separator "$BASH_COLOR_Cyan" "-" 120 "STARTING ASSETS SETUP"
run_script "$INSTALLER_DIR/components/assets.sh" "Assets Setup"
separator "$BASH_COLOR_Cyan" "#" 120

# Run script installation (user-written shell scripts)
separator "$BASH_COLOR_Cyan" "-" 120 "STARTING SCRIPTS SETUP"
run_script "$INSTALLER_DIR/components/scripts.sh" "Scripts Setup"
separator "$BASH_COLOR_Cyan" "#" 120

# Copy dotfiles (like .bashrc, .zshrc) to $HOME
separator "$BASH_COLOR_Cyan" "-" 120 "STARTING HOME DIRECTORY SETUP"
run_script "$INSTALLER_DIR/components/home.sh" "Home Directory Setup"
separator "$BASH_COLOR_Cyan" "#" 120

# Run miscellaneous setup (like custom TTY and Ollama)
separator "$BASH_COLOR_Cyan" "-" 120 "STARTING MISCELLANEOUS SYSTEM SETUP"
run_script "$INSTALLER_DIR/components/misc.sh" "Custom tty Login & ollama Setup"
separator "$BASH_COLOR_Cyan" "#" 120

# Load final message or steps (cleanup, success note, etc.)
source "$INSTALLER_DIR/components/final.sh"
