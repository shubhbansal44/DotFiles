#!/bin/bash

# ─── Configuration ─────────────────────────────
CONFIG="$HOME/.config/hotspot.conf"
DEFAULT_SSID="banshee"
DEFAULT_PASSWORD="reqw2@7yr^ti"
INTERFACE="wlo1"

# ─── Load Saved Config ─────────────────────────
if [[ -f "$CONFIG" ]]; then
  source "$CONFIG"
else
  SSID="$DEFAULT_SSID"
  PASSWORD="$DEFAULT_PASSWORD"
  mkdir -p "$(dirname "$CONFIG")"
  echo -e "SSID=\"$SSID\"\nPASSWORD=\"$PASSWORD\"" > "$CONFIG"
fi

# ─── Colors ────────────────────────────────────
BOLD="\033[1m"
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# ─── Save Config ───────────────────────────────
save_config() {
  mkdir -p "$(dirname "$CONFIG")"
  echo -e "SSID=\"$SSID\"\nPASSWORD=\"$PASSWORD\"" > "$CONFIG"
}

# ─── Validate Interface ────────────────────────
validate_interface() {
  if ! nmcli device status | grep -q "^$INTERFACE.*wifi"; then
    echo -e "${RED}❌ Error: Wireless interface '$INTERFACE' not found or not wireless.${RESET}"
    echo -e "${YELLOW}🔧 Tip: Run 'nmcli device status' to see available interfaces.${RESET}"
    exit 1
  fi
}

# ─── Start Hotspot ─────────────────────────────
start_hotspot() {
  validate_interface
  echo -e "${BLUE}📡 Starting hotspot on '$INTERFACE' with SSID: '${BOLD}${SSID}${RESET}${BLUE}'...${RESET}"
  OUTPUT=$(nmcli device wifi hotspot ifname "$INTERFACE" ssid "$SSID" password "$PASSWORD" 2>&1)
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}❌ Failed to start hotspot:${RESET}"
    echo -e "$OUTPUT"
    exit 1
  else
    echo -e "${GREEN}✅ Hotspot started successfully.${RESET}"
  fi
}

# ─── Stop Hotspot ──────────────────────────────
stop_hotspot() {
  if nmcli con show --active | grep -q "Hotspot"; then
    echo -e "${RED}🔌 Stopping Hotspot...${RESET}"
    nmcli connection down Hotspot &>/dev/null
    echo -e "${GREEN}✅ Hotspot stopped.${RESET}"
  else
    echo -e "${YELLOW}ℹ️  No active hotspot found.${RESET}"
  fi
}

# ─── Change Credentials ────────────────────────
change_credentials() {
  read -p "Enter new SSID: " NEW_SSID
  read -sp "Enter new Password (min 8 characters): " NEW_PASSWORD
  echo

  if [[ -z "$NEW_SSID" || -z "$NEW_PASSWORD" || ${#NEW_PASSWORD} -lt 8 ]]; then
    echo -e "${RED}❌ Invalid SSID or password. Password must be at least 8 characters.${RESET}"
    exit 1
  fi

  SSID="$NEW_SSID"
  PASSWORD="$NEW_PASSWORD"
  save_config
  echo -e "${GREEN}✅ Credentials updated and saved.${RESET}"
}

# ─── Show Status ───────────────────────────────
show_status() {

  # Find the active hotspot connection name
  HOTSPOT_CON=$(nmcli -g NAME connection show --active | grep -i Hotspot)

  if [[ -n "$HOTSPOT_CON" ]]; then
    # Get SSID from the connection profile
    SSID=$(nmcli -f 802-11-wireless.ssid connection show "$HOTSPOT_CON" | awk '{print $2}')

    # Find the device used for this connection
    DEVICE=$(nmcli -t -f NAME,DEVICE connection show --active | grep "$HOTSPOT_CON" | cut -d: -f2)

    echo -e "🔌 Connection Name: ${BOLD}$HOTSPOT_CON${RESET}"
    echo -e "📶 SSID: ${BOLD}${SSID}${RESET}"
    echo -e "📡 Interface: ${BOLD}${DEVICE}${RESET}"
  else
    echo -e "${YELLOW}⚠️  No active hotspot connection.${RESET}"
  fi
}

# ─── Help ──────────────────────────────────────
show_help() {
  echo -e "${BOLD}Usage:${RESET} hotspot {on|off|status|creds|help}"
  echo -e "  ${GREEN}on${RESET}     - Start Wi-Fi hotspot"
  echo -e "  ${RED}off${RESET}    - Stop Wi-Fi hotspot"
  echo -e "  ${BLUE}status${RESET} - Show current hotspot status"
  echo -e "  ${YELLOW}creds${RESET}  - Change SSID and password"
  echo -e "  help   - Show this help message"
}

# ─── Password ──────────────────────────────────────
password() {
  echo -e "${BOLD}🔐 Verifying with sudo...${RESET}"
  if sudo true; then
    HOTSPOT_CON=$(nmcli -g NAME connection show | grep -i Hotspot)

    if [[ -z "$HOTSPOT_CON" ]]; then
      echo -e "${YELLOW}⚠️  No hotspot connection profile found.${RESET}"
      return 1
    fi

    PSK=$(nmcli -s -g 802-11-wireless-security.psk connection show "$HOTSPOT_CON")

    if [[ -n "$PSK" ]]; then
      echo -e "${GREEN}🔑 Hotspot Password for '${SSID}':${RESET} ${BOLD}${PSK}${RESET}"
    else
      echo -e "${RED}❌ Password not set or not retrievable.${RESET}"
    fi
  else
    echo -e "${RED}❌ sudo verification failed.${RESET}"
  fi
}

# ─── Main ──────────────────────────────────────
case "$1" in
  on)      start_hotspot ;;
  off)     stop_hotspot ;;
  creds)   change_credentials ;;
  status)  show_status ;;
  help|"") show_help ;;
  -p)      password ;;
  *)
    echo -e "${RED}❌ Unknown option: $1${RESET}"
    show_help
    exit 1
    ;;
esac
