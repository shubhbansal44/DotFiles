#!/bin/bash

# Get the root directory of the dotfiles repository
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
INSTALLER_DIR="$DOTFILES_DIR/installer"

# Load utility functions (e.g., log, print_info, run_command)
source "$INSTALLER_DIR/core/utils.sh"

# Start logging
log "Starting base system setup"

# Update the system (package database and installed packages)
print_info "Updating system..."
run_command "pacman -Syyu --noconfirm" "Update package database and upgrade packages" "yes"

# Install yay (AUR helper)
print_info "Setting up YAY (AUR helper)..."
if run_command "pacman -S --noconfirm --needed git base-devel" "Install Git and base-devel (for YAY)" "yes"; then
    run_command "git clone https://aur.archlinux.org/yay.git && cd yay" "Clone YAY from AUR" "no" "no"
    run_command "makepkg --noconfirm -si && cd .." "Build and install YAY" "no" "no"
fi

# Install essential system packages (bootloader, firmware, tools)
print_info "Installing essential system packages..."
run_command "yay -S --noconfirm --needed base base-devel linux linux-firmware linux-headers sudo efibootmgr grub os-prober dosfstools mtools man-db wget curl less ncdu xdg-desktop-portal-hyprland" "Install base and essential system packages" "yes" "no"

# Install network-related packages (NetworkManager, Bluetooth)
print_info "Installing networking packages..."
run_command "yay -S --noconfirm --needed networkmanager nm-connection-editor bluez blueman bluez-utils" "Install networking and Bluetooth packages" "yes" "no"

# Install shell and terminal tools (CLI, dev tools, visuals)
print_info "Installing shell and CLI tools..."
run_command "yay -S --noconfirm --needed git rust gcc gdb cmake make nano neovim vim htop eza fastfetch figlet chafa jp2a ncdu starship xplr cava cmatrix imagemagick" "Install terminal and dev CLI tools" "yes" "no"

# Install fonts (Nerd fonts, emoji, dev fonts)
print_info "Installing fonts..."
run_command "yay -S --noconfirm --needed ttf-cascadia-code-nerd ttf-cascadia-mono-nerd ttf-fira-code ttf-fira-mono ttf-fira-sans ttf-firacode-nerd ttf-iosevka-nerd ttf-iosevkaterm-nerd ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono noto-fonts-emoji" "Install Nerd Fonts and emoji support" "yes" "no"

# Install audio and multimedia tools (Pipewire, VLC, etc.)
print_info "Installing audio and multimedia tools..."
run_command "yay -S --noconfirm --needed pipewire pipewire-pulse wireplumber pamixer pavucontrol vlc" "Install audio/media packages" "yes" "no"

# Install desktop GUI applications
print_info "Installing GUI applications..."
run_command "yay -S --noconfirm --needed brave-bin code obsidian spotify kitty nautilus" "Install GUI applications" "yes" "no"

# Install Hyprland window manager and related appearance tools
print_info "Installing Hyprland and UI tools..."
run_command "yay -S --noconfirm --needed hyprland hyprlock hypridle hyprpicker grimblast-git dunst rofi wlogout waybar nwg-look polkit-kde-agent kvantum kvantum-theme-catppuccin-git qt5ct qt6ct qt5-graphicaleffects rofimoji" "Install Hyprland and appearance tools" "yes" "no"

# Install programming languages and dev tools
print_info "Installing development tools..."
run_command "yay -S --noconfirm --needed nodejs npm python-pip" "Install Node.js, NPM, and Python" "yes" "no"
