-- core/keymaps.lua
-- All key mappings migrated from vimrc_legacy.vim
-- Uses vim.keymap.set exclusively for consistency

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

--------------------------------------------------------------------------------
-- Escape Alternatives
--------------------------------------------------------------------------------
-- jj in insert mode to escape (classic vim muscle memory)
map("i", "jj", "<Esc>", { desc = "Exit insert mode with jj" })
-- jj in command mode to cancel
map("c", "jj", "<C-c>", { desc = "Cancel command with jj" })
-- v in visual mode to escape (quick toggle)
map("v", "v", "<Esc>", { desc = "Exit visual mode with v" })

--------------------------------------------------------------------------------
-- Arrow Keys Disabled
--------------------------------------------------------------------------------
-- "Don't be a noob, join the no arrows key movement"
-- Forces hjkl usage for navigation muscle memory
map("i", "<Up>", "<NOP>", opts)
map("i", "<Down>", "<NOP>", opts)
map("i", "<Left>", "<NOP>", opts)
map("i", "<Right>", "<NOP>", opts)
map("n", "<Up>", "<NOP>", opts)
map("n", "<Down>", "<NOP>", opts)
map("n", "<Left>", "<NOP>", opts)
map("n", "<Right>", "<NOP>", opts)

--------------------------------------------------------------------------------
-- Search
--------------------------------------------------------------------------------
-- Clear search highlighting with leader + Enter
map("n", "<Leader><CR>", ":nohlsearch<CR>", { desc = "Clear search highlighting" })

--------------------------------------------------------------------------------
-- Buffer Navigation
--------------------------------------------------------------------------------
-- Quick buffer switching without leaving home row
map("n", "<Leader>p", ":bp<CR>", { desc = "Previous buffer" })
map("n", "<Leader>n", ":bn<CR>", { desc = "Next buffer" })
map("n", "<Leader>d", ":bd<CR>", { desc = "Delete buffer" })

--------------------------------------------------------------------------------
-- vim-test Mappings
--------------------------------------------------------------------------------
-- Run tests with leader shortcuts (vim-test handles the strategy)
map("n", "<Leader>c", ":TestFile<CR>", { desc = "Run tests in current file" })
map("n", "<Leader>s", ":TestNearest<CR>", { desc = "Run nearest test" })

--------------------------------------------------------------------------------
-- Rails Navigation
--------------------------------------------------------------------------------
-- Jump to alternate file (test <-> implementation) via vim-rails
map("n", "<Leader>t", ":A<CR>", { desc = "Jump to alternate file (Rails)" })
-- Jump to related file
map("n", "<Leader>r", ":R<CR>", { desc = "Jump to related file (Rails)" })

--------------------------------------------------------------------------------
-- File Tree Toggle
--------------------------------------------------------------------------------
-- Toggle nvim-tree sidebar (mapped in plugins/init.lua, but documented here)
-- <Leader>q is configured in the nvim-tree plugin setup

--------------------------------------------------------------------------------
-- Ruby Hash Syntax Conversion
--------------------------------------------------------------------------------
-- Convert old hash rocket syntax (:key => value) to new syntax (key: value)
map("n", "<F12>", [[:%s/:\([^ ]*\)\(\s*\)=>/\1:/g<CR>]], { desc = "Convert Ruby hash rockets to new syntax" })

--------------------------------------------------------------------------------
-- Window Navigation
--------------------------------------------------------------------------------
-- Easier split navigation with Ctrl + hjkl
map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to split below" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to split above" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

--------------------------------------------------------------------------------
-- Better Indentation
--------------------------------------------------------------------------------
-- Stay in visual mode after indenting
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

--------------------------------------------------------------------------------
-- Move Lines
--------------------------------------------------------------------------------
-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

--------------------------------------------------------------------------------
-- Quality of Life
--------------------------------------------------------------------------------
-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Keep cursor centered when searching
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Don't lose register content when pasting over selection
map("x", "<Leader>p", [["_dP]], { desc = "Paste without losing register" })

-- Quick save
map("n", "<Leader>w", ":w<CR>", { desc = "Save file" })

-- Quick quit
map("n", "<Leader>Q", ":qa<CR>", { desc = "Quit all" })

--------------------------------------------------------------------------------
-- Telescope Mappings (documented here, configured in plugins)
--------------------------------------------------------------------------------
-- <Leader>ff - Find files
-- <Leader>fg - Live grep
-- <Leader>fb - Buffers
-- <Leader>fh - Help tags
-- See plugins/init.lua for telescope configuration
