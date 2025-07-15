#!/bin/bash

SEARCH_DIR="$HOME"

# Collect directories (excluding hidden & common junk)
mapfile -t DIRS < <(
  fd . "$SEARCH_DIR" --type d --hidden \
    --exclude .git \
    --exclude node_modules \
    --exclude public \
    --exclude privateassets \
    --exclude '.*' 2>/dev/null
)

# If no folders found
if [[ ${#DIRS[@]} -eq 0 ]]; then
  echo "❌ No folders found in $SEARCH_DIR"
  exit 1
fi

# FZF prompt with tree preview
SELECTED=$(printf "%s\n" "${DIRS[@]}" | sort -u | fzf \
  --preview='tree -C -L 3 -I ".git|node_modules|public|privateassets" "$(echo {})"' \
  --preview-window=right:50% \
  --layout=reverse \
  --height=100% \
  --border \
  --ansi \
  --prompt="📂 Open Folder: " \
  --header="Select a folder to open in VS Code" \
  --bind "ctrl-l:toggle-preview")

# Open in VS Code (existing window if running)
if [[ -n "$SELECTED" ]]; then
  echo -n "$SELECTED" | wl-copy
  if pgrep -x "code" > /dev/null; then
    code --reuse-window "$SELECTED"
  else
    code "$SELECTED"
  fi
fi
