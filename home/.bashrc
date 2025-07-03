#
# ~/.bashrc
#

# Exit if not running interactively
[[ $- != *i* ]] && return

# Set grep to use color in output
alias grep='grep --color=auto'

# Set prompt to show user, host, and current directory
PS1='[\u@\h \W]\$ '

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Alias to explain custom aliases and functions
alias help-bash='~/.local/bin/help-bash.sh'

# Alias to use Ollama AI model via terminal
alias ask="~/.local/bin/ask.sh"

# Connect to Wi-Fi using custom script
alias wifi-connect='~/.local/bin/wifi-connect.sh'

# Enable Wi-Fi and send a desktop notification
alias wifi-on='nmcli radio wifi on && echo "✅ Wi-Fi enabled" && notify-send "Wi-Fi" "✅ Enabled"'

# Disable Wi-Fi and send a desktop notification
alias wifi-off='nmcli radio wifi off && echo "📴 Wi-Fi disabled" && notify-send "Wi-Fi" "📴 Disabled"'

# Show current Wi-Fi device status
alias wifi-status='nmcli device status | grep wifi || echo "No Wi-Fi device found"'

# List available Wi-Fi networks
alias wifi-list='nmcli device wifi list | less'

# Show SSID of currently connected Wi-Fi
alias wifi-current='nmcli -t -f active,ssid dev wifi | grep yes | cut -d: -f2 || echo "Not connected"'

# Load Starship prompt with custom config
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
eval "$(starship init bash)"

# Start Hyprland window manager session
alias start='exec Hyprland'

# Basic alias for running fastfetch
alias f="fastfetch"

# Custom fastfetch display with logo and spacing
typefetch() {
    local padding_top=3
    for ((i = 0; i < padding_top; i++)); do echo ""; done
    fastfetch \
        --logo ~/.config/fastfetch/assets/fastfetch.txt \
        --logo-type file \
        --logo-padding-left 3
}

# Open Hyprland main config in VS Code
alias hdc='code ~/.config/hypr/hyprland.conf'

# Open Hyprlock config in VS Code
alias hkc='code ~/.config/hypr/hyprlock.conf'

# Open Hypridle config in VS Code
alias hic='code ~/.config/hypr/hypridle.conf'

# Open .bashrc in VS Code
alias brc='code ~/.bashrc'

# Source .bashrc to apply changes
alias sbrc='source ~/.bashrc'

# Open .bash_profile in VS Code
alias bfr='code ~/.bash_profile'

# Open Rofi config in VS Code
alias rfc='code ~/.config/rofi/config.rasi'

# Open Waybar config in VS Code
alias wrc='code ~/.config/waybar/config.jsonc'

# Open Waybar CSS in VS Code
alias wrcss='code ~/.config/waybar/style.css'

# Open Fastfetch config in VS Code
alias ffc='code ~/.config/fastfetch/config.jsonc'

# Open Starship config in VS Code
alias sst='code ~/.config/starship/starship.toml'

# Open Kitty terminal config in VS Code
alias ktc='code ~/.config/kitty/kitty.conf'

# Open Dunst notification config in VS Code
alias drc='code ~/.config/dunst/dunstrc'

# Open Cava audio visualizer config in VS Code
alias cvc='code ~/.config/cava/config'

# List active Node/JS-related servers with PID and port
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

# Kill process running on given port
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

# Use exa for improved ls with icons and sorting
alias ls='exa -al --icons --color=always --group-directories-first --time-style=iso'

# Tree view up to 2 levels deep
alias lst='exa -T --level=2 --icons --color=always'

# Show files with Git status
alias lsg='exa -al --git --icons --color=always --group-directories-first'

# List files sorted by size
alias lss='exa -al --sort=size --icons'

# Show only directories
alias lsd='exa -D --icons --group-directories-first'

# Display summary of a directory: size, files, and subdirs
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
