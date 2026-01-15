# Neovim Configuration

A modern Neovim configuration migrated from a long-standing Vim + Vundle setup. This config preserves muscle memory and workflows while embracing Neovim-native features and Lua-based configuration.

## Philosophy

This configuration follows several guiding principles:

1. **Preserve muscle memory** - Key mappings match the original Vim config where possible
2. **Modern tooling** - Use Neovim-native features (LSP, Treesitter) instead of legacy solutions
3. **Clarity over cleverness** - Code is heavily commented for future maintenance
4. **Terminal-first** - No GUI assumptions, works perfectly in iTerm or any terminal
5. **AI-assisted development** - Codeium for inline completions, Claude Code for repo-aware editing

## How This Differs from Classic Vim

| Classic Vim | This Neovim Config |
|-------------|-------------------|
| Vundle for plugins | lazy.nvim (faster, Lua-native) |
| ctrlp.vim | Telescope (better UI, more features) |
| NERDTree | nvim-tree (Lua-native, faster) |
| tcomment | Comment.nvim |
| vim-snipmate + supertab | nvim-cmp + LuaSnip |
| Regex syntax highlighting | Treesitter (AST-based, more accurate) |
| No language server | Native LSP with mason.nvim |
| vimscript configuration | Lua configuration |

## Directory Structure

```
nvim/
├── init.lua              # Bootstrap file
├── lua/
│   ├── core/
│   │   ├── options.lua   # Editor settings (line numbers, tabs, etc.)
│   │   ├── keymaps.lua   # All key mappings
│   │   └── autocmds.lua  # Autocommands (filetype settings, etc.)
│   └── plugins/
│       └── init.lua      # Plugin declarations and configurations
├── README.md             # This file
└── install.sh            # Setup script for new machines
```

## Key Mappings

Leader key is `<Space>`.

### Essential Mappings (Preserved from Vim)

| Mapping | Action |
|---------|--------|
| `jj` | Exit insert mode |
| `<Leader>q` | Toggle file tree |
| `<Leader><CR>` | Clear search highlighting |
| `<Leader>p` / `<Leader>n` / `<Leader>d` | Previous/Next/Delete buffer |
| `<Leader>c` | Run tests in current file |
| `<Leader>s` | Run nearest test |
| `<Leader>t` | Jump to alternate file (Rails) |
| `<F12>` | Convert Ruby hash rockets to new syntax |
| Arrow keys | Disabled (use hjkl) |

### Telescope (Fuzzy Finding)

| Mapping | Action |
|---------|--------|
| `<Leader>ff` | Find files |
| `<Leader>fg` | Live grep (search content) |
| `<Leader>fb` | List buffers |
| `<Leader>fh` | Help tags |
| `<Leader>fr` | Recent files |
| `<C-p>` | Find files (Ctrl-P muscle memory) |

### LSP (Language Server)

| Mapping | Action |
|---------|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<Leader>rn` | Rename symbol |
| `<Leader>ca` | Code action |
| `<Leader>lf` | Format buffer |
| `[d` / `]d` | Previous/Next diagnostic |

### Git

| Mapping | Action |
|---------|--------|
| `<Leader>gs` | Git status (fugitive) |
| `<Leader>gb` | Git blame |
| `<Leader>gd` | Git diff |
| `]h` / `[h` | Next/Previous hunk |
| `<Leader>hp` | Preview hunk |

### AI Completions (Codeium)

| Mapping | Action |
|---------|--------|
| `<C-g>` | Accept Codeium suggestion |
| `<M-]>` | Next suggestion (Alt+]) |
| `<M-[>` | Previous suggestion (Alt+[) |
| `<M-\>` | Clear suggestion (Alt+\) |

## Plugins

| Plugin | Purpose |
|--------|---------|
| **lazy.nvim** | Plugin manager (replaces Vundle) |
| **nvim-tree** | File explorer (replaces NERDTree) |
| **telescope.nvim** | Fuzzy finder (replaces ctrlp + fzf) |
| **nvim-treesitter** | Syntax highlighting and parsing |
| **vim.lsp** | Native LSP support (Neovim 0.11+) |
| **mason.nvim** | LSP server installer |
| **nvim-cmp** | Autocompletion (replaces supertab) |
| **LuaSnip** | Snippets (replaces snipmate) |
| **codeium.vim** | AI inline completions |
| **Comment.nvim** | Commenting (replaces tcomment) |
| **nvim-autopairs** | Auto-close brackets |
| **nvim-ts-autotag** | Auto-close HTML tags |
| **vim-surround** | Surround text objects |
| **vim-fugitive** | Git integration |
| **gitsigns.nvim** | Git status in gutter |
| **vim-rails** | Rails navigation |
| **vim-test** | Test runner |
| **lualine.nvim** | Status line |
| **which-key.nvim** | Keybinding hints |
| **indent-blankline** | Indentation guides |
| **PaperColor** | Colorscheme |
| **emmet-vim** | HTML/CSS expansion |

## Setup on a New macOS Machine

### Prerequisites

Before installing, ensure you have:

1. **Neovim 0.9+** (0.10+ recommended for best performance)
2. **A Nerd Font** installed and configured in your terminal
   - Icons in file tree, statusline, and Telescope require a Nerd Font
   - Recommended: [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads)
   - After installing, set your terminal's font to the Nerd Font variant
3. **Git** for plugin management
4. **A C compiler** (Xcode CLI tools on macOS) for telescope-fzf-native

```bash
# Install prerequisites on macOS
brew install neovim ripgrep fd fzf git

# Install Nerd Font (example with JetBrainsMono)
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font

# Verify Neovim version
nvim --version  # Should be 0.9.0 or higher
```

### Quick Start

```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/dotfiles-nvim.git ~/projects/dotfiles-nvim

# Run the install script
cd ~/projects/dotfiles-nvim/nvim
chmod +x install.sh
./install.sh

# Open Neovim (plugins will auto-install on first launch)
nvim
```

### Manual Setup

If you prefer manual installation:

```bash
# 1. Install Homebrew dependencies
brew install neovim ripgrep fd fzf

# 2. Create config directory symlink
mkdir -p ~/.config
ln -sf ~/projects/dotfiles-nvim/nvim ~/.config/nvim

# 3. Open Neovim (lazy.nvim will bootstrap automatically)
nvim

# 4. Wait for plugins to install, then run health check
:checkhealth
```

### Installing LSP Servers

LSP servers are managed by Mason and will auto-install when you open relevant files. You can also install them manually:

```vim
:Mason
```

Then press `i` on any server to install it. Pre-configured servers:

| Server | Language | Notes |
|--------|----------|-------|
| **ruby_lsp** | Ruby | Preferred for Ruby 3.0+, modern features |
| **solargraph** | Ruby | Fallback for older Ruby versions |
| **ts_ls** | TypeScript/JavaScript | Full TypeScript support |
| **gopls** | Go | Official Go language server |
| **yamlls** | YAML | Schema validation for GitHub Actions, etc. |
| **lua_ls** | Lua | For editing Neovim configuration |

#### Ruby LSP Notes

- **ruby_lsp** requires Ruby 3.0 or higher
- If you're on an older Ruby version, use **solargraph** instead
- Both are installed by default; the appropriate one will activate based on your project
- For solargraph, you may want to add it to your project's Gemfile for best results

### Codeium Setup

Codeium provides AI-powered inline completions. Authenticate on first use:

```vim
:Codeium Auth
```

This opens a browser to authenticate with your Codeium account. After authentication, Codeium suggestions appear as ghost text while typing.

## Vim and Neovim Coexistence

This configuration lives entirely under `~/.config/nvim` and does not touch your existing Vim setup:

- **Vim** uses `~/.vim/` and `~/.vimrc`
- **Neovim** uses `~/.config/nvim/`

You can run both editors side by side:

```bash
vim somefile.txt    # Opens in classic Vim with your existing config
nvim somefile.txt   # Opens in Neovim with this new config
```

To fully migrate, you can alias vim to nvim in your shell config:

```bash
# Add to ~/.zshrc or ~/.bashrc (only when you're ready!)
# alias vim="nvim"
```

## AI Tools: Codeium + Claude Code

This setup uses two complementary AI tools:

### Codeium (Inline Completions)
- Runs inside Neovim
- Provides real-time code suggestions as you type
- Accept with `<C-g>`, cycle with `<C-;>` and `<C-,>`
- Best for: completing the current line, boilerplate, obvious patterns

### Claude Code (Terminal Chat)
- Runs in your terminal alongside Neovim
- Full repo awareness - can read and edit files
- Best for: explaining code, refactoring, writing tests, complex changes
- Usage: Run `claude` in your project directory

**Workflow Example:**
1. Use Codeium for quick completions while typing
2. When stuck on a complex problem, switch to terminal and ask Claude Code
3. Claude Code can edit files directly, then switch back to Neovim to review

## Troubleshooting

### Run Health Check

```vim
:checkhealth
```

This will identify any missing dependencies or configuration issues.

### Icons Not Displaying Correctly

If you see boxes, question marks, or missing icons:

1. **Install a Nerd Font** (see Prerequisites above)
2. **Configure your terminal** to use the Nerd Font as the main font
3. **Restart your terminal** after font installation

Common terminal font settings:
- **iTerm2**: Preferences → Profiles → Text → Font
- **Alacritty**: Edit `~/.config/alacritty/alacritty.yml`, set `font.normal.family`
- **WezTerm**: Edit `~/.wezterm.lua`, set `config.font`

### Plugins Not Loading

```vim
:Lazy
```

Press `S` to sync plugins, `U` to update, `C` to check for issues.

### LSP Not Working

Check if the server is installed and attached:
```vim
:LspInfo
```

If no server is attached:
1. Check `:Mason` to see if the server is installed
2. Press `i` on the server name to install it
3. Reopen the file to trigger attachment

### Ruby LSP Issues

If ruby_lsp fails to start:
- Ensure you're using Ruby 3.0+ (`ruby --version`)
- For older Ruby, solargraph should auto-activate as fallback
- Check `:LspLog` for detailed error messages

### Treesitter Errors

Update all parsers:
```vim
:TSUpdate
```

If a specific parser fails:
```vim
:TSInstall <language>
```

### Telescope Previewer Not Showing Syntax Highlighting

This is fixed in the current configuration. If you still see issues:
1. Ensure Treesitter parsers are installed: `:TSInstall <language>`
2. Open a file of that type first to trigger parser loading
3. Treesitter loads on VeryLazy event, so first file open triggers it

### Slow Startup

Check which plugins take longest:
```vim
:Lazy profile
```

### Codeium Not Working

1. Ensure you've authenticated: `:Codeium Auth`
2. Check status: `:Codeium Status`
3. If issues persist, try `:Codeium Disable` then `:Codeium Enable`

### Reset Everything

```bash
# Remove lazy.nvim cache and data
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Reopen Neovim (will reinstall all plugins)
nvim
```

### Common :checkhealth Warnings

| Warning | Resolution |
|---------|------------|
| "python3 provider not found" | Expected - Python provider is intentionally disabled |
| "ruby provider not found" | Expected - Ruby provider is intentionally disabled |
| "clipboard: No clipboard tool found" | Install `pbcopy` (macOS has this by default) |
| "ripgrep not found" | Run `brew install ripgrep` |

## Customization

### Adding a New Plugin

Edit `lua/plugins/init.lua` and add a new entry:

```lua
{
  "author/plugin-name",
  config = function()
    require("plugin-name").setup({})
  end,
},
```

### Adding a Keymap

Edit `lua/core/keymaps.lua`:

```lua
map("n", "<Leader>x", ":SomeCommand<CR>", { desc = "Description" })
```

### Adding a Filetype Setting

Edit `lua/core/autocmds.lua` and add to the appropriate augroup.

## License

MIT - Do whatever you want with this configuration.
