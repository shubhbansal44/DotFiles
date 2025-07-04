# 🛠️  Dotfiles for Arch Linux

Welcome to my custom dotfiles repository, built for minimal, modern, and functional **Arch Linux desktop setups** using [`Hyprland`](https://github.com/hyprwm/Hyprland), `waybar`, `kitty`, `rofi`, and many more.

This setup includes:

* Pre-configured system-wide tools and applications
* Beautiful theming
* Useful CLI scripts
* Automated installer
* Logical file structure for customization

---

## 📦 Features

* ⚡ **Fast installer** for all essential packages
* 🎨 Pre-configured Hyprland desktop with waybar, rofi, fastfetch, and more
* 🧰 Handy bash utilities (`wifi-connect`, `ask.sh`, `help-bash.sh`, etc.)
* 🖼️ Wallpapers + auto wallpaper cycler
* ✅ Built-in logging and confirmation handling
* 🧠 Modular and readable configuration

---

## 📸 Preview
![Preview of Setup](preview/installation.png)
![wallpaper1](preview/wallpaper1.png)
![wallpaper2](preview/wallpaper2.png)
![htop](preview/htop.png)
![cava](preview/cava.png)
![terminal-assistant](preview/terminal-assistant.png)
![xplr+ncdu](preview/xplr+ncdu.png)
![nautilus](preview/nautilus.png)

---

## 📁 Repository Structure

```bash
DotFiles/
├── assets/                          # Wallpapers, helper JSONs, and wallpaper state
│   ├── Wallpapers/                  # Images used by wallpaper scripts
│   └── help-bash-descriptions.json  # Prompt help definitions
│   └── current_wallpaper_inder      # Current wallpaper index for swwww
│
├── config/                 # Main config files for all apps (copied to ~/.config)
│   ├── hypr/               # Hyprland configs (hyprland.conf, hypridle, hyprlock)
│   ├── waybar/             # Waybar bar and style
│   ├── kitty/              # Kitty terminal configuration
│   ├── rofi/               # Rofi launcher styling
│   ├── starship/           # Starship shell prompt
│   ├── fastfetch/          # Fastfetch (like neofetch) JSON config
│   ├── dunst/              # Notification styling
│   ├── gtk-3.0/, gtk-4.0/  # GTK theming and settings
│   ├── qt5ct/, qt6ct/      # QT theming
│   ├── nwg-look/           # Style manager for wayland
│   ├── cava/, htop/, etc.  # Terminal visualizer and monitor
│   └── systemd/, wlogout/, xsettingsd/, ollama/, etc.
│
├── home/                   # Files copied directly to user home (~)
│   ├── .bashrc             # Shell config
│   ├── .bash_profile       # Bash login profile
│   ├── .gtkrc-2.0          # GTK2 theme fallback
│   ├── .xinitrc            # Hyprland launch via startx
│   └── issue               # TTY welcome message
│
├── installer/              # Contains the logic for installing and setting up
│   ├── core/               # Logging, utils, colors, UI helpers
│   ├── components/         # Scripts for copying configs, assets, etc.
│   └── install.sh          # Main installer script (entry point)
│
├── scripts/                # Executable bash utilities (installed to ~/.local/bin)
│   ├── ask.sh              # Confirmation prompt
│   ├── change_wallpaper.sh # Changes wallpaper from the Wallpapers folder
│   ├── help-bash.sh        # Shows bash command help from JSON
│   ├── songdetail.sh       # Music now playing info (if supported)
│   └── wifi-connect.sh     # TUI-based wifi connection script
│
├── pkglist.txt             # Complete list of packages to be installed
├── dotfiles_install.log    # Logs from the installation process
├── .gitignore
└── README.md
```

---

## ⚙️ Installation

### 🔧 1. Prerequisites

* Arch Linux system (clean recommended)
* Internet connection
* `git` installed

### 🚀 2. Clone the Repository

```bash
git clone https://github.com/shubhbansal44/DotFiles.git ~/DotFiles
cd ~/DotFiles/installer
```

### ▶️ 3. Run the Installer

```bash
chmod +x install.sh
sudo ./install.sh
```

This script will:

1. Check root and OS
2. Prompt you for actions
3. Install all packages
4. Set up YAY (AUR helper)
5. Copy dotfiles and configs
6. Install helper scripts to `~/.local/bin`
7. Configure wallpapers and theming

---

## ✅ After Installation

Once everything is installed:

* You can **start Hyprland** using:

  ```bash
  start
  ```

* All **scripts** are available via:

  ```bash
  ~/.local/bin/script-name.sh
  ```

* **Wallpapers** are stored in:

  ```bash
  ~/Pictures/Wallpapers/
  ```

* **Config files** are located in:

  ```bash
  ~/.config/
  ```

* **Shell configs** and `.xinitrc` are in your home:

  ```bash
  ~/.bashrc, ~/.xinitrc, ~/.bash_profile
  ```

---

## 🤝 FAQ

### ❓ Can I use this on other distros?

While it’s optimized for **Arch Linux**, many configs will work elsewhere — but the installer and package setup is Arch-specific.

### 🛠 How to customize my setup?

Just edit the files in:

* `~/.config/`
* `~/.bashrc`, `~/.xinitrc`, `~/.local/bin/`

Theme settings can be changed using `qt5ct`, `nwg-look`, and `gtk-settings`.

---

## ✨ Credits

**Created by:** [Shubh Bansal](https://github.com/shubhbansal44)

* 🔗 GitHub: [shubhbansal44](https://github.com/shubhbansal44)
* 🧠 Reddit: [u/Heaurision_Guy432](https://reddit.com/u/Heaurision_Guy432)
* 🐦 Twitter: [Heaurision Guy](https://twitter.com/ShubhBa88864619)

---

## ❤️ Contribute or Fork

Feel free to fork this repository, modify it for your setup, and star it if you found it helpful.

---

## 🚀 License

This project is under the **MIT License**. Use it freely, but give credit where it’s due!

---
