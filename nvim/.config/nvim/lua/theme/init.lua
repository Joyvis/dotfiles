-- theme/init.lua
-- Centralized theme configuration
-- Replace this folder to change themes without touching other config

local M = {}

--------------------------------------------------------------------------------
-- Theme Plugin Spec (for lazy.nvim)
--------------------------------------------------------------------------------
M.plugin = {
  "Mofiqul/dracula.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("dracula").setup({
      transparent_bg = true, -- Enable transparent background to show terminal background
    })
    -- Set background to dark for proper syntax highlighting
    vim.opt.background = "dark"
    vim.cmd.colorscheme("dracula")

    -- Apply transparency after colorscheme loads
    require("theme").apply_transparency()
  end,
}

--------------------------------------------------------------------------------
-- Lualine Theme (Dracula colors with transparent backgrounds)
--------------------------------------------------------------------------------
M.lualine = {
  normal = {
    a = { fg = "#bd93f9", bg = "NONE", gui = "bold" }, -- Purple
    b = { fg = "#f8f8f2", bg = "NONE" },               -- Foreground
    c = { fg = "#f8f8f2", bg = "NONE" },
  },
  insert = {
    a = { fg = "#50fa7b", bg = "NONE", gui = "bold" }, -- Green
  },
  visual = {
    a = { fg = "#ff79c6", bg = "NONE", gui = "bold" }, -- Pink
  },
  replace = {
    a = { fg = "#ff5555", bg = "NONE", gui = "bold" }, -- Red
  },
  command = {
    a = { fg = "#f1fa8c", bg = "NONE", gui = "bold" }, -- Yellow
  },
  inactive = {
    a = { fg = "#6272a4", bg = "NONE" },               -- Comment
    b = { fg = "#6272a4", bg = "NONE" },
    c = { fg = "#6272a4", bg = "NONE" },
  },
}

--------------------------------------------------------------------------------
-- Indent Blankline Colors (Dracula dark theme)
--------------------------------------------------------------------------------
M.indent_blankline = {
  indent = { fg = "#44475a" }, -- Current line (subtle)
  scope = { fg = "#6272a4" },  -- Comment (more visible for scope)
}

--------------------------------------------------------------------------------
-- Transparency Settings
--------------------------------------------------------------------------------
M.transparent = true -- Set to false to disable transparency

M.apply_transparency = function()
  if not M.transparent then
    return
  end

  local groups = {
    -- Core editor
    "Normal",
    "NormalNC",
    "NormalFloat",
    "SignColumn",
    "EndOfBuffer",
    "LineNr",
    "CursorLineNr",
    "CursorLine",
    "Folded",
    "FoldColumn",
    "VertSplit",
    "WinSeparator",
    -- Status/Tab lines
    "StatusLine",
    "StatusLineNC",
    "TabLine",
    "TabLineFill",
    -- Popup menu
    "Pmenu",
    "PmenuSbar",
    -- NvimTree
    "NvimTreeNormal",
    "NvimTreeNormalNC",
    "NvimTreeWinSeparator",
    "NvimTreeEndOfBuffer",
    "NvimTreeVertSplit",
    -- Telescope
    "TelescopeNormal",
    "TelescopeBorder",
    "TelescopePromptNormal",
    "TelescopePromptBorder",
    "TelescopeResultsNormal",
    "TelescopeResultsBorder",
    "TelescopePreviewNormal",
    "TelescopePreviewBorder",
    -- Which-key
    "WhichKeyFloat",
    -- Floating windows
    "FloatBorder",
    -- Git signs
    "GitSignsAdd",
    "GitSignsChange",
    "GitSignsDelete",
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
  end
end

return M
