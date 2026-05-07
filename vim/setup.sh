#!/bin/bash
# Install vim, plugins, and deploy config

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

# Make nvm node accessible to vim (symlink to /usr/local/bin)
ensure_node_for_vim() {
    # Load nvm if available (non-interactive shells don't auto-load it)
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        . "$HOME/.nvm/nvm.sh"
    fi

    if command -v node &>/dev/null && node --version &>/dev/null; then
        local node_path
        node_path="$(command -v node)"
        log_info "node found: $node_path ($(node --version))"

        # If node is from nvm, create symlinks for vim to find it
        if [[ "$node_path" == *".nvm"* ]]; then
            log_info "nvm node detected, creating symlinks..."
            sudo ln -sf "$node_path" /usr/local/bin/node 2>/dev/null || \
                ln -sf "$node_path" "$HOME/.local/bin/node" 2>/dev/null || true
            local npm_path
            npm_path="$(command -v npm)"
            sudo ln -sf "$npm_path" /usr/local/bin/npm 2>/dev/null || \
                ln -sf "$npm_path" "$HOME/.local/bin/npm" 2>/dev/null || true
            log_info "Symlinks created for vim"
        fi
        return
    fi

    log_error "node not found. Install via: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && nvm install 18"
    exit 1
}

# Install vim and system tools
install_vim() {
    local pkg_manager="$1"
    log_info "Installing vim and system tools via $pkg_manager..."

    local base_pkgs=(
        vim
        git
        curl
        cscope
        exuberant-ctags
        python3
        python3-pip
        rustc
        cargo
        fzf
    )

    case "$pkg_manager" in
        apt)
            sudo apt-get update
            sudo apt-get install -y "${base_pkgs[@]}"
            ;;
        yum)
            sudo yum install -y "${base_pkgs[@]}" 2>/dev/null || true
            ;;
        dnf)
            sudo dnf install -y "${base_pkgs[@]}" 2>/dev/null || true
            ;;
        pacman)
            sudo pacman -S --noconfirm "${base_pkgs[@]}" 2>/dev/null || true
            ;;
        zypper)
            sudo zypper install -y "${base_pkgs[@]}" 2>/dev/null || true
            ;;
    esac

    # Install powerline via pip
    if ! python3 -c "import powerline" 2>/dev/null; then
        log_info "Installing powerline-status via pip..."
        pip3 install powerline-status 2>/dev/null ||
            python3 -m pip install --user powerline-status 2>/dev/null || true
    fi

    log_info "vim and dependencies installed"
}

# Install vim-plug
install_vim_plug() {
    if [ -f "$HOME/.vim/autoload/plug.vim" ]; then
        log_info "vim-plug already installed"
        return
    fi

    log_info "Installing vim-plug from GitHub..."
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" 2>/dev/null || {
        log_error "Failed to install vim-plug. Try manually:"
        log_error "  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
        exit 1
    }
    log_info "vim-plug installed successfully"
}

# Deploy .vimrc and .vim/ directory
deploy_vim_config() {
    log_info "Deploying .vimrc and .vim/..."

    # Deploy .vimrc
    if [ -f "$HOME/.vimrc" ]; then
        cp "$HOME/.vimrc" "$HOME/.vimrc.bak.$(date +%Y%m%d%H%M%S)"
        log_info "Existing .vimrc backed up"
    fi
    cp "$SCRIPT_DIR/.vimrc" "$HOME/.vimrc"
    log_info ".vimrc deployed"

    # Deploy .vim/ directory (merge, preserve plugged/)
    if [ -d "$SCRIPT_DIR/.vim" ]; then
        # Create target directory if not exists
        mkdir -p "$HOME/.vim"

        # If plugged/ exists in target but not in source, preserve it
        if [ -d "$HOME/.vim/plugged" ] && [ ! -d "$SCRIPT_DIR/.vim/plugged" ]; then
            # Copy everything except plugged/
            rsync -av --exclude='plugged/' "$SCRIPT_DIR/.vim/" "$HOME/.vim/" 2>/dev/null || \
                cp -rn "$SCRIPT_DIR/.vim/." "$HOME/.vim/" 2>/dev/null || true
        else
            cp -rn "$SCRIPT_DIR/.vim/." "$HOME/.vim/" 2>/dev/null || true
        fi
        log_info ".vim/ directory deployed"
    fi
}

# Install plugins via SSH directly (bypass PlugInstall network issues)
install_plugins() {
    log_info "Installing vim plugins via SSH..."

    local base="$HOME/.vim/plugged"
    mkdir -p "$base"

    # Plugin list: "repo-path branch" (branch empty = default)
    local -a plugins=(
        "vim-airline/vim-airline "
        "lilydjwg/colorizer "
        "kshenoy/vim-signature "
        "jiangmiao/auto-pairs "
        "preservim/NERDTree "
        "fholgado/minibufexpl.vim "
        "vim-scripts/grep.vim "
        "vim-scripts/comments.vim "
        "vim-scripts/indentpython.vim "
        "Lokaltog/powerline "
        "rust-lang/rust.vim "
        "dense-analysis/ale "
        "neoclide/coc.nvim release"
        "autozimu/LanguageClient-neovim "
        "junegunn/fzf "
    )

    local failed=0
    for entry in "${plugins[@]}"; do
        read -r repo branch <<< "$entry"
        local name
        name="$(basename "$repo")"

        # Skip if already installed with correct branch
        if [ -d "$base/$name/.git" ]; then
            if [ -z "$branch" ] || (cd "$base/$name" && git branch --show-current 2>/dev/null | grep -qx "$branch"); then
                log_info "  ✓ $name (already installed)"
                continue
            else
                log_info "  → $name branch mismatch, reinstalling..."
                rm -rf "$base/$name"
            fi
        fi

        log_info "  → Cloning $repo${branch:+ (branch: $branch)}..."
        local branch_arg=""
        [ -n "$branch" ] && branch_arg="--branch $branch"
        if timeout 60 git clone --depth=1 $branch_arg "git@github.com:$repo.git" "$base/$name" 2>&1; then
            log_info "  ✓ $name"
        else
            log_warn "  ✗ $name (clone failed)"
            failed=1
        fi
    done

    # Build coc.nvim
    if [ -d "$base/coc.nvim" ]; then
        local coc_dir="$base/coc.nvim"
        if [ ! -f "$coc_dir/build/index.js" ]; then
            log_info "  → Building coc.nvim (npm ci && npm run build)..."
            (cd "$coc_dir" && npm ci && npm run build && \
                log_info "  ✓ coc.nvim built") || \
                log_warn "  ✗ coc.nvim build failed, run: cd ~/.vim/plugged/coc.nvim && npm ci && npm run build"
        else
            log_info "  ✓ coc.nvim (already built)"
        fi
    fi

    if [ $failed -eq 1 ]; then
        log_warn "Some plugins failed. Check SSH key and network."
    else
        log_info "All plugins installed successfully!"
    fi
}

# Main
main() {
    log_info "Starting vim setup..."

    if command -v vim &>/dev/null; then
        log_info "vim is already installed ($(vim --version | head -1))"
    else
        install_vim "$(detect_pkg_manager)"
    fi

    ensure_node_for_vim
    install_vim_plug
    deploy_vim_config
    install_plugins

    log_info "Setup complete!"
    log_info "Plugins installed: ~/.vim/plugged/"
    log_info "To reinstall: vim +PlugInstall"
}

main "$@"
