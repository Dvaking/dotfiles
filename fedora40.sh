#!/bin/bash

set -e

# Variables
START=$(date +%s)
LOG_FILE="/var/log/installation.log"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
CRONTAB_ROOT="$SCRIPT_DIR/crontab/root"
USERNAME=$(id -un 1000)

## Logiciels
INSTALL_FLATPAK=true

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
VSCODE=true
ZSH=true

log() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") $message" | sudo tee -a "$LOG_FILE" > /dev/null
}

display() {
    local header_text="$1"
    local DISPLAY_COMMAND="echo"

    if command -v figlet &> /dev/null; then
        DISPLAY_COMMAND="figlet"
    else
        sudo dnf install -y figlet
        DISPLAY_COMMAND="figlet"
    fi

    echo "---------------------------"
    $DISPLAY_COMMAND "$header_text"
    log "$header_text"
    echo "---------------------------"
}

# Configuration
log "Début de la configuration"

log "Création des dossiers"
mkdir -p "$HOME/.config/"
mkdir -p "$HOME/Project_Epitech/"
mkdir -p "$HOME/Personnal_Project/"
log "Dossiers créés"

log "Mise à jour de DNF et installation de paquets de base"
sudo cp "$SCRIPT_DIR/dnf/dnf.conf" /etc/dnf/dnf.conf || log "Erreur lors de la copie du fichier dnf.conf"
sudo dnf update -y
sudo dnf install -y dnf-plugins-core

# Installation de Flatpak
if [ "$INSTALL_FLATPAK" = true ]; then
    sudo dnf install -y flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

# Installation des outils de développement
sudo dnf install -y kitty htop vim neovim curl rofi
mkdir -p "$HOME/.config/kitty/"
cp "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/"
sudo dnf groupinstall -y "Development Tools"

# Installation de Rust et cargo si absent
if ! command -v cargo &>/dev/null; then
    log "Installation de Rust et Cargo"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    cargo install --locked yazi-fm
    log "Rust installé"
fi

sudo dnf install -y tlp tlp-rdw
sudo systemctl enable tlp.service

# Installation de Git
if ! command -v git &>/dev/null; then
    display "GIT"
    sudo dnf install -y git
    log "Git installé"
fi

# Installation des langages
if [ "$INSTALL_C" = true ]; then
    display "C"
    sudo dnf install -y gcovr clang
    sudo dnf group install -y 'C Development Tools and Libraries'
    "$SCRIPT_DIR/criterion/install_criterion.sh"
    log "C installé"
fi

if [ "$INSTALL_JS_TS" = true ]; then
    display "JS / TS"
    sudo dnf install -y nodejs npm
    sudo npm install -g typescript
    log "JS / TS installé"
fi

if [ "$INSTALL_PYTHON" = true ]; then
    display "Python"
    sudo dnf install -y python3-pip
    log "Python installé"
fi

if [ "$INSTALL_HASKELL" = true ]; then
    display "Haskell"
    sudo dnf install -y stack ghc haskell-platform
    log "Haskell installé"
fi

if [ "$INSTALL_JAVA" = true ]; then
    display "Java"
    sudo dnf install -y java-latest-openjdk-devel
    log "Java installé"
fi

if [ "$INSTALL_NCURSES" = true ]; then
    display "Ncurses"
    sudo dnf install -y ncurses-devel
    log "Ncurses installé"
fi

if [ "$INSTALL_SFML" = true ]; then
    display "SFML"
    sudo dnf install -y SFML-devel
    log "SFML installé"
fi

if [ "$INSTALL_DOCKER" = true ]; then
    display "Docker"
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable --now docker
    grep -q "^docker:" /etc/group || sudo groupadd docker
    if ! groups $USER | grep -q "\bdocker\b"; then
        sudo usermod -aG docker $USER
        echo "Utilisateur ajouté au groupe docker. Déconnectez-vous et reconnectez-vous pour appliquer les changements."
    fi
    log "Docker installé"
fi

# Installation des logiciels
if [ "$DISCORD_VESKTOP" = true ]; then
    display "Vesktop"
    curl -L -o vesktop.rpm https://vencord.dev/download/vesktop/amd64/rpm
    sudo dnf install -y vesktop.rpm
    log "Vesktop installé"
fi

if [ "$VSCODE" = true ]; then
    display "VS Code"
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo
    sudo dnf install -y code
    log "VS Code installé"
fi

if [ "$ZSH" = true ]; then
    display "ZSH"
    sudo dnf install -y zsh fontawesome-fonts
    cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
    mkdir -p "$HOME/.zsh"
    cp "$SCRIPT_DIR/zsh/alias.zsh" "$HOME/.zsh"
    cp "$SCRIPT_DIR/zsh/env.zsh" "$HOME/.zsh"
    touch "$HOME/.zsh/kubectl.zsh"
    log "ZSH installé"
fi

# Installation de Hyprland
read -rp "Voulez-vous installer Hyprland ? [y/N]: " response
if [[ "${response,,}" =~ ^(y|yes)$ ]]; then
    display "Hyprland"
    sudo dnf install -y hyprland hyprland-devel hyprpaper hypridle hyprlock waybar
    mkdir -p "$HOME/.config/hypr"
    cp -rf "$SCRIPT_DIR/hypr/"* "$HOME/.config/hypr/"
    log "Hyprland installé"
fi

# Configuration XFCE
read -rp "Voulez-vous configurer des raccourcis clavier pour XFCE ? [y/N]: " rtwo
if [[ "$rtwo" == "y" || "$rtwo" == "yes" ]]; then
    sudo xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>r" -n -t string -s "kitty"
    sudo xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>f" -n -t string -s "rofi -show drun"
    log "Raccourcis XFCE configurés"
fi
