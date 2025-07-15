#!/bin/bash

TLDR_PAGE_DIR="$HOME/.cache/tldr/pages"
CACHE_FILE="$HOME/.cache/tldr-fzf-cache"
CHECKSUM_FILE="$HOME/.cache/tldr-fzf-checksum"

# Check if TLDR pages exist
if [[ ! -d "$TLDR_PAGE_DIR" ]]; then
  echo "❌ TLDR cache not found. Run: tldr --update"
  exit 1
fi

# Calculate checksum of the page directory (file list)
CURRENT_SUM=$(find "$TLDR_PAGE_DIR" -type f -name "*.md" | sort | sha256sum)

# If no cache or checksum changed, rebuild command list
if [[ ! -f "$CACHE_FILE" ]] || [[ "$CURRENT_SUM" != "$(cat "$CHECKSUM_FILE" 2>/dev/null)" ]]; then
  echo "🔄 Caching TLDR command list..."
  find "$TLDR_PAGE_DIR" -type f -name "*.md" -exec basename {} .md \; | sort -u > "$CACHE_FILE"
  echo "$CURRENT_SUM" > "$CHECKSUM_FILE"
fi

# Load commands from cache
mapfile -t TLDR_CMDS < "$CACHE_FILE"

if [[ ${#TLDR_CMDS[@]} -eq 0 ]]; then
  echo "❌ No TLDR pages cached."
  exit 1
fi

# FZF picker with preview
SELECTED=$(printf "%s\n" "${TLDR_CMDS[@]}" | fzf \
  --height=100% \
  --layout=reverse \
  --border \
  --prompt="📄 tldr: " \
  --preview='bash -c '"'"'
PAGE=$(find ~/.cache/tldr/pages -type f -name "{}.md" | head -n 1)
[[ -f "$PAGE" ]] && bat --style=plain --color=always "$PAGE"
'"'"'' \
  --preview-window=right:60%:wrap \
  --bind="ctrl-l:toggle-preview"
)

# Run selected tldr
if [[ -n "$SELECTED" ]]; then
  tldr "$SELECTED"
fi
