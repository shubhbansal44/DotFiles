# ========== BASIC ENVIRONMENT ==========
export ZSH="$HOME/.config/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"
export LANG=en_US.UTF-8
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml

eval "$(starship init zsh)"

# ========== OH MY ZSH ==========
ZSH_THEME=""  # empty, because starship handles prompt
plugins=(zsh-autosuggestions zsh-syntax-highlighting)

ENABLE_CORRECTION="true"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt append_history
setopt hist_ignore_all_dups

source $ZSH/oh-my-zsh.sh
source ${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ========== ALIASES ==========
alias grep='grep --color=auto'

# System & network
alias update='sudo pacman -Syu'
alias forceupdate='sudo pacman -Syyu'
alias update-dots='~/.local/bin/update.sh'

alias wifi-connect='~/.local/bin/wifi-connect.sh'
alias wifi-on='nmcli radio wifi on && echo "✅ Wi-Fi enabled" && notify-send "Wi-Fi" "✅ Enabled"'
alias wifi-off='nmcli radio wifi off && echo "📴 Wi-Fi disabled" && notify-send "Wi-Fi" "📴 Disabled"'
alias wifi-status='nmcli device status | grep wifi || echo "No Wi-Fi device found"'
alias wifi-list='nmcli device wifi list | less'
alias wifi-current='nmcli -t -f active,ssid dev wifi | grep yes | cut -d: -f2 || echo "Not connected"'
alias hotspot='~/.local/bin/hotspot.sh'

# Tools & utils
alias help-bash='~/.local/bin/help-bash.sh'
alias ask="~/.local/bin/ask.sh"
alias man="~/.local/bin/man-fzf.sh"
alias tldr="~/.local/bin/tldr-fzf.sh"
alias f="fastfetch --logo-padding-left 3 --logo-padding-top 1"
alias start='exec Hyprland'

# Config editing
alias hdc='code ~/.config/hypr/hyprland.conf'
alias hkc='code ~/.config/hypr/hyprlock.conf'
alias hic='code ~/.config/hypr/hypridle.conf'
alias rfc='code ~/.config/rofi/config.rasi'
alias wrc='code ~/.config/waybar/config.jsonc'
alias wrcss='code ~/.config/waybar/style.css'
alias ffc='code ~/.config/fastfetch/config.jsonc'
alias sst='code ~/.config/starship/starship.toml'
alias ktc='code ~/.config/kitty/kitty.conf'
alias drc='code ~/.config/dunst/dunstrc'
alias cvc='code ~/.config/cava/config'
alias brc='code ~/.bashrc'
alias orc='code ~/.zshrc'
alias sbrc='source ~/.bashrc'
alias sorc='source ~/.zshrc'
alias bfr='code ~/.bash_profile'

# Exa replacements for ls
alias ls='exa -al --icons --color=always --group-directories-first --time-style=iso'
alias lst='exa -T --level=2 --icons --color=always'
alias lsg='exa -al --git --icons --color=always --group-directories-first'
alias lss='exa -al --sort=size --icons'
alias lsd='exa -D --icons --group-directories-first'

# ========== FUNCTIONS ==========

typefetch() {
  local padding_top=3
  for ((i = 0; i < padding_top; i++)); do echo ""; done
  fastfetch \
    --logo ~/.config/fastfetch/assets/fastfetch.txt \
    --logo-type file \
    --logo-padding-left 3
}

flex() {
  fastfetch \
    --logo ~/.config/fastfetch/assets/flex.txt \
    --logo-type file \
    --logo-padding-left 3
}

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
    [[ -f "$entry" ]] && files+=("$entry")
    [[ -d "$entry" ]] && dirs+=("$entry")
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0 | sort -z)

  echo -e "\033[1;36m   📂 $dir\033[0m"
  echo -e "   ├───📦 -------->Total Size:"
  echo -e "   ├   ├── \033[1;35m$size\033[0m"
  echo -e "   ├───📄 ------------->Files: \033[1;32m${#files[@]}\033[0m"
  for f in "${files[@]}"; do echo -e "   ├   ├── \033[0;37m$(basename "$f")\033[0m"; done
  echo -e "   ├───📁 ----------->Subdirs: \033[1;33m${#dirs[@]}\033[0m"
  for d in "${dirs[@]}"; do echo -e "   ├   ├── \033[1;34m$(basename "$d")\033[0m"; done
  echo -e "   ├───🔚 ------------->\033[0;31mEnd"
}

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

# ========== FZF-HELPERS ==========

fzf_cd_handler() {
  local BASE_DIR="$HOME"
  local dir
  dir=$(fd . "$BASE_DIR" --type d --exclude .git --exclude node_modules \
    | fzf --height=40% --layout=reverse --border \
          --preview 'exa -T --level=2 --icons --color=always {}' \
          --preview-window=right:50%:wrap)

  if [[ -n "$dir" ]]; then
    LBUFFER="cd \"$dir\""
  else
    LBUFFER="cd "
  fi
  zle reset-prompt
}
zle -N fzf_cd_handler

fzf_kill_handler() {
  local pids
  pids=$(ps -eo pid,ppid,etime,%cpu,%mem,user,comm --no-headers \
    | awk '{printf "%-6s %-6s %-10s %-5s %-5s %-15s %s\n", $1, $2, $3, $4, $5, $6, $7}' \
    | grep -v "^ *$$" | grep -v "fzf" \
    | fzf --multi --height=40% --layout=reverse --border \
          --header='PID    PPID   ELAPSED    CPU   MEM   USER            COMMAND' \
          --preview='pid=$(echo {} | awk "{print \$1}"); \
            ps -p $pid -o pid,ppid,cmd,%cpu,%mem,etime --sort=-%cpu --no-headers \
            | awk "{ \
              printf \"\n🔹 PID      : %s\n🔹 PPID     : %s\n🔹 CPU      : %s%%\n🔹 MEM      : %s%%\n🔹 ELAPSED  : %s\n🔹 CMD      : %s\n\", \
              \$1, \$2, \$4, \$5, \$6, substr(\$3, 1, 100) \
            }"' \
          --preview-window=right:50%:wrap \
    | awk '{print $1}' | xargs) || return
  [[ -n "$pids" ]] && LBUFFER="kill -9 $pids"
  zle reset-prompt
}
zle -N fzf_kill_handler

smart_tab_handler() {
  if [[ "$LBUFFER" == "cd" || "$LBUFFER" == "cd " ]]; then
    zle fzf_cd_handler
  elif [[ "$LBUFFER" == "kill -9" || "$LBUFFER" == "kill -9 " ]]; then
    zle fzf_kill_handler
  else
    zle expand-or-complete  # default Tab completion
  fi
}
zle -N smart_tab_handler
bindkey '^I' smart_tab_handler  # '^I' is Tab
