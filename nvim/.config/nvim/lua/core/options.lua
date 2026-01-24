-- core/options.lua
-- Editor options migrated from vimrc_legacy.vim
-- Grouped logically with explanations for future reference

--------------------------------------------------------------------------------
-- Compatibility Shim
--------------------------------------------------------------------------------
-- Fix for Telescope/treesitter compatibility with Neovim 0.11+
-- The ft_to_lang function was renamed to get_lang
if not vim.treesitter.language.ft_to_lang then
  vim.treesitter.language.ft_to_lang = vim.treesitter.language.get_lang
end

local opt = vim.opt

--------------------------------------------------------------------------------
-- Leader Key
--------------------------------------------------------------------------------
-- Space as leader key (must be set before lazy.nvim loads plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--------------------------------------------------------------------------------
-- Language & Encoding
--------------------------------------------------------------------------------
pcall(vim.cmd, "language en_US.UTF-8")
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

--------------------------------------------------------------------------------
-- Line Numbers
--------------------------------------------------------------------------------
-- Absolute line numbers + relative numbers for easy motion commands (5j, 10k)
opt.number = true
opt.relativenumber = true

--------------------------------------------------------------------------------
-- Cursor & Visual Guides
--------------------------------------------------------------------------------
-- Highlight current line and column for easier cursor tracking
opt.cursorline = true
opt.cursorcolumn = true

-- Color column at 80 characters as a visual guide for line length
opt.colorcolumn = "80"

--------------------------------------------------------------------------------
-- Indentation
--------------------------------------------------------------------------------
-- Smart indentation that respects file type settings
opt.autoindent = true
opt.smartindent = true

-- Default to spaces, 2-space width (overridden per filetype in autocmds.lua)
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

--------------------------------------------------------------------------------
-- Search Behavior
--------------------------------------------------------------------------------
-- Incremental search with highlighting, case-insensitive unless uppercase used
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

--------------------------------------------------------------------------------
-- Command Line Completion
--------------------------------------------------------------------------------
-- Tab completion in command mode: show list, complete longest match first
opt.wildmode = "list:longest,list:full"
opt.wildignore:append({ "*.o", "*.obj", ".git", "*.rbc", "*.class", ".svn", "vendor/gems/*" })

--------------------------------------------------------------------------------
-- Clipboard
--------------------------------------------------------------------------------
-- Use system clipboard for all yank/paste operations (macOS integration)
opt.clipboard = "unnamedplus"

--------------------------------------------------------------------------------
-- Status Line
--------------------------------------------------------------------------------
-- Always show status line (needed for lualine or similar plugins)
opt.laststatus = 2

--------------------------------------------------------------------------------
-- Terminal Colors
--------------------------------------------------------------------------------
-- Enable 24-bit RGB colors in the TUI
opt.termguicolors = true

--------------------------------------------------------------------------------
-- Undo & Backup
--------------------------------------------------------------------------------
-- Persistent undo: undo history survives closing and reopening files
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Disable swap files (nvim handles crashes better than classic vim)
opt.swapfile = false

-- Disable backup files (we use git for version control)
opt.backup = false
opt.writebackup = false

--------------------------------------------------------------------------------
-- Misc Editor Behavior
--------------------------------------------------------------------------------
-- Faster completion (default is 4000ms)
opt.updatetime = 250

-- Time to wait for a mapped sequence to complete (in milliseconds)
opt.timeoutlen = 500

-- Allow hidden buffers (switch buffers without saving)
opt.hidden = true

-- Don't show mode in command line (shown in statusline instead)
opt.showmode = false

-- Enable mouse support in all modes (useful for occasional scrolling)
opt.mouse = "a"

-- Minimum number of screen lines above/below cursor
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Better split behavior: open new splits below and to the right
opt.splitbelow = true
opt.splitright = true

-- Don't wrap lines by default
opt.wrap = false

-- Show matching brackets when cursor is over them
opt.showmatch = true

-- Enable syntax highlighting (redundant in nvim but explicit is good)
vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

--------------------------------------------------------------------------------
-- Neovim-specific optimizations
--------------------------------------------------------------------------------
-- Disable some built-in plugins we don't need (faster startup)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_matchit = 1
-- Note: matchparen is kept enabled for bracket matching visual feedback
vim.g.loaded_2html_plugin = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_logipat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_spellfile_plugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1

--------------------------------------------------------------------------------
-- Disable unused providers (reduces :checkhealth warnings)
--------------------------------------------------------------------------------
-- We don't use Python/Ruby/Perl/Node remote plugins, so disable their providers
-- This eliminates "provider not installed" warnings in :checkhealth
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
