#!/bin/bash

# install.sh - Dotfiles installer
# Idempotent, environment-aware (macOS local or container)
# Usage: ./install.sh [--local | --container | --auto]

set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status()  { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }

# --- Script location ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Environment detection ---
detect_environment() {
    if [[ "$1" == "--local" ]]; then
        ENV="local"
    elif [[ "$1" == "--container" ]]; then
        ENV="container"
    elif [[ -n "$REMOTE_CONTAINERS" ]] || [[ -n "$CODESPACES" ]] || [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null; then
        ENV="container"
    elif [[ "$(uname)" == "Darwin" ]]; then
        ENV="local"
    else
        # Linux but not in a container — treat as container-style (apt-based)
        ENV="container"
    fi
}

detect_environment "$1"

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║            Dotfiles Installation               ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
print_status "Environment: ${ENV}"
echo ""

# ==============================================================================
# Dependencies
# ==============================================================================

install_deps_local() {
    print_status "Checking for Homebrew..."

    if ! command -v brew &>/dev/null; then
        print_warning "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        print_success "Homebrew installed"
    else
        print_success "Homebrew found"
    fi

    print_status "Installing Homebrew dependencies..."
    local deps=("neovim" "tmux" "ripgrep" "fd" "fzf" "luarocks")
    for dep in "${deps[@]}"; do
        if brew list "$dep" &>/dev/null; then
            print_success "$dep already installed"
        else
            brew install "$dep"
            print_success "$dep installed"
        fi
    done
}

install_deps_container() {
    print_status "Installing dependencies via apt..."

    # Only run apt-get update if we need to install something
    local deps=("neovim" "tmux" "zsh" "ripgrep" "fd-find" "fzf" "git" "curl" "unzip")
    local to_install=()

    for dep in "${deps[@]}"; do
        if dpkg -s "$dep" &>/dev/null; then
            print_success "$dep already installed"
        else
            to_install+=("$dep")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        sudo apt-get update -qq
        sudo apt-get install -y -qq "${to_install[@]}"
        print_success "Installed: ${to_install[*]}"
    fi

    # Neovim from apt is often outdated; install latest stable if version < 0.11
    local nvim_major nvim_minor
    nvim_major=$(nvim --version 2>/dev/null | head -1 | sed -n 's/.*v\([0-9]*\)\.\([0-9]*\).*/\1/p' || echo "0")
    nvim_minor=$(nvim --version 2>/dev/null | head -1 | sed -n 's/.*v\([0-9]*\)\.\([0-9]*\).*/\2/p' || echo "0")
    if [[ "$nvim_major" -eq 0 ]] && [[ "$nvim_minor" -lt 11 ]]; then
        print_warning "Neovim from apt is too old (need 0.11+). Installing from GitHub releases..."
        local arch
        arch=$(uname -m)
        if [[ "$arch" == "x86_64" ]]; then
            arch="linux-x86_64"
        elif [[ "$arch" == "aarch64" ]]; then
            arch="linux-arm64"
        fi
        curl -fsSL "https://github.com/neovim/neovim/releases/download/stable/nvim-${arch}.tar.gz" | sudo tar xz -C /opt/
        sudo ln -sf "/opt/nvim-${arch}/bin/nvim" /usr/local/bin/nvim
        print_success "Neovim (stable) installed to /usr/local/bin/nvim"
    fi
}

if [[ "$ENV" == "local" ]]; then
    install_deps_local
else
    install_deps_container
fi

# ==============================================================================
# Oh My Zsh
# ==============================================================================

print_status "Checking oh-my-zsh..."

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_success "oh-my-zsh already installed"
else
    print_warning "Installing oh-my-zsh (unattended)..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "oh-my-zsh installed"
fi

# ==============================================================================
# Symlink Configs
# ==============================================================================

# Helper: create symlink, backing up existing target
link_config() {
    local src="$1"
    local dst="$2"

    # Ensure parent directory exists
    mkdir -p "$(dirname "$dst")"

    if [[ -L "$dst" ]]; then
        local current
        current="$(readlink "$dst")"
        if [[ "$current" == "$src" ]]; then
            print_success "$(basename "$dst") already linked"
            return
        fi
        rm "$dst"
    elif [[ -e "$dst" ]]; then
        mv "$dst" "${dst}.backup.$(date +%s)"
        print_warning "Backed up existing $(basename "$dst")"
    fi

    ln -s "$src" "$dst"
    print_success "Linked: $dst -> $src"
}

print_status "Linking configurations..."

# Neovim
link_config "$SCRIPT_DIR/nvim/.config/nvim" "$HOME/.config/nvim"

# tmux
link_config "$SCRIPT_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# zsh
link_config "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"

# Create neovim data dirs
mkdir -p "$HOME/.local/share/nvim/undo"

# ==============================================================================
# iTerm2 (macOS only)
# ==============================================================================

if [[ "$ENV" == "local" ]]; then
    print_status "Setting up iTerm2 dynamic profiles..."
    local_iterm_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    if [[ -d "$HOME/Library/Application Support/iTerm2" ]] || [[ -d "/Applications/iTerm.app" ]]; then
        mkdir -p "$local_iterm_dir"
        link_config "$SCRIPT_DIR/iterm2/profiles.json" "$local_iterm_dir/dotfiles-profiles.json"
    else
        print_warning "iTerm2 not found, skipping profile install"
    fi
fi

# ==============================================================================
# Default Shell (containers only)
# ==============================================================================

if [[ "$ENV" == "container" ]]; then
    print_status "Setting default shell to zsh..."
    if command -v zsh &>/dev/null; then
        ZSH_PATH="$(command -v zsh)"
        if [[ "$SHELL" != "$ZSH_PATH" ]]; then
            # Add zsh to valid shells if not present
            if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
                echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
            fi
            sudo chsh -s "$ZSH_PATH" "$(whoami)" 2>/dev/null || true
            print_success "Default shell set to zsh"
        else
            print_success "zsh already default shell"
        fi
    fi
fi

# ==============================================================================
# Summary
# ==============================================================================

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║            Installation Complete!              ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "  Configs linked:"
echo "    nvim   -> ~/.config/nvim"
echo "    tmux   -> ~/.tmux.conf"
echo "    zsh    -> ~/.zshrc"
if [[ "$ENV" == "local" ]]; then
echo "    iterm2 -> ~/Library/.../DynamicProfiles/"
fi
echo ""
echo "  Next steps:"
echo "    1. Start a new shell (or run: exec zsh)"
echo "    2. Open nvim — plugins install automatically on first launch"
echo "    3. Run :Mason inside nvim to install LSP servers"
echo ""
if [[ "$ENV" == "local" ]]; then
echo "  Local setup:"
echo "    - Copy zsh/.zshrc.local.example to ~/.zshrc.local"
echo "      and add your version managers (pyenv, rbenv, nvm, etc.)"
echo ""
fi
