#!/bin/bash

mapfile -t MAN_COMMANDS < <(man -k . 2>/dev/null | awk '{print $1}' | sort -u)

[[ ${#MAN_COMMANDS[@]} -eq 0 ]] && echo "❌ No man pages found." && exit 1

SELECTED=$(printf "%s\n" "${MAN_COMMANDS[@]}" | fzf \
  --height=100% \
  --layout=reverse \
  --border \
  --prompt=" man page: " \
  --preview='man {} | col -bx | head -n 100 | bat --language=man --style=plain --color=always --paging=never' \
  --preview-window=right:60%:wrap \
  --bind="ctrl-l:toggle-preview")

# Only run if selection is non-empty and not just whitespace
if [[ -n "$SELECTED" && "$SELECTED" != "" ]]; then
  man "$SELECTED"
fi
