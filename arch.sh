#!/bin/bash

# Enable exit on error
set -e

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

USERNAME=$(id -u -n 1000)

if [[ "/home/$USERNAME" != "$HOME" ]]; then
    exit 1
fi

# Configuration
START=$(date +%s)
LOG_FILE="/var/log/installation.log"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CRONTAB_ROOT="$SCRIPT_DIR/crontab/root"

mkdir -p "$HOME/.config/" "$HOME/Epitech"
sudo pacman -S otf-font-awesome

# define what language you want to install
INSTALL_SFML=true
INSTALL_NCURSES=true;

INSTALL_JAVA=true
INSTALL_C=true
INSTALL_PYTHON=true
INSTALL_JS=true
INSTALL_TS=true

# software
INSTALL_DOCKER=true
INSTALL_DISCORD=false
INSTALL_TEAMS=true

# terminal
INSTALL_KITTY=true
INSTALL_HOW_MY_ZSH=true

# browser
INSTALL_FIREFOX=true
INSTALL_CHROME=false

# code editor
INSTALL_NEOVIM=true
INSTALL_VSCODE=true

# Update Submodule
git submodule update --init --recursive

# Update System
sudo pacman -Syu

# Install Dependencies
sudo pacman -S --noconfirm base-devel git

# Install Audio
sudo pacman -S pipewire pipewire-alsa pipewire-pulse wireplumber
systemctl --user --now enable pipewire pipewire-pulse wireplumber
sudo pacman -S pavucontrol

# Install Bluetooth
sudo pacman -S bluez bluez-utils bluez-deprecated-tools
sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service

# Install Docker
if [ "$INSTALL_DOCKER" = true ]; then
    display "Installing Docker"
    sudo pacman -S --noconfirm docker
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USERNAME
fi

# Install SFML
if [ "$INSTALL_SFML" = true ]; then
    display "Installing SFML"
    sudo pacman -S --noconfirm sfml
fi

# Install Ncurses
if [ "$INSTALL_NCURSES" = true ]; then
    display "Installing Ncurses"
    sudo pacman -S --noconfirm ncurses
fi

# Install Java
if [ "$INSTALL_JAVA" = true ]; then
    display "Installing Java"
    sudo pacman -S --noconfirm jdk-openjdk
fi

# Install C
if [ "$INSTALL_C" = true ]; then
    display "Installing C"
    sudo pacman -S --noconfirm gcc
fi

# Install Python
if [ "$INSTALL_PYTHON" = true ]; then
    display "Installing Python"
    sudo pacman -S --noconfirm python
fi

# Install JS
if [ "$INSTALL_JS" = true ]; then
    display "Installing JS"
    sudo pacman -S --noconfirm nodejs npm
fi

# Install TS
if [ "$INSTALL_TS" = true ]; then
    display "Installing TS"
    sudo npm install -g typescript
fi


# Install Kitty
if [ "$INSTALL_KITTY" = true ]; then
    display "Installing Kitty"
    sudo pacman -S --noconfirm kitty
fi

# Install Visual Studio Code
if [ "$INSTALL_VSCODE" = true ]; then
    display "Installing Visual Studio Code"
    sudo pacman -S --noconfirm code
fi

# Install Oh My Zsh
if [ "$INSTALL_HOW_MY_ZSH" = true ]; then
	display "ZSH"
	if [ ! "$(command -v zsh)" ]; then
		sudo pacman -S install zsh fontawesome-fonts    
	fi
	cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
	mkdir -p "$HOME/.zsh"
	cp "$SCRIPT_DIR/zsh/alias.zsh" "$HOME/.zsh"
	cp "$SCRIPT_DIR/zsh/env.zsh" "$HOME/.zsh"
	touch "$HOME/.zsh/kubectl.zsh"
fi

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
