-- init.lua
-- Neovim configuration bootstrap
-- Migrated from vimrc_legacy.vim to modern Lua-based setup

--------------------------------------------------------------------------------
-- Load Core Configuration
--------------------------------------------------------------------------------
-- Options must load first (sets leader key before plugins load)
require("core.options")

-- Keymaps second (some may depend on options)
require("core.keymaps")

-- Autocommands for filetype-specific behavior
require("core.autocmds")

--------------------------------------------------------------------------------
-- Load Plugins
--------------------------------------------------------------------------------
-- lazy.nvim handles all plugin management and configuration
require("plugins")

--------------------------------------------------------------------------------
-- Post-plugin Configuration
--------------------------------------------------------------------------------
-- Any configuration that must run after plugins are loaded can go here

-- Print a welcome message (optional, remove if annoying)
-- vim.notify("Neovim loaded successfully!", vim.log.levels.INFO)
