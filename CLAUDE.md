# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Dotfiles repo for a terminal-first development environment: Neovim, tmux, zsh (oh-my-zsh), and iTerm2. Works both as a local macOS setup and as a devcontainer/Codespaces dotfiles repository.

## Structure

```
dotfiles/
├── install.sh                  # Environment-aware installer (--local / --container / --auto)
├── nvim/.config/nvim/          # Neovim config (Lua, lazy.nvim, Neovim 0.11+)
│   ├── init.lua
│   └── lua/{core,plugins,theme}/
├── tmux/.tmux.conf             # tmux config (C-a prefix, vi-mode)
├── zsh/.zshrc                  # Portable zsh config (oh-my-zsh)
├── zsh/.zshrc.local.example    # Template for machine-specific overrides
├── iterm2/profiles.json        # iTerm2 dynamic profile (Dracula, JetBrains Mono)
└── .devcontainer/              # Test container for validating dotfiles
```

## Commands

```bash
# Install (auto-detects environment)
./install.sh              # macOS: brew deps + symlinks + iTerm2
./install.sh --container  # Container: apt deps + symlinks + zsh as default shell
./install.sh --local      # Force macOS mode

# Inside Neovim
:Lazy              # Plugin manager UI (S=sync, U=update, C=check)
:Mason             # LSP server manager (i=install)
:checkhealth       # Diagnose issues
:TSUpdate          # Update Treesitter parsers
```

## Neovim Architecture

**Load order** (defined in `nvim/.config/nvim/init.lua`):
1. `lua/core/options.lua` - Editor settings, leader key (`Space`), disables unused providers
2. `lua/core/keymaps.lua` - All key mappings (preserves classic Vim muscle memory)
3. `lua/core/autocmds.lua` - Filetype settings, trailing whitespace highlighting
4. `lua/plugins/init.lua` - lazy.nvim bootstrap and all plugin specs with inline configs
5. `lua/theme/init.lua` - Colorscheme (Dracula) with transparency support

**Plugin configuration pattern**: All plugins are configured inline in `lua/plugins/init.lua` with their specs. No separate plugin config files.

**LSP setup**: Uses Neovim 0.11 native `vim.lsp.config()` and `vim.lsp.enable()` instead of nvim-lspconfig. Mason auto-installs servers. LSP keymaps are set in an `LspAttach` autocmd inside `lua/plugins/init.lua`.

## Install Script Design

- **Idempotent**: Safe to run multiple times
- **Environment detection**: Checks `$REMOTE_CONTAINERS`, `$CODESPACES`, `/.dockerenv`, `uname`
- **Container path**: apt-get deps, downloads Neovim stable from GitHub if apt version < 0.11, sets zsh as default shell
- **macOS path**: Homebrew deps, iTerm2 dynamic profile symlink
- **Both**: oh-my-zsh unattended install, symlinks nvim/tmux/zsh configs

## Key Conventions

- Symlinks point FROM `$HOME` TO this repo (e.g., `~/.config/nvim -> dotfiles/nvim/.config/nvim`)
- Machine-specific config goes in `~/.zshrc.local` (not tracked)
- Neovim leader key: `Space`
- tmux prefix: `C-a`
- Exit insert mode: `jj`

## Filetype Indentation

- 2 spaces: Ruby, JS/TS, HTML, CSS, YAML, Lua, Markdown
- 4 spaces with tabs: Go (gofmt standard)
