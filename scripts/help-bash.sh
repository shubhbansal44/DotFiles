#!/bin/bash

# ─── Colors ─────────────────────────────────────────────
BOLD="\033[1m"
BLUE="\033[1;34m"
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

# ─── Config ─────────────────────────────────────────────
BASHRC="$HOME/.bashrc"
CACHE_FILE="$HOME/.cache/help-bash-descriptions.json"
SYS_PROMPT_FILE="$HOME/.config/ollama/help-bash.prompt"
MODEL="mistral"
MODEL_NAME="$(tr '[:upper:]' '[:lower:]' <<< "$MODEL")"
MODEL_NAME="${MODEL_NAME^}"

# ─── Check System Prompt ───────────────────────────────
if [[ ! -f "$SYS_PROMPT_FILE" ]]; then
  echo -e "${RED}❌ Missing system prompt file:${RESET} $SYS_PROMPT_FILE"
  exit 1
fi
SYS_PROMPT=$(jq -Rs < "$SYS_PROMPT_FILE")

# ─── Ensure Cache ──────────────────────────────────────
mkdir -p "$(dirname "$CACHE_FILE")"
[[ ! -f "$CACHE_FILE" ]] && echo "{}" > "$CACHE_FILE"

# ─── Search Mode (e.g., help-bash wifi-on) ─────────────
if [[ -n "$1" ]]; then
  SEARCH="$1"
  DESC=$(jq -r --arg k "$SEARCH" '.[$k] // empty' "$CACHE_FILE")

  if [[ -n "$DESC" ]]; then
    echo -e "${BLUE}🔍 Found in cache:${RESET} ${BOLD}$SEARCH${RESET}"
    echo -e "${GREEN}- $DESC${RESET}"
    exit 0
  fi

  # Extract full definition
  definition=$(awk -v name="$SEARCH" '
    $0 ~ "alias "name"=" {
      print
      exit
    }
    $1 == name"()" {
      print; found=1; next
    }
    found {
      print
      if ($0 ~ /\}/) exit
    }
  ' "$BASHRC")

  if [[ -z "$definition" ]]; then
    echo -e "${RED}❌ Definition not found in .bashrc for:${RESET} $SEARCH"
    exit 1
  fi

  echo -e "${BLUE}🔍 Fetching new definition for:${RESET} $SEARCH"

  PROMPT=$(jq -Rs <<< "$definition")

  DESC=$(curl -s http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d "{
      \"model\": \"$MODEL\",
      \"prompt\": $PROMPT,
      \"system\": $SYS_PROMPT,
      \"stream\": false
    }" | jq -r '.response')

  echo -e "${GREEN}- $DESC${RESET}"
  tmp=$(mktemp)
  jq --arg k "$SEARCH" --arg v "$DESC" '. + {($k): $v}' "$CACHE_FILE" > "$tmp" && mv "$tmp" "$CACHE_FILE"
  exit 0
fi

# ─── Header ─────────────────────────────────────────────
echo -e "${BLUE}🔍 Analyzing Aliases & Functions${RESET}"
echo -e "Using model: ${BOLD}${MODEL_NAME}${RESET}"
echo -e "${GREEN}────────────────────────────────────────────${RESET}"

# ─── Get All Aliases & Functions ──────────────────────
mapfile -t ALIASES < <(grep -E '^alias ' "$BASHRC" | cut -d '=' -f1 | sed 's/alias //')
mapfile -t FUNCTIONS < <(awk '/^[a-zA-Z0-9_]+\(\)[ ]*\{/,/\}/' "$BASHRC" | grep -E '^[a-zA-Z0-9_]+\(\)' | cut -d '(' -f1)
ALL_ITEMS=("${ALIASES[@]}" "${FUNCTIONS[@]}")

# ─── Describe Each ─────────────────────────────────────
for item in "${ALL_ITEMS[@]}"; do
  DESC=$(jq -r --arg item "$item" '.[$item] // empty' "$CACHE_FILE")
  if [[ -n "$DESC" ]]; then
    echo -e "${BOLD}- $item:${RESET} $DESC"
    continue
  fi

  definition=$(awk -v name="$item" '
    $0 ~ "alias "name"=" {
      print
      exit
    }
    $1 == name"()" {
      print; found=1; next
    }
    found {
      print
      if ($0 ~ /\}/) exit
    }
  ' "$BASHRC")

  [[ -z "$definition" ]] && continue

  PROMPT=$(jq -Rs <<< "$definition")

  DESC=$(curl -s http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d "{
      \"model\": \"$MODEL\",
      \"prompt\": $PROMPT,
      \"system\": $SYS_PROMPT,
      \"stream\": false
    }" | jq -r '.response')

  echo -e "${BOLD}- $item:${RESET} $DESC"
  tmp=$(mktemp)
  jq --arg k "$item" --arg v "$DESC" '. + {($k): $v}' "$CACHE_FILE" > "$tmp" && mv "$tmp" "$CACHE_FILE"
done

echo -e "${GREEN}────────────────────────────────────────────${RESET}"
