#!/bin/bash

# setup.sh
# Complete setup script for Neovim configuration from scratch
# Installs all dependencies including fonts and language runtimes for LSP
# Safe to run multiple times (idempotent)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║       Complete Neovim Environment Setup                        ║"
echo "║       Fonts + Languages + Tools + Config                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# ==============================================================================
# 1. Xcode Command Line Tools (required for building native extensions)
# ==============================================================================
print_section "Xcode Command Line Tools"

if xcode-select -p &> /dev/null; then
    print_success "Xcode CLI tools already installed"
else
    print_warning "Xcode CLI tools not found. Installing..."
    xcode-select --install
    echo ""
    print_warning "Please complete the Xcode CLI tools installation popup,"
    print_warning "then run this script again."
    exit 0
fi

# ==============================================================================
# 2. Homebrew
# ==============================================================================
print_section "Homebrew Package Manager"

if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    print_success "Homebrew installed"
else
    print_success "Homebrew found"
fi

# ==============================================================================
# 3. Core System Dependencies
# ==============================================================================
print_section "Core System Dependencies"

CORE_DEPS=("git" "neovim" "ripgrep" "fd" "fzf")

for dep in "${CORE_DEPS[@]}"; do
    if brew list "$dep" &> /dev/null; then
        print_success "$dep already installed"
    else
        print_warning "$dep not found. Installing..."
        brew install "$dep"
        print_success "$dep installed"
    fi
done

# ==============================================================================
# 4. Nerd Font (required for icons in nvim-tree, telescope, lualine)
# ==============================================================================
print_section "Nerd Font Installation"

# Check if font is already installed
FONT_NAME="JetBrainsMonoNerdFont"
FONT_INSTALLED=false

if [[ -d "$HOME/Library/Fonts" ]]; then
    if ls "$HOME/Library/Fonts" 2>/dev/null | grep -qi "JetBrains.*Nerd" || \
       ls "/Library/Fonts" 2>/dev/null | grep -qi "JetBrains.*Nerd"; then
        FONT_INSTALLED=true
    fi
fi

# Also check via brew
if brew list --cask font-jetbrains-mono-nerd-font &> /dev/null 2>&1; then
    FONT_INSTALLED=true
fi

if [[ "$FONT_INSTALLED" == "true" ]]; then
    print_success "JetBrains Mono Nerd Font already installed"
else
    print_warning "Installing JetBrains Mono Nerd Font..."

    # Add homebrew fonts tap if not already added
    if ! brew tap | grep -q "homebrew/cask-fonts"; then
        brew tap homebrew/cask-fonts
    fi

    brew install --cask font-jetbrains-mono-nerd-font
    print_success "JetBrains Mono Nerd Font installed"
fi

# ==============================================================================
# 5. Language Runtimes (for LSP servers)
# ==============================================================================
print_section "Language Runtimes for LSP"

# --- Ruby ---
print_status "Checking Ruby..."
if command -v ruby &> /dev/null; then
    RUBY_VERSION=$(ruby -v | grep -oE '[0-9]+\.[0-9]+' | head -1)
    print_success "Ruby found: $(ruby -v | head -c 50)"

    # Check if Ruby version is 3.0+ for ruby_lsp
    RUBY_MAJOR=$(echo "$RUBY_VERSION" | cut -d. -f1)
    if [[ "$RUBY_MAJOR" -lt 3 ]]; then
        print_warning "Ruby $RUBY_VERSION detected. ruby_lsp requires Ruby 3.0+"
        print_warning "Consider installing Ruby 3.x via rbenv or asdf"
        print_warning "Solargraph will be used as fallback LSP"
    fi
else
    print_warning "Ruby not found. Installing via Homebrew..."
    brew install ruby
    print_success "Ruby installed"
    print_warning "Add to your shell profile:"
    echo '    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"'
fi

# --- Node.js ---
print_status "Checking Node.js..."
if command -v node &> /dev/null; then
    print_success "Node.js found: $(node -v)"
else
    print_warning "Node.js not found. Installing via Homebrew..."
    brew install node
    print_success "Node.js installed"
fi

# --- Go ---
print_status "Checking Go..."
if command -v go &> /dev/null; then
    print_success "Go found: $(go version | grep -oE 'go[0-9]+\.[0-9]+(\.[0-9]+)?')"
else
    print_warning "Go not found. Installing via Homebrew..."
    brew install go
    print_success "Go installed"
fi

# ==============================================================================
# 6. Neovim Config Setup
# ==============================================================================
print_section "Neovim Configuration"

NVIM_CONFIG_DIR="$HOME/.config/nvim"

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Handle existing nvim config
if [[ -L "$NVIM_CONFIG_DIR" ]]; then
    CURRENT_TARGET="$(readlink "$NVIM_CONFIG_DIR")"
    if [[ "$CURRENT_TARGET" == "$SCRIPT_DIR" ]]; then
        print_success "Config symlink already correctly configured"
    else
        print_warning "Updating symlink from: $CURRENT_TARGET"
        rm "$NVIM_CONFIG_DIR"
        ln -s "$SCRIPT_DIR" "$NVIM_CONFIG_DIR"
        print_success "Symlink updated to: $SCRIPT_DIR"
    fi
elif [[ -d "$NVIM_CONFIG_DIR" ]]; then
    BACKUP_DIR="$NVIM_CONFIG_DIR.backup.$(date +%Y%m%d%H%M%S)"
    print_warning "Backing up existing config to: $BACKUP_DIR"
    mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
    ln -s "$SCRIPT_DIR" "$NVIM_CONFIG_DIR"
    print_success "Symlink created (old config backed up)"
elif [[ -f "$NVIM_CONFIG_DIR" ]]; then
    print_error "$NVIM_CONFIG_DIR is a file. Please remove it manually."
    exit 1
else
    ln -s "$SCRIPT_DIR" "$NVIM_CONFIG_DIR"
    print_success "Symlink created: $NVIM_CONFIG_DIR -> $SCRIPT_DIR"
fi

# Create data directories
mkdir -p "$HOME/.local/share/nvim/undo"
print_success "Neovim data directories ready"

# ==============================================================================
# 7. Verification
# ==============================================================================
print_section "Verification"

NVIM_VERSION=$(nvim --version | head -n 1)
print_success "Neovim: $NVIM_VERSION"

# Quick config check
if nvim --headless -c 'quit' 2>/dev/null; then
    print_success "Neovim config loads without errors"
else
    print_warning "Config may have issues - run :checkhealth after opening"
fi

# ==============================================================================
# Summary and Next Steps
# ==============================================================================
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    Setup Complete!                             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Installed:${NC}"
echo "  - Xcode CLI tools (C compiler)"
echo "  - Homebrew package manager"
echo "  - Neovim, ripgrep, fd, fzf, git"
echo "  - JetBrains Mono Nerd Font"
echo "  - Ruby, Node.js, Go runtimes"
echo "  - Neovim config linked"
echo ""
echo -e "${YELLOW}IMPORTANT: Configure your terminal font!${NC}"
echo ""
echo "  For iTerm2:"
echo "    Preferences -> Profiles -> Text -> Font"
echo "    Select: JetBrainsMono Nerd Font"
echo ""
echo "  For Terminal.app:"
echo "    Preferences -> Profiles -> Font -> Change"
echo "    Select: JetBrainsMono Nerd Font Mono"
echo ""
echo "  For VS Code Terminal:"
echo "    Settings -> Terminal > Integrated: Font Family"
echo "    Set to: JetBrainsMono Nerd Font"
echo ""
echo "  For Alacritty (~/.config/alacritty/alacritty.toml):"
echo '    [font.normal]'
echo '    family = "JetBrainsMono Nerd Font"'
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo ""
echo "  1. Configure terminal font (see above)"
echo ""
echo "  2. Open Neovim and wait for plugin installation:"
echo -e "     ${GREEN}nvim${NC}"
echo ""
echo "  3. Run health check for any issues:"
echo -e "     ${GREEN}:checkhealth${NC}"
echo ""
echo "  4. LSP servers auto-install via Mason on first file open"
echo "     Or manually manage with:"
echo -e "     ${GREEN}:Mason${NC}"
echo ""
echo "  5. (Optional) Authenticate Codeium for AI completions:"
echo -e "     ${GREEN}:Codeium Auth${NC}"
echo ""
echo "  6. Update Treesitter parsers:"
echo -e "     ${GREEN}:TSUpdate${NC}"
echo ""
echo -e "${CYAN}Quick test:${NC}"
echo "  nvim test.rb    # Should show Ruby LSP working"
echo "  nvim test.ts    # Should show TypeScript LSP working"
echo "  nvim test.go    # Should show Go LSP working"
echo ""
echo "Your existing Vim config is unchanged."
echo "Run 'vim' for classic Vim, 'nvim' for Neovim."
echo ""
