#
# ~/.bashrc
#

# Exit if not running interactively
[[ $- != *i* ]] && return

# ----------------------------- #
#        General Settings       #
# ----------------------------- #

# Colorize grep output
alias grep='grep --color=auto'

# Prompt Style: [user@host current-directory]$
PS1='[\u@\h \W]\$ '

# ----------------------------- #
#        Help Commands          #
# ----------------------------- #

# Explains each bashrc aliases and functions
alias help-bash='~/scripts/help-bash.sh'

# Ollama AI model for terminal integrated chats
alias ask="~/scripts/ask.sh"

# ----------------------------- #
#     Wi-Fi Utility Aliases     #
# ----------------------------- #

# Connect to Wi-Fi using custom script
alias wifi-connect='~/scripts/wifi-connect.sh'

# Turn Wi-Fi ON and send notification
alias wifi-on='nmcli radio wifi on && echo "✅ Wi-Fi enabled" && notify-send "Wi-Fi" "✅ Enabled"'

# Turn Wi-Fi OFF and send notification
alias wifi-off='nmcli radio wifi off && echo "📴 Wi-Fi disabled" && notify-send "Wi-Fi" "📴 Disabled"'

# Show Wi-Fi device status
alias wifi-status='nmcli device status | grep wifi || echo "No Wi-Fi device found"'

# List nearby Wi-Fi networks
alias wifi-list='nmcli device wifi list | less'

# Show currently connected Wi-Fi SSID
alias wifi-current='nmcli -t -f active,ssid dev wifi | grep yes | cut -d: -f2 || echo "Not connected"'

# ----------------------------- #
#        Starship Prompt        #
# ----------------------------- #

# Use custom Starship config
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
eval "$(starship init bash)"

# ----------------------------- #
#        Hyprland Start         #
# ----------------------------- #

# Start Hyprland session
alias start='exec Hyprland'

# ----------------------------- #
#          Fastfetch            #
# ----------------------------- #

# Quick alias for fastfetch
alias f="fastfetch"

# Fancy fastfetch with logo and padding
typefetch() {
    local padding_top=3
    for ((i = 0; i < padding_top; i++)); do echo ""; done
    fastfetch \
        --logo ~/.config/fastfetch/assets/fastfetch.txt \
        --logo-type file \
        --logo-padding-left 3
}

# ----------------------------- #
#     Config File Shortcuts     #
# ----------------------------- #

# Open Hyprland-related config files
alias hdc='code ~/.config/hypr/hyprland.conf'
alias hkc='code ~/.config/hypr/hyprlock.conf'
alias hic='code ~/.config/hypr/hypridle.conf'

# Bash configs
alias brc='code ~/.bashrc'
alias sbrc='source ~/.bashrc'
alias bfr='code ~/.bash_profile'

# Other configs
alias rfc='code ~/.config/rofi/config.rasi'
alias wrc='code ~/.config/waybar/config.jsonc'
alias wrcss='code ~/.config/waybar/style.css'
alias ffc='code ~/.config/fastfetch/config.jsonc'
alias sst='code ~/.config/starship/starship.toml'
alias ktc='code ~/.config/kitty/kitty.conf'
alias drc='code ~/.config/dunst/dunstrc'
alias cvc='code ~/.config/cava/config'

# ----------------------------- #
#     Server Port Utilities     #
# ----------------------------- #

# List all active JavaScript-related servers
listports() {
  echo -e "\033[1;34mListing active JS servers:\033[0m"
  printf "\033[1;33m%-8s %-8s %-20s\033[0m\n" "PID" "PORT" "COMMAND"
  echo "--------------------------------------------"

  sudo ss -ltnp 2>/dev/null | grep -E 'pid=[0-9]+' | while read -r line; do
    pid=$(echo "$line" | grep -oP 'pid=\K[0-9]+')
    port=$(echo "$line" | awk '{print $4}' | awk -F: '{print $NF}')
    cmd=$(ps -p "$pid" -o comm= 2>/dev/null)
    if [[ "$cmd" =~ ^(node|next|vite|bun|deno|nuxt|remix|svelte|react-scripts|next-server) ]]; then
      printf "%-8s %-8s %-20s\n" "$pid" "$port" "$cmd"
    fi
  done
}

# Kill server process by port
killport() {
  if [ -z "$1" ]; then
    echo -e "\033[1;31mUsage:\033[0m killport <port>"
    return 1
  fi

  pid=$(sudo ss -ltnp 2>/dev/null | grep ":$1" | grep -oP 'pid=\K[0-9]+')

  if [ -z "$pid" ]; then
    echo -e "\033[1;31mNo process found on port $1\033[0m"
  else
    cmd=$(ps -p "$pid" -o comm=)
    echo -e "\033[1;35mKilling\033[0m PID \033[1;36m$pid\033[0m (\033[1;33m$cmd\033[0m) on port \033[1;36m$1\033[0m..."
    kill -9 "$pid" && echo -e "\033[1;32m✓ Successfully killed.\033[0m" || echo -e "\033[1;31m✗ Failed to kill.\033[0m"
  fi
}

# ----------------------------- #
#         Directory View        #
# ----------------------------- #

# Enhanced ls using exa
alias ls='exa -al --icons --color=always --group-directories-first --time-style=iso'

# Tree view (2 levels)
alias lst='exa -T --level=2 --icons --color=always'

# Show with Git status
alias lsg='exa -al --git --icons --color=always --group-directories-first'

# Sort files by size
alias lss='exa -al --sort=size --icons'

# List only directories
alias lsd='exa -D --icons --group-directories-first'

# Directory summary with size and contents
dsummary() {
    local dir="${1:-.}"

    if [[ ! -d "$dir" ]]; then
        echo -e "\033[0;31m❌ '$dir' is not a directory\033[0m"
        return 1
    fi

    local size
    size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    local files=()
    local dirs=()

    while IFS= read -r -d '' entry; do
        if [[ -f "$entry" ]]; then
            files+=("$entry")
        elif [[ -d "$entry" ]]; then
            dirs+=("$entry")
        fi
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0 | sort -z)

    echo -e "\033[1;36m   📂 $dir\033[0m"
    echo -e "   ├───📦 -------->Total Size:"
    echo -e "   ├   ├── \033[1;35m$size\033[0m"
    echo -e "   ├───📄 ------------->Files: \033[1;32m${#files[@]}\033[0m"
    for f in "${files[@]}"; do
        echo -e "   ├   ├── \033[0;37m$(basename "$f")\033[0m"
    done
    echo -e "   ├───📁 ----------->Subdirs: \033[1;33m${#dirs[@]}\033[0m"
    for d in "${dirs[@]}"; do
        echo -e "   ├   ├── \033[1;34m$(basename "$d")\033[0m"
    done
    echo -e "   ├───🔚 ------------->\033[0;31mEnd"
}
