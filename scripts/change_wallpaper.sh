#!/bin/bash

wallpaper_dir="$HOME/Pictures/Wallpapers"
index_file="$HOME/.cache/current_wallpaper_index"
lockscreen_wall="$HOME/.config/assets/hyprlock/lock-screen.png"

# Create the cache directory and file if they don't exist
mkdir -p "$(dirname "$index_file")"
touch "$index_file"

# Get all image files
mapfile -t wallpapers < <(find "$wallpaper_dir" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | sort)

# Read current index, default to 0
current_index=$(cat "$index_file")
current_index=${current_index:-0}

# Calculate next index
next_index=$(( (current_index + 1) % ${#wallpapers[@]} ))
new_wall="${wallpapers[$next_index]}"

# Set the new wallpaper
swww img "$new_wall" --transition-type outer --transition-duration 0.8 --transition-fps 255

# Save the index
echo "$next_index" > "$index_file"

# --- Dynamic lock screen overlay based on brightness ---

# Get average brightness (0–255)
brightness=$(magick "$new_wall" -resize 1x1 -format "%[fx:mean*255]" info:)

# Map brightness to opacity (0.2–0.6)
opacity=$(awk -v b="$brightness" 'BEGIN {
  min_o=0.3; max_o=0.5;
  opacity = min_o + (b / 255.0) * (max_o - min_o);
  if (opacity > max_o) opacity = max_o;
  if (opacity < min_o) opacity = min_o;
  printf "%.2f", opacity;
}')

# Generate blurred and dimmed lock screen image
magick "$new_wall" \
    -resize 1920x1080^ \
    -gravity center -extent 1920x1080 \
    -strip \
    -colorspace sRGB \
    -alpha remove \
    -blur 0x8 \
    \( -size 1920x1080 canvas:"rgba(0,0,0,$opacity)" \) -composite \
    -define png:color-type=2 \
    "$lockscreen_wall"
