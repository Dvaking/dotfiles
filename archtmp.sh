#!/bin/bash

# Enable exit on error
set -e

# Variables
START=$(date +%s)
LOG_FILE="$HOME/install.log"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
USERNAME=$(id -un 1000)

# Configuration
START=$(date +%s)
LOG_FILE="/var/log/installation.log"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CRONTAB_ROOT="$SCRIPT_DIR/crontab/root"

## Langages
INSTALL_C=true
INSTALL_JS_TS=true
INSTALL_PYTHON=true
INSTALL_HASKELL=true
INSTALL_JAVA=true

INSTALL_NCURSES=true
INSTALL_SFML=true
INSTALL_DOCKER=true

# software
DISCORD_VESKTOP=false
INSTALL_TEAMS=true

INSTALL_FIREFOX=true
INSTALL_CHROME=false

INSTALL_NEOVIM=true
INSTALL_VSCODE=true

# terminal
ZSH=true

mkdir -p "$HOME/.config/" "$HOME/Epitech"
sudo pacman -S otf-font-awesome

# Function to log messages
log() {
    local message="$1"
    sudo sh -c "echo \"$(date +'%Y-%m-%d %H:%M:%S') $message\" >> \"$LOG_FILE\""
}

# Function for displaying headers
display() {
    local header_text="$1"
    local DISPLAY_COMMAND="echo"

    if [ "$(command -v figlet)" ]; then
        DISPLAY_COMMAND="figlet"
    fi

    echo "--------------------------------------"
    $DISPLAY_COMMAND "$header_text"
    log "$header_text"
    echo "--------------------------------------"
}

# Check if Script is Run as Root
if [[ $EUID -ne 1000 ]]; then
    echo "You must be a normal user to run this script, please run ./install.sh" 2>&1
    exit 1
fi

if [[ "/home/$USERNAME" != "$HOME" ]]; then
    exit 1
fi

# Update Submodule
git submodule update --init --recursive

# Update System
sudo pacman -Syu

# Installation de base
log "Installation de paquets de base"
sudo pacman -S --noconfirm base-devel git neovim htop curl rofi kitty figlet
mkdir -p "$HOME/.config/kitty/"
cp "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/"

# Installation de yay
if ! command -v yay &>/dev/null; then
    log "Installation de yay"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd - && rm -rf /tmp/yay
fi


# Install Audio
sudo pacman -S pipewire pipewire-alsa pipewire-pulse wireplumber
systemctl --user --now enable pipewire pipewire-pulse wireplumber
sudo pacman -S pavucontrol

# Install Bluetooth
sudo pacman -S bluez bluez-utils bluez-deprecated-tools
sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service

# Installation des langages
if [ "$INSTALL_C" = true ]; then
    display "C"
    sudo pacman -S --noconfirm gcc clang gcovr
    log "C installé"
fi

if [ "$INSTALL_JS_TS" = true ]; then
    display "JS / TS"
    sudo pacman -S --noconfirm nodejs npm
    npm install -g typescript
    log "JS / TS installé"
fi

if [ "$INSTALL_PYTHON" = true ]; then
    display "Python"
    sudo pacman -S --noconfirm python python-pip
    log "Python installé"
fi

if [ "$INSTALL_HASKELL" = true ]; then
    display "Haskell"
    sudo pacman -S --noconfirm ghc stack
    log "Haskell installé"
fi

if [ "$INSTALL_JAVA" = true ]; then
    display "Java"
    sudo pacman -S --noconfirm jdk-openjdk
    log "Java installé"
fi

if [ "$INSTALL_NCURSES" = true ]; then
    display "Ncurses"
    sudo pacman -S --noconfirm ncurses
    log "Ncurses installé"
fi

if [ "$INSTALL_SFML" = true ]; then
    display "SFML"
    sudo pacman -S --noconfirm sfml
    log "SFML installé"
fi

if [ "$INSTALL_DOCKER" = true ]; then
    display "Docker"
    sudo pacman -S --noconfirm docker
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    log "Docker installé"
fi


# Install Visual Studio Code
if [ "$INSTALL_VSCODE" = true ]; then
    display "Visual Studio Code"
    sudo pacman -S --noconfirm code
fi

# Install Oh My Zsh
if [ "$ZSH" = true ]; then
    display "ZSH"
    sudo pacman -S --noconfirm zsh
    cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
    log "ZSH installé"
fi

# Installation des logiciels
# Install Firefox
if [ "$INSTALL_FIREFOX" = true ]; then
    display "Installing Firefox"
    sudo pacman -S --noconfirm firefox
fi

# Install Chrome
if [ "$INSTALL_CHROME" = true ]; then
    display "Installing Chrome"
    sudo pacman -S --noconfirm google-chrome
fi

# Install Neovim
if [ "$INSTALL_NEOVIM" = true ]; then
    display "Installing Neovim"
    sudo pacman -S --noconfirm neovim
fi

if [ "$DISCORD_VESKTOP" = true ]; then
    display "Vesktop"
    yay -S --noconfirm vesktop-bin
    log "Vesktop installé"
fi

# Install rofi
display "Installing Rofi"
sudo pacman -S --noconfirm rofi

# Install criterion
display "Installing Criterion"
"$SCRIPT_DIR/criterion/install_criterion.sh"

while true; do
	read -p "Download hyprland conf ? [y/n]" rep
	case $rep in
		[Yy]* )
			echo "Start init"
			mkdir -p "$HOME/.config"
			mkdir -p "$HOME/.config/hypr"
			cp -r "hypr/*" "$HOME/.config/hypr/"
			pacman -S hyprpaper waypaper hypridle hyprlock waybar
			break
			;;
		[Nn]* )
			echo "Init"
			break
			;;
		* )
			echo "Download hyprland conf ? [y/n]"
			;;
	esac
done

# End
END=$(date +%s)
echo "Installation took $(($END - $START)) seconds"
