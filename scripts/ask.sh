#!/bin/bash

# ─── Colors ───────────────────────────────────────────────
BOLD="\033[1m"
BLUE="\033[1;34m"
GREEN="\033[1;32m"
RED="\033[1;31m"
GRAY="\033[1;90m"
RESET="\033[0m"

# ─── Help Message ─────────────────────────────────────────
show_help() {
  echo -e "${BOLD}${BLUE}📘 ask - Local Terminal Assistant (Ollama)${RESET}"
  echo
  echo -e "${BOLD}Usage:${RESET} ask [OPTION] \"your terminal question\""
  echo
  echo -e "${GREEN}Options:${RESET}"
  echo -e "  ${BOLD}-b${RESET}        Use ${BLUE}Mistral${RESET} (default): Good general-purpose model, short & fast"
  echo -e "  ${BOLD}-q${RESET}        Use ${BLUE}Phi-3${RESET}: Lightweight, great for quick terminal-based how-to’s"
  echo -e "  ${BOLD}-e${RESET}        Use ${BLUE}LLaMA3${RESET}: More verbose, better reasoning, but slower"
  echo -e "  ${BOLD}-h${RESET}        Show this help message"
  echo
  echo -e "${BLUE}Example:${RESET}"
  echo -e "  ask -q \"How to check active ports on Linux?\""
  echo -e "  ask -e \"Difference between curl and wget?\""
  echo -e "  ask \"List all services using systemd\" (uses default model)"
  echo
  echo -e "${GRAY}⚡ Models must be pulled via \`ollama pull <model>\` before use.${RESET}"
  exit 0
}

# ─── Default Model ────────────────────────────────────────
MODEL="mistral"
MODEL_NAME="Mistral"

# ─── Parse Flags ──────────────────────────────────────────
while getopts ":qebh" opt; do
  case $opt in
    q) MODEL="phi3"; MODEL_NAME="Phi-3" ;;
    e) MODEL="llama3"; MODEL_NAME="LLaMA3" ;;
    b) MODEL="mistral"; MODEL_NAME="Mistral" ;;
    h) show_help ;;
    \?) echo -e "${RED}❌ Unknown option: -$OPTARG${RESET}"; show_help ;;
  esac
done
shift $((OPTIND -1))

# ─── Prompt File ──────────────────────────────────────────
PROMPT_FILE="$HOME/.config/ollama/terminal-assistant.prompt"
[[ ! -f "$PROMPT_FILE" ]] && {
  echo -e "${RED}❌ System prompt file not found at:${RESET} $PROMPT_FILE"
  exit 1
}

# ─── Missing Question ─────────────────────────────────────
if [[ -z "$1" ]]; then
  echo -e "${RED}❗ No question provided.${RESET}"
  echo -e "Run ${BOLD}ask -h${RESET} for usage."
  exit 1
fi

# ─── Join Prompt and System Prompt ────────────────────────
SYS_PROMPT=$(jq -Rs < "$PROMPT_FILE")
PROMPT=$(printf "%s" "$*" | jq -Rs)

# ─── Banner ───────────────────────────────────────────────
echo -e "${BOLD}${BLUE}🔍 Terminal Question:${RESET} \"$*\""
echo -e "${BOLD}${GRAY}💭 Model Used:${RESET} $MODEL_NAME"
echo -e "${GREEN}─────────────────────────────────────────────────────${RESET}"

# ─── Ask Ollama ───────────────────────────────────────────
RESPONSE=$(curl -s http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"prompt\": $PROMPT,
    \"system\": $SYS_PROMPT,
    \"stream\": false
  }" | jq -r '.response')

# ─── Output ───────────────────────────────────────────────
echo -e "$RESPONSE"
echo -e "${GREEN}─────────────────────────────────────────────────────${RESET}"
