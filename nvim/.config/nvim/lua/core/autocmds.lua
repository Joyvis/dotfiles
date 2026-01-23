-- core/autocmds.lua
-- Autocommands migrated from vimrc_legacy.vim
-- Uses Neovim's lua API for better performance and clarity

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

--------------------------------------------------------------------------------
-- Filetype-specific Indentation
--------------------------------------------------------------------------------
-- 2-space indentation for web development languages
-- Migrated from: autocmd FileType ruby,eruby,yaml,markdown,javascript,typescript set ai sw=2 sts=2 et
local indentation_group = augroup("FileTypeIndentation", { clear = true })

autocmd("FileType", {
  group = indentation_group,
  pattern = {
    "ruby",
    "eruby",
    "yaml",
    "markdown",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "html",
    "css",
    "scss",
    "lua",
  },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
  desc = "Set 2-space indentation for web development filetypes",
})

-- 4-space indentation for Go (gofmt standard)
autocmd("FileType", {
  group = indentation_group,
  pattern = { "go" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = false -- Go uses tabs
  end,
  desc = "Set tab-based indentation for Go (gofmt standard)",
})

--------------------------------------------------------------------------------
-- Trailing Whitespace Highlighting
--------------------------------------------------------------------------------
-- Highlight trailing whitespace in red (visual reminder to keep code clean)
-- Migrated from: :highlight ExtraWhitespace ctermbg=red guibg=red
local whitespace_group = augroup("TrailingWhitespace", { clear = true })

-- Define the highlight group
autocmd("ColorScheme", {
  group = whitespace_group,
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "#ff0000" })
  end,
  desc = "Define red background for trailing whitespace",
})

-- Match trailing whitespace in all buffers
autocmd({ "BufWinEnter", "InsertLeave" }, {
  group = whitespace_group,
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "" and vim.bo.buftype == "" then
      vim.fn.matchadd("ExtraWhitespace", [[\s\+$]])
    end
  end,
  desc = "Highlight trailing whitespace",
})

-- Don't highlight trailing whitespace while typing in insert mode
autocmd("InsertEnter", {
  group = whitespace_group,
  pattern = "*",
  callback = function()
    vim.fn.clearmatches()
  end,
  desc = "Clear trailing whitespace highlight in insert mode",
})

--------------------------------------------------------------------------------
-- Restore Cursor Position
--------------------------------------------------------------------------------
-- Return to last edit position when opening files
local cursor_group = augroup("RestoreCursor", { clear = true })

autocmd("BufReadPost", {
  group = cursor_group,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Restore cursor position on file open",
})

--------------------------------------------------------------------------------
-- Highlight on Yank
--------------------------------------------------------------------------------
-- Brief highlight when yanking text (visual feedback)
local yank_group = augroup("HighlightYank", { clear = true })

autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
  desc = "Highlight yanked text briefly",
})

--------------------------------------------------------------------------------
-- Auto-resize Splits
--------------------------------------------------------------------------------
-- Automatically resize splits when terminal window is resized
local resize_group = augroup("AutoResizeSplits", { clear = true })

autocmd("VimResized", {
  group = resize_group,
  pattern = "*",
  command = "tabdo wincmd =",
  desc = "Auto-resize splits on terminal resize",
})

--------------------------------------------------------------------------------
-- Remove Trailing Whitespace on Save (Optional)
--------------------------------------------------------------------------------
-- Uncomment below if you want to automatically strip trailing whitespace
-- local strip_group = augroup("StripWhitespace", { clear = true })
--
-- autocmd("BufWritePre", {
--   group = strip_group,
--   pattern = "*",
--   callback = function()
--     local save_cursor = vim.fn.getpos(".")
--     vim.cmd([[%s/\s\+$//e]])
--     vim.fn.setpos(".", save_cursor)
--   end,
--   desc = "Strip trailing whitespace on save",
-- })

--------------------------------------------------------------------------------
-- Terminal Settings
--------------------------------------------------------------------------------
-- Automatically enter insert mode when opening a terminal
local terminal_group = augroup("TerminalSettings", { clear = true })

autocmd("TermOpen", {
  group = terminal_group,
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
  desc = "Configure terminal buffer settings",
})

--------------------------------------------------------------------------------
-- Help in Vertical Split
--------------------------------------------------------------------------------
-- Open help windows in a vertical split on the right
local help_group = augroup("HelpVerticalSplit", { clear = true })

autocmd("FileType", {
  group = help_group,
  pattern = "help",
  callback = function()
    vim.cmd("wincmd L")
  end,
  desc = "Open help in vertical split",
})
