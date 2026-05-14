#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Detect package manager
detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    else
        log_error "No supported package manager found"
        exit 1
    fi
}

# Install tmux
install_tmux() {
    local pkg_manager="$1"
    log_info "Installing tmux via $pkg_manager..."
    case "$pkg_manager" in
        apt)    sudo apt-get update && sudo apt-get install -y tmux ;;
        yum)    sudo yum install -y tmux ;;
        dnf)    sudo dnf install -y tmux ;;
        pacman) sudo pacman -S --noconfirm tmux ;;
        zypper) sudo zypper install -y tmux ;;
    esac
}

# Install Tmux Plugin Manager (tpm)
install_tpm() {
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        log_info "tpm already installed"
        return
    fi
    
    log_info "Installing Tmux Plugin Manager (tpm)..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

# Copy tmux config
copy_config() {
    log_info "Copying tmux config to ~/"
    
    # Copy .tmux.conf
    if [ -f "$HOME/.tmux.conf" ]; then
        cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$(date +%Y%m%d%H%M%S)"
        log_info "Existing .tmux.conf backed up"
    fi
    cp "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"
    
    # Copy .tmux directory
    if [ -d "$SCRIPT_DIR/.tmux" ]; then
        cp -r "$SCRIPT_DIR/.tmux" "$HOME/"
    fi
}

# Main
main() {
    log_info "Starting tmux setup..."
    
    if command -v tmux &>/dev/null; then
        log_info "tmux already installed ($(tmux -V))"
    else
        install_tmux "$(detect_pkg_manager)"
    fi
    
    install_tpm
    copy_config
    
    log_info "Setup complete!"
    log_info "Run 'tmux' to start tmux, then press 'prefix + I' to install plugins"
}

main "$@"