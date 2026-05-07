#!/bin/bash
# Install zsh, oh-my-zsh, plugins, and apply config

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
ZSH_CUSTOM_PLUGINS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

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

# Install zsh
install_zsh() {
    local pkg_manager="$1"
    log_info "Installing zsh via $pkg_manager..."
    case "$pkg_manager" in
        apt)    sudo apt-get update && sudo apt-get install -y zsh ;;
        yum)    sudo yum install -y zsh ;;
        dnf)    sudo dnf install -y zsh ;;
        pacman) sudo pacman -S --noconfirm zsh ;;
        zypper) sudo zypper install -y zsh ;;
    esac
}

# Install oh-my-zsh (with mirror fallback)
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_warn "oh-my-zsh already installed at ~/.oh-my-zsh"
        return
    fi

    log_info "Installing oh-my-zsh via git clone..."

    local mirrors=(
        "https://gitee.com/mirrors/oh-my-zsh.git"
        "https://gitclone.com/github.com/ohmyzsh/ohmyzsh.git"
        "https://github.com/ohmyzsh/ohmyzsh.git"
    )

    for mirror in "${mirrors[@]}"; do
        log_info "Trying: $mirror"
        local timeout=10
        [[ "$mirror" == *"gitee"* ]] && timeout=30

        if timeout "$timeout" git clone --depth=1 --config core.autocrlf=false \
            "$mirror" "$HOME/.oh-my-zsh" 2>/dev/null; then
            log_info "oh-my-zsh cloned successfully from $mirror"
            return
        fi
        log_warn "Mirror failed or timed out (${timeout}s), trying next..."
        rm -rf "$HOME/.oh-my-zsh" 2>/dev/null
    done

    log_error "All mirrors failed. Try manually:"
    log_error "  git clone --depth=1 https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh"
    exit 1
}

# Install external plugins
install_external_plugins() {
    log_info "Installing external plugins..."

    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions" ]; then
        log_info "Installing zsh-autosuggestions..."
        git clone --depth=1 https://gitee.com/mirrors/zsh-autosuggestions.git \
            "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions" 2>/dev/null || \
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
            "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions"
    else
        log_info "zsh-autosuggestions already installed"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting" ]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone --depth=1 https://gitee.com/mirrors/zsh-syntax-highlighting.git \
            "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting" 2>/dev/null || \
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
            "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting"
    else
        log_info "zsh-syntax-highlighting already installed"
    fi
}

# Deploy .zshrc
deploy_zshrc() {
    log_info "Deploying .zshrc..."
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
        log_info "Existing .zshrc backed up"
    fi
    cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
    log_info ".zshrc deployed to ~/.zshrc"
}

# Set zsh as default shell
set_default_shell() {
    if [ "$(basename "$SHELL")" = "zsh" ]; then
        log_info "zsh is already the default shell"
        return
    fi
    log_info "Setting zsh as default shell..."
    chsh -s "$(command -v zsh)"
    log_info "Default shell changed. Restart terminal or run 'zsh' to start."
}

# Main
main() {
    log_info "Starting zsh + oh-my-zsh setup..."

    if command -v zsh &>/dev/null; then
        log_info "zsh is already installed ($(zsh --version))"
    else
        install_zsh "$(detect_pkg_manager)"
    fi

    install_oh_my_zsh
    install_external_plugins
    deploy_zshrc
    set_default_shell

    log_info "Setup complete! Launching zsh..."
    exec zsh -l
}

main "$@"
