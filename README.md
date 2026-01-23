# Dotfiles

Terminal-first development environment: **Neovim** + **tmux** + **zsh** (oh-my-zsh) + **iTerm2**.

Works as a local macOS setup and as a devcontainer/Codespaces dotfiles repository.

## Quick Start

```bash
# Clone
git clone git@github.com:Joyvis/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install (auto-detects macOS vs container)
./install.sh

# Start a new shell
exec zsh
```

## What's Included

| Tool | Config | Highlights |
|------|--------|------------|
| **Neovim** | `nvim/.config/nvim/` | Lua config, lazy.nvim, native LSP (0.11+), Treesitter, Telescope, Dracula theme |
| **tmux** | `tmux/.tmux.conf` | `C-a` prefix, vim-style navigation, vi copy-mode, mouse, true-color |
| **zsh** | `zsh/.zshrc` | oh-my-zsh, git plugin, nvim aliases, `.zshrc.local` pattern |
| **iTerm2** | `iterm2/profiles.json` | Dracula colors, JetBrains Mono Nerd Font, dynamic profile |

## Install Script

The installer is environment-aware and idempotent:

```bash
./install.sh              # Auto-detect (default)
./install.sh --local      # Force macOS mode (Homebrew)
./install.sh --container  # Force container mode (apt-get)
```

**macOS**: Installs Homebrew deps (neovim, tmux, ripgrep, fd, fzf), symlinks configs, sets up iTerm2 dynamic profile.

**Container**: Installs via apt-get, downloads Neovim stable from GitHub if apt version is too old, installs oh-my-zsh, sets zsh as default shell.

### Machine-Specific Config

Version managers and credentials go in `~/.zshrc.local` (not tracked by git):

```bash
cp ~/dotfiles/zsh/.zshrc.local.example ~/.zshrc.local
# Edit with your pyenv, rbenv, nvm, gvm, etc.
```

## Devcontainer / Codespaces

### VS Code User Settings (Recommended)

Add to your global `settings.json` — applies to all devcontainers:

```json
{
  "dotfiles.repository": "Joyvis/dotfiles",
  "dotfiles.installCommand": "install.sh",
  "dotfiles.targetPath": "~/dotfiles"
}
```

### GitHub Codespaces

Set your dotfiles repo at [github.com/settings/codespaces](https://github.com/settings/codespaces).

### Devcontainer CLI

```bash
devcontainer up --workspace-folder . \
  --dotfiles-repository https://github.com/Joyvis/dotfiles \
  --dotfiles-install-command install.sh
```

### Testing

```bash
# Build and test in Docker
docker build -t dotfiles-test -f- . <<'EOF'
FROM mcr.microsoft.com/devcontainers/base:ubuntu
COPY . /home/vscode/dotfiles
RUN cd /home/vscode/dotfiles && ./install.sh
USER vscode
CMD ["zsh"]
EOF
docker run -it dotfiles-test
```

## Neovim

### Key Mappings

Leader: `Space` | Exit insert: `jj` | Arrow keys: disabled

| Mapping | Action |
|---------|--------|
| `<Leader>q` | Toggle file tree (nvim-tree) |
| `<Leader>ff` / `<C-p>` | Find files (Telescope) |
| `<Leader>fg` | Live grep |
| `<Leader>fb` | List buffers |
| `<Leader>p` / `<Leader>n` / `<Leader>d` | Prev/Next/Delete buffer |
| `gd` / `gr` / `K` | Go to definition / references / hover |
| `<Leader>rn` / `<Leader>ca` | Rename / code action |
| `<Leader>c` / `<Leader>s` | Run test file / nearest test |
| `<Leader>t` | Rails alternate file |
| `<Leader>gs` / `<Leader>gb` | Git status / blame |

### Plugins

| Plugin | Purpose |
|--------|---------|
| lazy.nvim | Plugin manager |
| nvim-tree | File explorer |
| telescope.nvim | Fuzzy finder |
| nvim-treesitter | Syntax highlighting |
| mason.nvim | LSP server installer |
| nvim-cmp + LuaSnip | Autocompletion + snippets |
| codeium.vim | AI inline completions |
| vim-fugitive + gitsigns | Git integration |
| vim-rails + vim-test | Ruby/Rails workflow |
| lualine.nvim | Status line |
| Comment.nvim | Commenting |
| which-key.nvim | Keybinding hints |

### LSP Servers (Mason)

ruby_lsp, solargraph, ts_ls, gopls, yamlls, lua_ls — auto-installed on file open.

## tmux

| Binding | Action |
|---------|--------|
| `C-a` | Prefix (replaces `C-b`) |
| `\|` | Vertical split |
| `-` | Horizontal split |
| `h/j/k/l` | Navigate panes |
| `H/J/K/L` | Resize panes |
| `v` (copy-mode) | Begin selection |
| `y` (copy-mode) | Yank to clipboard |
| `r` | Reload config |

## Structure

```
dotfiles/
├── install.sh
├── nvim/.config/nvim/
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
│       ├── core/{options,keymaps,autocmds}.lua
│       ├── plugins/init.lua
│       └── theme/init.lua
├── tmux/.tmux.conf
├── zsh/
│   ├── .zshrc
│   └── .zshrc.local.example
├── iterm2/profiles.json
└── .devcontainer/devcontainer.json
```

## Troubleshooting

```vim
:checkhealth          " Diagnose Neovim issues
:Lazy                 " Plugin status (S=sync, U=update)
:Mason                " LSP server status (i=install)
```

```bash
# Reset Neovim state completely
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
nvim  # Reinstalls everything on launch
```
