#!/bin/bash

SEARCH_DIR="$HOME"
CACHE_FILE="$HOME/.cache/code_file_cache"
CACHE_TTL=1800  # cache duration in seconds (30 minutes)
BLUE="\033[1;34m"
RESET="\033[0m"

EXT_REGEX=".*\.(bash|zsh|sh|c|cpp|h|hpp|py|js|ts|java|cs|go|rs|rb|pl|php|lua|swift|kt|scala|m|vb|\
html|css|scss|less|xml|json|jsonc|yaml|yml|toml|ini|cfg|conf|md|markdown|rst|txt|log|csv|tsv|env|\
dockerfile|makefile|gradle|gitignore|editorconfig|gitattributes)$"

# ─── Load Cache or Refresh ────────────────────────────────────────
if [[ -f "$CACHE_FILE" && $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") )) -lt $CACHE_TTL ]]; then
  mapfile -t FILES < "$CACHE_FILE"
else
  echo -e "⏳ ${BLUE}Indexing files, please wait...${RESET}"
  mapfile -t FILES < <(
    fd . "$SEARCH_DIR" --type f \
      --exclude ".git" \
      --exclude "node_modules" \
      --hidden \
      -E "*/.git/*" -E "*/node_modules/*" \
      | grep -Ei "$EXT_REGEX|/(\.[a-zA-Z0-9_-]+)$"
  )
  printf "%s\n" "${FILES[@]}" > "$CACHE_FILE"
fi

# ─── Exit if No Files ─────────────────────────────────────────────
if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "❌ No readable code/text files found in $SEARCH_DIR"
  exit 1
fi

# ─── Launch FZF ───────────────────────────────────────────────────
SELECTED=$(printf "%s\n" "${FILES[@]}" | sort -u | fzf \
  --multi \
  --preview='echo -e "\033[1;34m📄 {}\033[0m\n" && bat --style=plain --color=always --paging=never "$(echo {})"' \
  --preview-window=right:60%:wrap \
  --layout=reverse \
  --height=100% \
  --border \
  --ansi \
  --prompt="📄 Code Files: " \
  --header="Select one or more files to open in VS Code" \
  --bind "ctrl-l:toggle-preview"
)

# ─── Copy & Open in VS Code ───────────────────────────────────────
if [[ -n "$SELECTED" ]]; then
  echo "$SELECTED" | wl-copy
  if pgrep -x "code" > /dev/null; then
    xargs -d '\n' code --reuse-window <<< "$SELECTED"
  else
    xargs -d '\n' code <<< "$SELECTED"
  fi
  kitty @ close-window
fi

# kitty_pid=$(ps -o ppid= -p $$)
# kill "$kitty_pid"
