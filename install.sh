#!/bin/bash

# install.sh
# Idempotent setup script for Neovim configuration
# Safe to run multiple times

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║     Neovim Configuration Installation          ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# ------------------------------------------------------------------------------
# Check for Homebrew
# ------------------------------------------------------------------------------
print_status "Checking for Homebrew..."

if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session (Apple Silicon)
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    print_success "Homebrew installed"
else
    print_success "Homebrew found"
fi

# ------------------------------------------------------------------------------
# Install Homebrew Dependencies
# ------------------------------------------------------------------------------
print_status "Checking Homebrew dependencies..."

DEPS=("neovim" "ripgrep" "fd" "fzf" "luarocks")

for dep in "${DEPS[@]}"; do
    if brew list "$dep" &> /dev/null; then
        print_success "$dep already installed"
    else
        print_warning "$dep not found. Installing..."
        brew install "$dep"
        print_success "$dep installed"
    fi
done

# ------------------------------------------------------------------------------
# Setup Ruby Gems (for LSP servers)
# ------------------------------------------------------------------------------
print_status "Checking Ruby gem configuration..."

if command -v gem &> /dev/null; then
    # Ensure rubygems.org is in sources
    if ! gem sources -l 2>/dev/null | grep -q "rubygems.org"; then
        print_warning "Adding rubygems.org to gem sources..."
        gem sources --add https://rubygems.org/ > /dev/null 2>&1
        print_success "rubygems.org added to gem sources"
    else
        print_success "rubygems.org already in gem sources"
    fi

    # Install required gems for LSP
    GEMS=("solargraph")
    for gem_name in "${GEMS[@]}"; do
        if gem list -i "^${gem_name}$" > /dev/null 2>&1; then
            print_success "$gem_name gem already installed"
        else
            print_warning "$gem_name gem not found. Installing..."
            gem install "$gem_name" > /dev/null 2>&1
            print_success "$gem_name gem installed"
        fi
    done
else
    print_warning "Ruby not found - skipping gem installation"
fi

# ------------------------------------------------------------------------------
# Create Neovim Config Symlink
# ------------------------------------------------------------------------------
print_status "Setting up Neovim config directory..."

NVIM_CONFIG_DIR="$HOME/.config/nvim"

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Handle existing nvim config
if [[ -L "$NVIM_CONFIG_DIR" ]]; then
    # It's a symlink - check if it points to the right place
    CURRENT_TARGET="$(readlink "$NVIM_CONFIG_DIR")"
    if [[ "$CURRENT_TARGET" == "$SCRIPT_DIR" ]]; then
        print_success "Symlink already correctly configured"
    else
        print_warning "Symlink points to different location: $CURRENT_TARGET"
        print_warning "Updating symlink to point to: $SCRIPT_DIR"
        rm "$NVIM_CONFIG_DIR"
        ln -s "$SCRIPT_DIR" "$NVIM_CONFIG_DIR"
        print_success "Symlink updated"
    fi
elif [[ -d "$NVIM_CONFIG_DIR" ]]; then
    # It's an existing directory
    print_warning "Existing nvim config found at $NVIM_CONFIG_DIR"
    print_warning "Backing up to $NVIM_CONFIG_DIR.backup.$(date +%Y%m%d%H%M%S)"
    mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_DIR.backup.$(date +%Y%m%d%H%M%S)"
    ln -s "$SCRIPT_DIR" "$NVIM_CONFIG_DIR"
    print_success "Symlink created (old config backed up)"
elif [[ -f "$NVIM_CONFIG_DIR" ]]; then
    # It's a file (unusual)
    print_error "$NVIM_CONFIG_DIR is a file, not a directory. Please remove it manually."
    exit 1
else
    # Nothing exists - create symlink
    ln -s "$SCRIPT_DIR" "$NVIM_CONFIG_DIR"
    print_success "Symlink created: $NVIM_CONFIG_DIR -> $SCRIPT_DIR"
fi

# ------------------------------------------------------------------------------
# Create Data Directories
# ------------------------------------------------------------------------------
print_status "Creating Neovim data directories..."

mkdir -p "$HOME/.local/share/nvim/undo"
print_success "Undo directory ready"

# ------------------------------------------------------------------------------
# Verify Installation
# ------------------------------------------------------------------------------
print_status "Verifying installation..."

NVIM_VERSION=$(nvim --version | head -n 1)
print_success "Neovim version: $NVIM_VERSION"

# Check if config is readable
if nvim --headless -c 'quit' 2>/dev/null; then
    print_success "Neovim config loads without errors"
else
    print_warning "Config may have issues - run :checkhealth after opening"
fi

# ------------------------------------------------------------------------------
# Print Next Steps
# ------------------------------------------------------------------------------
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║              Installation Complete!            ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo ""
echo "  1. Open Neovim:"
echo "     ${GREEN}nvim${NC}"
echo ""
echo "  2. Wait for plugins to install automatically"
echo "     (lazy.nvim will bootstrap on first launch)"
echo ""
echo "  3. Run health check:"
echo "     ${GREEN}:checkhealth${NC}"
echo ""
echo "  4. Install LSP servers (opens Mason UI):"
echo "     ${GREEN}:Mason${NC}"
echo ""
echo "  5. Authenticate Codeium (if using AI completions):"
echo "     ${GREEN}:Codeium Auth${NC}"
echo ""
echo "  6. Update Treesitter parsers:"
echo "     ${GREEN}:TSUpdate${NC}"
echo ""
echo "Your existing Vim configuration is unchanged."
echo "Run 'vim' for classic Vim, 'nvim' for Neovim."
echo ""
