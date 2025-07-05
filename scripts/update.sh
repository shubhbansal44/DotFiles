#!/bin/bash

# Dotfiles auto-sync script
# Syncs configs, home files, scripts, and assets
# Optional --push to commit and push to Git

DOTFILES_DIR="$HOME/Work/WORKSPACES/LINUX WORKSPACE/DotFiles"
CONFIG_DIR="$DOTFILES_DIR/config"
HOME_DIR="$DOTFILES_DIR/home"
ASSETS_DIR="$DOTFILES_DIR/assets"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

COMMIT_MSG=""
PUSH=false

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --push)
      PUSH=true
      ;;
    -*)
      echo "❌ Unknown flag: $arg"
      echo "Usage: update-dots [commit message] [--push]"
      exit 1
      ;;
    *)
      if [ -n "$COMMIT_MSG" ]; then
        echo "❌ Multiple commit messages provided or wrong usage."
        echo "Usage: update-dots [commit message] [--push]"
        exit 1
      fi
      COMMIT_MSG="$arg"
      ;;
  esac
done

# Validate commit message if push is requested
if $PUSH && [[ -z "$COMMIT_MSG" ]]; then
  COMMIT_MSG="update"
elif ! $PUSH && [[ -n "$COMMIT_MSG" ]]; then
  echo "⚠️ You provided a commit message without --push."
  echo "If you intend to commit, use: update-dots \"your message\" --push"
  echo "Aborting to avoid confusion."
  exit 1
fi

echo "🔄 Syncing existing config folders..."

if [ ! -d "$CONFIG_DIR" ]; then
  echo "❌ Config directory $CONFIG_DIR not found."
  exit 1
fi

for dir in "$CONFIG_DIR"/*; do
  name=$(basename "$dir")
  source_path="$HOME/.config/$name"
  if [ -d "$source_path" ]; then
    echo "📁 Updating $name config..."
    rsync -a --delete "$source_path/" "$CONFIG_DIR/$name/" || {
      echo "⚠️ Failed to sync $name config."
    }
  else
    echo "⚠️ Skipping $name — not found in ~/.config/"
  fi
done

echo "🏠 Syncing home dotfiles..."
if [ ! -d "$HOME_DIR" ]; then
  echo "❌ Home dotfiles directory $HOME_DIR not found."
  exit 1
fi

for file in "$HOME_DIR"/.*; do
  fname=$(basename "$file")
  [[ "$fname" == "." || "$fname" == ".." ]] && continue
  if [ -f "$HOME/$fname" ]; then
    cp "$HOME/$fname" "$HOME_DIR/$fname" || echo "⚠️ Could not copy $fname"
  else
    echo "⚠️ $fname not found in home directory, skipping"
  fi
done

if [ -f "$HOME/issue" ]; then
  cp "$HOME/issue" "$HOME_DIR/issue" || echo "⚠️ Failed to copy issue file"
else
  echo "⚠️ issue file not found"
fi

echo "🖼️ Syncing assets..."
mkdir -p "$ASSETS_DIR"

if [ -d "$HOME/Pictures/Wallpapers" ]; then
  cp -r "$HOME/Pictures/Wallpapers/" "$ASSETS_DIR/" || echo "⚠️ Failed to copy Wallpapers"
else
  echo "⚠️ Wallpapers directory not found"
fi

cp "$HOME/.cache/help-bash-descriptions.json" "$ASSETS_DIR/help-bash-descriptions.json" 2>/dev/null || echo "⚠️ help-bash-descriptions.json not found"
cp "$HOME/.cache/current_wallpaper_index" "$ASSETS_DIR/current_wallpaper_index" 2>/dev/null || echo "⚠️ current_wallpaper_index not found"

echo "⚙️ Syncing scripts..."
mkdir -p "$SCRIPTS_DIR"
cp ~/.local/bin/*.sh "$SCRIPTS_DIR" 2>/dev/null || echo "⚠️ No scripts found in ~/.local/bin/"

echo "📝 Regenerating pkglist.txt..."
if command -v pacman &>/dev/null; then
  pacman -Qqe > "$DOTFILES_DIR/pkglist.txt" || echo "⚠️ Failed to regenerate pkglist.txt"
else
  echo "❌ pacman not available. Cannot regenerate pkglist.txt"
fi

echo "✅ Dotfiles updated locally."

# Git push (optional)
if $PUSH; then
  echo "🔐 Validating sudo access for Git push..."
  if sudo -v; then
    echo "📦 Committing changes to Git..."
    cd "$DOTFILES_DIR" || { echo "❌ Could not access $DOTFILES_DIR"; exit 1; }
    git add .
    git commit -m "$COMMIT_MSG" || echo "⚠️ Git commit failed"
    git push origin main || echo "⚠️ Git push failed"
    echo "🚀 Changes pushed to remote repository."
  else
    echo "❌ Sudo validation failed. Cannot push to remote repository."
    exit 1
  fi
fi
