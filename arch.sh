#!/bin/bash

# Enable exit on error
set -e

# Variable
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

## Logiciels
DISCORD_VESKTOP=true
FIREFOX=true
VSCODE=true
ZSH=true
FOLDER_MANAGER=true
HYPRLAND=true

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

## Configuration
display "Start config"

log "Update"
sudo pacman -Syu --noconfirm
log "End Update"

log "Folder"
mkdir -p "$HOME/.config/"
mkdir -p "$HOME/Project_Epitech/"
mkdir -p "$HOME/Personnal_Project/"
log "End folder"

log "Font"
sudo pacman -S --noconfirm otf-font-awesome
sudo pacman -S --noconfirm ttf-font-awesome
sudo pacman -S --noconfirm noto-fonts-emoji
mkdir -p "$HOME/.config/fontconfig/"
cp "$SCRIPT_DIR/font/fonts.conf" "$HOME/.config/fontconfig/"
log "End font"

log "Default package"
sudo pacman -S --noconfirm base-devel git htop curl wofi kitty figlet eza thunar neovim
log "End default package"

log "Audio"
sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-pulse wireplumber
systemctl --user --now enable pipewire pipewire-pulse wireplumber
sudo pacman -S pavucontrol
log "End audio"

log "Bluetooth"
sudo pacman -S --noconfirm bluez bluez-utils bluez-deprecated-tools
systemctl --user --now enable bluetooth.service
systemctl start bluetooth.service
log "End bluetooth"

log "End config"

## Install yay
if ! command -v yay &>/dev/null; then
	display "Install Yay"
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si --noconfirm
	cd ../
	rm -rf yay
	log "End yay"
fi

## Language

if [ "$INSTALL_C" = true]; then
	display "C"
	sudo pacman -S --noconfirm gcc clang gcov
	log "End C"
fi

if [ "$INSTALL_JS_TS" = true]; then
	display "JS / TS"
	sudo pacman -S --noconfirm nodejs npm
	npm install -g typescript
	log "End JS / TS"
fi

if [ "$INSTALL_PYTHON" = true]; then
	display "Python"
	sudo pacman -S --noconfirm python python-pip
	log "End Python"
fi

if [ "$INSTALL_HASKELL" = true]; then
	display "Haskell"
	sudo pacman -S --noconfirm ghc stack
	log "End Haskell"
fi

if [ "$INSTALL_JAVA" = true]; then
	display "Java"
	sudo pacman -S --noconfirm gcc jdk-openjdk
	log "End Java"
fi

if [ "$INSTALL_NCURSES" = true]; then
	display "Ncurses"
	sudo pacman -S --noconfirm ncurses
	log "End Ncurses"
fi

if [ "$INSTALL_SFML" = true]; then
	display "SFML"
	sudo pacman -S --noconfirm sfml
	log "End SFML"
fi

if [ "$INSTALL_DOCKER" = true]; then
	display "Docker"
    	sudo pacman -S --noconfirm docker
    	sudo systemctl enable --now docker
    	sudo usermod -aG docker $USER
	sudo pacman -S --noconfirm docker-compose
    	log "End Docker"
fi

## SoftWare

if [ "$VSCODE" = true ]; then
	display "Vscode"
	yay -S --noconfirm visual-studio-code-bin
	log "End Vscode"
fi

if [ "$DISCORD_VESKTOP" = true ]; then
	display "Discord"
	yay -S --noconfirm vesktop
	log "End Discord"
fi

if [ "$FIREFOX" = true ]; then
	display "Firefox"
	sudo pacman -S --noconfirm firefox
	log "End Firefox"
fi

if [ "$ZSH" = true ]; then
	display "Zsh"
	sudo pacman -S --noconfirm zsh
	cp -r "$SCRIPT_DIR/zsh/.zsh/" "$HOME/"
	cp -r "$SCRIPT_DIR/zsh/.p10k.zsh" "$HOME/"
	cp -r "$SCRIPT_DIR/zsh/.zshrc" "$HOME/"
	log "End Zsh"
fi


if [ "$HYPRLAND" = true ]; then
	display "Hyprland"
	sudo pacman -S --noconfirm hypaper hypridle hyprlock waybar
	mkdir -p "$HOME/.config/hypr/"
	cp -r "$SCRIPT_DIR/hypr/fonts" "$SCRIPT_DIR/hypr/wallpaper" "$SCRIPT_DIR/hypr/hypridle.conf" "$SCRIPT_DIR/hypr/hyprland.conf" "$SCRIPT_DIR/hypr/hyprlock.conf" "$SCRIPT_DIR/hypr/hyprpaper.conf" "$HOME/.config/hypr/"
	log "End Hyprland"
fi

if [ "$FOLDER_MANAGER" = true ]; then
	display "Folder"
	sudo pacman -S --noconfirm ranger
	log "End folder"
fi


# End
END=$(date +%s)
echo "Installation took $(($END - $START)) seconds"
