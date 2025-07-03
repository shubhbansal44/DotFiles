#!/bin/bash

SSID="$1"
PASSWORD="$2"

# === Utility Functions ===
notify() {
  # Send a desktop notification using dunst
  if command -v dunstify &> /dev/null; then
    notify-send "Wi-Fi Connect" "$1"
  fi
}

error_exit() {
  notify "❌ $1"
  echo "Error: $1"
  exit 1
}

# === Argument Validation ===
if [[ -z "$SSID" || -z "$PASSWORD" ]]; then
  error_exit "Usage: wifi-connect <SSID> <PASSWORD>"
fi

# === Check if nmcli is installed ===
if ! command -v nmcli &> /dev/null; then
  error_exit "nmcli is not installed. Please install NetworkManager."
fi

# === Enable Wi-Fi if disabled ===
if [[ "$(nmcli radio wifi)" == "disabled" ]]; then
  nmcli radio wifi on || error_exit "Failed to enable Wi-Fi radio"
  notify "🔁 Wi-Fi was off. Turning it on..."
  sleep 2
fi

# === Try Connecting ===
notify "🔌 Attempting to connect to \"$SSID\"..."

nmcli device wifi connect "$SSID" password "$PASSWORD" &> /tmp/wifi-connect.log

if [[ $? -eq 0 ]]; then
  notify "✅ Connected to \"$SSID\""
  echo "Success: Connected to $SSID"
else
  ERR_MSG=$(< /tmp/wifi-connect.log)
  error_exit "Failed to connect to \"$SSID\"\n$ERR_MSG"
fi
