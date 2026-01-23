-- plugins/init.lua
-- Plugin management with lazy.nvim
-- All plugins configured inline with explanations

--------------------------------------------------------------------------------
-- Bootstrap lazy.nvim
--------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- Plugin Specifications
--------------------------------------------------------------------------------
require("lazy").setup({

  ----------------------------------------------------------------------------
  -- Colorscheme (loaded from theme module for easy swapping)
  ----------------------------------------------------------------------------
  require("theme").plugin,

  ----------------------------------------------------------------------------
  -- Icons (used by nvim-tree, telescope, lualine, etc.)
  -- Requires a Nerd Font to be installed and configured in your terminal
  ----------------------------------------------------------------------------
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,   -- Load early so icons are available for all plugins
    priority = 100, -- Load before plugins that need icons
    config = function()
      require("nvim-web-devicons").setup({
        -- Use default icon colors (can be customized if needed)
        default = true,
        -- Ensure strict mode is off so missing icons fallback gracefully
        strict = false,
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- File Tree (replaces NERDTree)
  ----------------------------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      -- <Leader>q toggles file tree (preserved from your vimrc)
      { "<Leader>q", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" },
    },
    config = function()
      require("nvim-tree").setup({
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end
          -- Apply default mappings first
          api.config.mappings.default_on_attach(bufnr)
          -- Custom mappings
          vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))
        end,
        view = {
          width = 35,
          side = "left",
        },
        renderer = {
          group_empty = true,          -- Collapse empty folders
          highlight_git = true,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,            -- Show dotfiles
          custom = { ".git", "node_modules", ".cache" },
        },
        git = {
          enable = true,
          ignore = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,      -- Keep tree open after opening file
            resize_window = true,
          },
        },
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- Fuzzy Finder (replaces ctrlp.vim and fzf.vim)
  ----------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Native FZF for better sorting performance
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<Leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<Leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<Leader>fb", "<cmd>Telescope buffers<CR>", desc = "List buffers" },
      { "<Leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<Leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<Leader>fc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
      { "<Leader>fs", "<cmd>Telescope git_status<CR>", desc = "Git status" },
      { "<C-p>", "<cmd>Telescope find_files<CR>", desc = "Find files (Ctrl-P)" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
            width = 0.87,
            height = 0.80,
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
          },
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "vendor/",
            "*.min.js",
          },
        },
        pickers = {
          find_files = {
            hidden = true,             -- Show hidden files
            follow = true,             -- Follow symlinks
          },
          live_grep = {
            additional_args = function()
              return { "--hidden" }    -- Search hidden files
            end,
          },
        },
      })

      -- Load fzf-native extension for better performance
      telescope.load_extension("fzf")
    end,
  },

  ----------------------------------------------------------------------------
  -- Treesitter (modern syntax highlighting & parsing)
  -- Loaded on VeryLazy to ensure it's ready before Telescope opens
  ----------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "VeryLazy",
    config = function()
      -- Use pcall to handle API changes gracefully
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup({
          ensure_installed = {
            "ruby",
            "javascript",
            "typescript",
            "tsx",
            "go",
            "yaml",
            "json",
            "html",
            "css",
            "lua",
            "vim",
            "vimdoc",
            "markdown",
            "markdown_inline",
            "bash",
            "regex",
            "elixir",
          },
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = {
            enable = true,
          },
        })
      else
        -- Fallback for newer treesitter versions or if configs module unavailable
        -- Enable highlighting via the newer API
        vim.treesitter.language.register("markdown", "mdx")
        -- Parsers will be auto-installed via :TSInstall command
        vim.notify("Treesitter: Run :TSUpdate to install parsers", vim.log.levels.INFO)
      end
    end,
  },

  -- Auto-close HTML/JSX tags (separate from treesitter, requires its own setup)
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
      },
    },
  },

  ----------------------------------------------------------------------------
  -- LSP Configuration (Neovim 0.11+ native vim.lsp.config API)
  ----------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ruby_lsp",      -- Ruby (preferred, requires Ruby 3.0+)
          "solargraph",    -- Ruby (fallback for older Ruby versions)
          "ts_ls",         -- TypeScript/JavaScript
          "gopls",         -- Go
          "yamlls",        -- YAML
          "lua_ls",        -- Lua (for nvim config editing)
        },
        automatic_installation = true,
      })
    end,
  },

  {
    "j-hui/fidget.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("fidget").setup({})
    end,
  },

  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = false,
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- LSP keymaps (only active in buffers with LSP attached)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map = function(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
          end

          -- Navigation
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gr", vim.lsp.buf.references, "Go to references")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gI", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "K", vim.lsp.buf.hover, "Hover documentation")

          -- Actions
          map("n", "<Leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<Leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "<Leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")

          -- Diagnostics
          map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
          map("n", "<Leader>e", vim.diagnostic.open_float, "Show diagnostic")
          map("n", "<Leader>ld", vim.diagnostic.setloclist, "Diagnostics to loclist")
        end,
      })

      -- Configure LSP servers using Neovim 0.11 native API
      -- Ruby LSP (preferred for modern Ruby development, requires Ruby 3.0+)
      vim.lsp.config("ruby_lsp", {
        capabilities = capabilities,
      })

      -- Solargraph (fallback for older Ruby versions)
      vim.lsp.config("solargraph", {
        capabilities = capabilities,
        settings = {
          solargraph = {
            diagnostics = true,
            completion = true,
            hover = true,
            references = true,
            rename = true,
            symbols = true,
          },
        },
      })

      -- TypeScript/JavaScript
      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
            },
          },
        },
      })

      -- Go
      vim.lsp.config("gopls", {
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
      })

      -- YAML
      vim.lsp.config("yamlls", {
        capabilities = capabilities,
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            },
          },
        },
      })

      -- Lua (for editing Neovim config)
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      -- Enable all configured LSP servers
      vim.lsp.enable("ruby_lsp")
      vim.lsp.enable("solargraph")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("gopls")
      vim.lsp.enable("yamlls")
      vim.lsp.enable("lua_ls")

      -- Configure diagnostic display
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- Autocompletion (replaces supertab + snipmate)
  ----------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippet engine
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      -- Completion sources
      "hrsh7th/cmp-nvim-lsp",    -- LSP completions
      "hrsh7th/cmp-buffer",      -- Buffer words
      "hrsh7th/cmp-path",        -- File paths
      -- Snippet collection (like vim-snippets)
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Load VSCode-style snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          -- Tab to cycle through completions (like supertab)
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          -- Enter to confirm selection
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          -- Ctrl+Space to trigger completion
          ["<C-Space>"] = cmp.mapping.complete(),
          -- Ctrl+e to close completion menu
          ["<C-e>"] = cmp.mapping.abort(),
          -- Scroll docs
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
        }),
        sources = cmp.config.sources({
          { name = "codeium", priority = 1100 },
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
        formatting = {
          format = function(entry, vim_item)
            -- Source labels
            vim_item.menu = ({
              codeium = "[AI]",
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- AI Autocompletion (Codeium - Lua version with nvim-cmp integration)
  ----------------------------------------------------------------------------
  {
    "Exafunction/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    event = "InsertEnter",
    config = function()
      require("codeium").setup({})
    end,
  },

  ----------------------------------------------------------------------------
  -- Commenting (replaces tcomment_vim)
  ----------------------------------------------------------------------------
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("Comment").setup({
        -- gcc to comment line, gc in visual mode to comment selection
        -- These are the defaults and match tcomment behavior
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- Auto Pairs (replaces auto-pairs)
  ----------------------------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true, -- Use treesitter for smarter pairing
      })
      -- Integrate with nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  ----------------------------------------------------------------------------
  -- Surround (keeping vim-surround, it works perfectly in nvim)
  ----------------------------------------------------------------------------
  {
    "tpope/vim-surround",
    event = { "BufReadPost", "BufNewFile" },
  },

  ----------------------------------------------------------------------------
  -- Git Integration (keeping vim-fugitive)
  ----------------------------------------------------------------------------
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiff", "Gblame", "Glog" },
    keys = {
      { "<Leader>gs", "<cmd>Git<CR>", desc = "Git status" },
      { "<Leader>gb", "<cmd>Git blame<CR>", desc = "Git blame" },
      { "<Leader>gd", "<cmd>Gdiff<CR>", desc = "Git diff" },
    },
  },

  -- Git signs in the gutter (additions, deletions, changes)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local gitsigns = require("gitsigns")
      gitsigns.setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          -- Navigation
          map("n", "]h", gitsigns.next_hunk, "Next hunk")
          map("n", "[h", gitsigns.prev_hunk, "Previous hunk")

          -- Actions
          map("n", "<Leader>hs", gitsigns.stage_hunk, "Stage hunk")
          map("n", "<Leader>hr", gitsigns.reset_hunk, "Reset hunk")
          map("n", "<Leader>hp", gitsigns.preview_hunk, "Preview hunk")
          map("n", "<Leader>hu", gitsigns.undo_stage_hunk, "Undo stage hunk")
          map("n", "<Leader>hb", function() gitsigns.blame_line({ full = true }) end, "Blame line")
        end,
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- Rails Support (keeping vim-rails)
  ----------------------------------------------------------------------------
  {
    "tpope/vim-rails",
    ft = { "ruby", "eruby" },
  },

  ----------------------------------------------------------------------------
  -- Test Runner (keeping vim-test)
  ----------------------------------------------------------------------------
  {
    "vim-test/vim-test",
    keys = {
      { "<Leader>c", "<cmd>TestFile<CR>", desc = "Test file" },
      { "<Leader>s", "<cmd>TestNearest<CR>", desc = "Test nearest" },
      { "<Leader>T", "<cmd>TestSuite<CR>", desc = "Test suite" },
      { "<Leader>l", "<cmd>TestLast<CR>", desc = "Test last" },
      { "<Leader>v", "<cmd>TestVisit<CR>", desc = "Test visit" },
    },
    config = function()
      -- Use neovim's built-in terminal for test output
      vim.g["test#strategy"] = "neovim"
      -- Keep terminal open after test finishes
      vim.g["test#neovim#term_position"] = "botright 15"
    end,
  },

  ----------------------------------------------------------------------------
  -- Status Line
  ----------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          theme = require("theme").lualine,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } }, -- Relative path
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- Which Key (shows available keybindings)
  ----------------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        delay = 500, -- Show after 500ms
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- Indent Guides (visual indentation lines)
  ----------------------------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local theme = require("theme")
      local hooks = require("ibl.hooks")

      -- Define highlight groups before setup (colors from theme)
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "IblIndent", vim.tbl_extend("force", theme.indent_blankline.indent, { nocombine = true }))
        vim.api.nvim_set_hl(0, "IblScope", vim.tbl_extend("force", theme.indent_blankline.scope, { nocombine = true }))
      end)

      require("ibl").setup({
        indent = {
          char = "│",
          highlight = "IblIndent",
        },
        scope = {
          enabled = true,
          show_start = false,
          show_end = false,
          highlight = "IblScope",
        },
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- Emmet (keeping for HTML/JSX expansion)
  ----------------------------------------------------------------------------
  {
    "mattn/emmet-vim",
    ft = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact", "eruby" },
  },

}, {
  -- lazy.nvim configuration
  install = {
    colorscheme = { "dracula" },
  },
  checker = {
    enabled = true,       -- Check for plugin updates
    notify = false,       -- Don't notify on updates
  },
  change_detection = {
    notify = false,       -- Don't notify when config changes
  },
  ui = {
    border = "rounded",
  },
  rocks = {
    enabled = false,      -- Disable luarocks (no plugins require it)
  },
})
