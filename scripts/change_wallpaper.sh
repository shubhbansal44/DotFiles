#!/bin/bash

wallpaper_dir="$HOME/Wallpapers"
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

# Generate blurred lock screen version
magick "$new_wall" \
    -resize 1920x1080^ \
    -gravity center -extent 1920x1080 \
    -strip \
    -colorspace sRGB \
    -alpha remove \
    -blur 0x8 \
    -define png:color-type=2 \
    "$lockscreen_wall"
