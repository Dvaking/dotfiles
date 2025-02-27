#!/bin/bash

set -e

# Variable
START=$(date +%s)
LOG_FILE="/var/log/installation.log"
SCRIPT_DIR=$(cd -- "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
USERNAME="$(id -u -n 300)"


## Logiciel
INSTALL_FLATPAK=true

## Language
INSTALL_C=true
INSTALL_JS_TS=true
INSTALL_PYTHON=true
INSTALL_HASKELL=true
INSTALL_JAVA=true

INSTALL_NCURSES=true
INSTALL_SFML=true
INSTALL_DOCKER=true

## Software
DISCORD_VESKTOP=true
VSCODE=true
ZSH=true


log() {
	local message="$1"
	sudo sh -c "echo \"$(date + '%Y-%m-%d %H:%M:%S') $message\" >> \"$LOG_FILE\""
}

display() {
	local header_text="$1"
	local DISPLAY_COMMAND="echo"

	if command -v figlet &> /dev/null; then
		DISPLAY_COMMAND="figlet"
	fi

	sudo dnf install figlet -y
	DISPLAY_COMMAND="figlet"

	echo "---------------------------"
	$DISPLAY_COMMAND "$header_text"
	log "$header_text"
	echo "---------------------------"
}

# Configuration
log "Start configuration"

log "Start folder conf"
mkdir -p "$HOME/.config/"
mkdir -p "$HOME/Project_Epitech/"
mkdir -p "$HOME/Personnal_Project/"
log "End folder conf"

log "Start program conf"

# Update DNF configuration and system
sudo cp "$SCRIPT_DIR/dnf/dnf.conf" /etc/dnf/dnf.conf
sudo dnf update -y

sudo dnf -y install dnf-plugins-core

sudo dnf install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

sudo dnf install kitty -y
mkdir -p "$HOME/.config/kitty/"
cp "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/"


if ! command -v cargo &>/dev/null; then
    log "cargo and Rust"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rust.sh
    chmod +x /tmp/rust.sh
    /tmp/rust.sh -y
    rm -f /tmp/rust.sh
    source "$HOME/.cargo/env"
	cargo install --locked yazi-fm
	log "End Rust"
fi

sudo dnf install tlp tlp-rdw
sudo systemctl enable tlp.service
log "End tlp"

sudo dnf -y install rofi
log "End rofi"


log "End program conf"

cp

log "End configuration"


# Check if script run as root
if [[ $EUID -ne 1000 ]]; then
	echo "You must be a normal user to run this script, please run ./install.sh" 2>&1
	exit 1
fi


# Update fedora
sudo dnf update -y

# Install default App
sudo dnf install htop vim neovim curl -y

# Install git
if ! command -v git &>/dev/null; then
	display "GIT"
	sudo dnf install git -y
	log "End git"
fi

# Install language
if ["$INSTALL_C" == true]; then
	display "C"
	sudo dnf groupinstall "Development Tools" -y
	log "End C"
fi

if ["$INSTALL_JS_TS" == true]; then
	display "JS / TS"
	sudo dnf install nodejs npm -y
	sudo npm install -g typescript
	log "End JS / TS"
fi

if ["$INSTALL_PYTHON" == true]; then
	display "Python"
	sudo dnf install python3-pip -y
	log "End Python"
fi

if ["$INSTALL_HASKELL" == true]; then
	display "Haskell"
	sudo dnf install stack ghc haskell-platform -y
	log "End Haskell"
fi

if ["$INSTALL_JAVA" == true]; then
	display "Java"
	sudo dnf install java -y
	log "End Java"
fi

if ["$INSTALL_NCURSES" == true]
	display "Ncurses"
	sudo dnf install ncurses-devel -y
	log "End Ncurses"
fi

if ["$INSTALL_SFML" == true]
	display "SFML"
	sudo dnf install SFML-devel -y
	log "End SFML"
fi

if ["$INSTALL_DOCKER" == true]; then
	display "Docker"
	sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
	sudo systemctl enable --now docker
	grep -q "^docker:" /etc/group || sudo groupadd docker
	if ! groups $USER | grep -q "\bdocker\b"; then
  		sudo usermod -aG docker $USER
    	echo "Utilisateur ajouté au groupe docker. Déconnectez-vous et reconnectez-vous pour appliquer les changements."
	else
    		echo "L'utilisateur est déjà dans le groupe docker."
	fi
	sudo systemctl enable docker
fi

## Software

if ["$DISCORD_VESKTOP" == true]; then
	display "Vesktop"
	curl -L -o vesktop.rpm https://vencord.dev/download/vesktop/amd64/rpm
	sudo dnf install vesktop.rpm
	log "End Vesktop"
fi

if ["$VSCODE" == true]; then
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
	sudo dnf check-update
	sudo dnf -y install code
fi

if ["$ZSH" == true]; then
	display "ZSH"
	sudo dnf install -y zsh fontawesome-fonts

	cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
	mkdir -p "$HOME/.zsh"
	cp "$SCRIPT_DIR/zsh/alias.zsh" "$HOME/.zsh"
	cp "$SCRIPT_DIR/zsh/env.zsh" "$HOME/.zsh"
	touch "$HOME/.zsh/kubectl.zsh"
fi


## Install Hyprland

echo -n "Do you want to install Hyprland [y/N]: "
read -r response

response=${response,,}

if [[ "$response" == "y" || "$response" == "yes" ]]; then
	display "Hyprland"
	sudo dnf install hyprland -y
	sudo dnf install hyprland-devel -y
	sudo dnf install hyprpaper hypridle hyprlock waybar -y

	mkdir -p "$HOME/.config/hypr"

	cp -rf "$SCRIPT_DIR/hypr/*" "$HOME/.config/hypr/"

    display "Installation complete!"
else
    echo "Installation canceled."
fi

## Set shortcut on XFCE

echo -n "Are-you on XFCE [y/N]: "
read -r rtwo


if [[ "$rtwo" == "y" || "$rtwo" == "yes"]]
	sudo xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>r" -n -t string -s "kitty"
	sudo xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>f" -n -t string -s "rofi -show drun"
fi
