#!/bin/bash

# Get the root of the dotfiles directory
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
INSTALLER_DIR="$DOTFILES_DIR/installer"

# Load utility functions (log, separator, print_info, etc.)
source "$INSTALLER_DIR/core/utils.sh"

# Final separator banner indicating setup completion
separator "$BASH_COLOR_Cyan" "=" 120 "🎉 SETUP COMPLETE — YOUR SYSTEM IS READY"

# Show a message to the user
print_info "Your Arch Linux system has been customized with Shubh Bansal's dotfiles."
echo

# --- FILE STRUCTURE OVERVIEW ---

separator "$BASH_COLOR_Green" "=" 120 "📁 FILE STRUCTURE OVERVIEW"
echo

# List key config directories and their usage
echo -e "  ${BASH_COLOR_BOLD}${BASH_COLOR_Cyan}~/.config/ — Application configurations:${BASH_COLOR_NC}"
echo -e "  ├── hypr/                                               ${BASH_COLOR_LightPurple}→ Hyprland window manager config${BASH_COLOR_NC}"
echo -e "  ├── waybar/                                             ${BASH_COLOR_LightPurple}→ Status bar with modules${BASH_COLOR_NC}"
echo -e "  ├── dunst/                                              ${BASH_COLOR_LightPurple}→ Notification styling (dunstrc)${BASH_COLOR_NC}"
echo -e "  ├── kitty/                                              ${BASH_COLOR_LightPurple}→ Terminal config + theme${BASH_COLOR_NC}"
echo -e "  ├── rofi/                                               ${BASH_COLOR_LightPurple}→ Launcher (app switcher) themes${BASH_COLOR_NC}"
echo -e "  ├── cava/                                               ${BASH_COLOR_LightPurple}→ Audio visualizer${BASH_COLOR_NC}"
echo -e "  ├── starship/                                           ${BASH_COLOR_LightPurple}→ Shell prompt theme${BASH_COLOR_NC}"
echo -e "  ├── fastfetch/                                          ${BASH_COLOR_LightPurple}→ Terminal system info tool${BASH_COLOR_NC}"
echo -e "  ├── nwg-look/, qt5ct/, qt6ct/                           ${BASH_COLOR_LightPurple}→ GTK/QT theming configs${BASH_COLOR_NC}"
echo -e "  ├── gtk-3.0/, gtk-4.0/                                  ${BASH_COLOR_LightPurple}→ GTK-specific theme settings${BASH_COLOR_NC}"
echo -e "  ├── ollama/, xsettingsd/, systemd/, etc.                ${BASH_COLOR_LightPurple}→ Additional configs${BASH_COLOR_NC}"
echo

# Describe where CLI scripts are placed
echo -e "  ${BASH_COLOR_BOLD}${BASH_COLOR_Cyan}~/.local/bin/ — Custom helper scripts:${BASH_COLOR_NC}"
echo -e "  ├── ask.sh, wifi-connect.sh, help-bash.sh, etc.         ${BASH_COLOR_LightPurple}→ CLI scripts usable from terminal (in your PATH)${BASH_COLOR_NC}"
echo

# Wallpaper assets
echo -e "  ${BASH_COLOR_BOLD}${BASH_COLOR_Cyan}~/Pictures/Wallpapers/ — Wallpaper collection:${BASH_COLOR_NC}"
echo -e "  ├── 1.jpg, 2.jpg, 3.jpg, 4.jpeg                         ${BASH_COLOR_LightPurple}→ Used by swww or change_wallpaper.sh${BASH_COLOR_NC}"
echo

# Shell and startup dotfiles
echo -e "  ${BASH_COLOR_BOLD}${BASH_COLOR_Cyan}~ (Home directory) — System startup + terminal files:${BASH_COLOR_NC}"
echo -e "  ├── .bashrc, .bash_profile                              ${BASH_COLOR_LightPurple}→ Your shell config${BASH_COLOR_NC}"
echo -e "  ├── .xinitrc                                            ${BASH_COLOR_LightPurple}→ Starts Hyprland via startx${BASH_COLOR_NC}"
echo -e "  └── issue                                               ${BASH_COLOR_LightPurple}→ Custom login message${BASH_COLOR_NC}"
echo

# --- CREDITS SECTION ---

separator "$BASH_COLOR_Yellow" "=" 120 "🙌 CREDITS — Shubh Bansal"
echo
echo -e "  ${BASH_COLOR_BOLD}${BASH_COLOR_LightBlue}🔵 Author:  ${BASH_COLOR_NC}Shubh Bansal\n"
echo -e "  ${BASH_COLOR_BOLD}${BASH_COLOR_LightBlue}🔵 GitHub:  ${BASH_COLOR_NC}shubhbansal44\n"
echo -e "  ${BASH_COLOR_BOLD}${BASH_COLOR_LightBlue}🔵 Reddit:  ${BASH_COLOR_NC}u/Heaurision_Guy432\n"
echo -e "  ${BASH_COLOR_BOLD}${BASH_COLOR_LightBlue}🔵 Twitter: ${BASH_COLOR_NC}@ShubhBa88864619\n"
# echo -e "  ${BASH_COLOR_BOLD}${BASH_COLOR_LightBlue}🔵 Website: ${BASH_COLOR_NC}https://me.com\n"
echo

# --- NEXT STEPS FOR USER ---

separator "$BASH_COLOR_Cyan" "=" 120 "💡 NEXT STEPS"

# Guidance on how to start and what to customize
print_info "✅ Reboot or run Hyprland with: start"
print_info "✅ Modify configs in ~/.config to personalize your environment"
print_info "✅ Scripts available in ~/.local/bin"
print_info "✅ Wallpapers in ~/Pictures/Wallpapers"
print_info "✅ Terminal looks: Starship, Kitty, Rofi already themed!"
echo

# Final goodbye banner
separator "$BASH_COLOR_Green" "=" 120 "🚀 DONE — ENJOY YOUR NEW SYSTEM"
echo
