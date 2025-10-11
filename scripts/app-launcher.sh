#!/usr/bin/env bash
# app-launcher.sh — Hyprland app launcher
# Requires: jq

declare -A apps=(
  [code]="2"
  [idea]="5"
  [obsidian]="6"
  [spotify]="7"
  [brave-browser]="3"
  [org.gnome.Nautilus]="4"
  [nvim-editor]="5"
)

app="$1"
workspace="${apps[$app]}"

if [[ -z "$app" || -z "$workspace" ]]; then
  echo "Usage: app-launcher.sh <app_class>"
  exit 1
fi

# Check if app window already exists
if hyprctl clients -j | jq -e ".[] | select(.class == \"$app\")" >/dev/null; then
  hyprctl dispatch workspace "$workspace"
  exit 0
fi

# Otherwise, launch app
case "$app" in
  code)
    code & disown
    ;;
  idea)
    idea & disown
    ;;
  obsidian)
    obsidian & disown
    ;;
  spotify)
    spotify & disown
    ;;
  brave-browser)
    nohup /usr/bin/brave --enable-features=UseOzonePlatform --ozone-platform=wayland >/dev/null 2>&1 &
    ;;
  org.gnome.Nautilus)
    nautilus & disown
    ;;
  nvim-editor)
    kitty --class nvim-editor nvim & disown
    ;;
  *)
    echo "Unknown app: $app"
    exit 1
    ;;
esac

# Give it a moment to appear, then move to workspace
sleep 0.6
hyprctl dispatch workspace "$workspace"
