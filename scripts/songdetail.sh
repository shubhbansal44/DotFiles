#!/bin/bash

# Check if Spotify is running
if ! pgrep -x "spotify" > /dev/null; then
    song_info=$(playerctl metadata --format '{{title}}  -  {{artist}}')
    echo "$song_info" 
    exit 0
fi

# Get current playing track info
title=$(playerctl -p spotify metadata title)
artist=$(playerctl -p spotify metadata artist)

# Output in "title 🎧 artist" format if valid
if [[ -n "$title" && -n "$artist" ]]; then
    echo "$title     $artist"
else
    echo "♫ No song playing"
fi
