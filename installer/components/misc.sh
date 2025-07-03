#!/bin/bash

# Get the dotfiles root directory
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
INSTALLER_DIR="$DOTFILES_DIR/installer"

# Load utility functions (log, print_info, run_command, etc.)
source "$INSTALLER_DIR/core/utils.sh"

# Log the beginning of this phase
log "Starting miscellaneous system setup"

# --- OLLAMA SETUP ---

print_info "Setting up Ollama (local LLM server)..."

# Check if Ollama is already installed
if ! command -v ollama &> /dev/null; then
    run_command "curl -fsSL https://ollama.com/install.sh | sh" \
      "Install Ollama (local AI engine)" "yes"
else
    print_success "Ollama is already installed."
    log "Ollama already present. Skipping installation."
fi

# Enable Ollama as a user-level systemd service
print_info "Enabling Ollama as a user service..."
run_command "systemctl --user daemon-reexec && systemctl --user daemon-reload && systemctl --user enable --now ollama" \
  "Enable and start Ollama (user service)" "yes" "no"

# --- OLLAMA MODEL SELECTION ---

print_info "Ollama models are necessary for various terminal assistants, like help-bash, ask."
print_info "You can skip any model or install them all."

# Predefined list of LLM models to optionally pull
MODELS=("llama3" "phi3" "mistral")

# Iterate through each model and install it if not present
for MODEL_NAME in "${MODELS[@]}"; do
    if ollama list | grep -q "$MODEL_NAME"; then
        print_success "Model '$MODEL_NAME' is already installed."
        log "Model $MODEL_NAME already present. Skipped pull."
    else
        run_command "ollama pull $MODEL_NAME" \
          "Pull Ollama model: $MODEL_NAME" "yes" "no"
    fi
done

print_info "You can always install more models later using: ollama pull <model>"

# --- TTY CUSTOMIZATION ---

print_info "Setting up custom TTY login screen..."

ISSUE_FILE="$DOTFILES_DIR/home/issue"     # Custom issue content
ISSUE_TARGET="/etc/issue"                 # System-wide login prompt config

# Check if the custom issue file exists
if [[ -f "$ISSUE_FILE" ]]; then
    # Copy issue file to system location (requires sudo)
    if run_command "sudo cp \"$ISSUE_FILE\" \"$ISSUE_TARGET\"" "Apply custom TTY login screen" "yes"; then
        print_success "Custom TTY login screen applied."
        log "Copied $ISSUE_FILE to $ISSUE_TARGET."
    else
        print_warning "Custom TTY login screen not applied."
        log "Failed to apply custom TTY login screen."
    fi
else
    print_warning "Issue file not found at $ISSUE_FILE"
    log "Issue file missing. Skipping TTY login screen setup."
fi
