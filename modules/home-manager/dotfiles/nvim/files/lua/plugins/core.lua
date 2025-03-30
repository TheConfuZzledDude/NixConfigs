---@type LazyPluginSpec[]
return {
  {
    "LazyVim/LazyVim",
    opts = {
      defaults = {
        keymaps = true,
      },
    },
  },
  {
    "lambdalisue/suda.vim",
  },
  {
    "saghen/blink.cmp",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        ["<C-j>"] = { "snippet_forward", "select_next", "fallback" },
        ["<C-k>"] = { "snippet_backward", "select_prev", "fallback" },
        ["<C-h>"] = { "cancel", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-l>"] = { "select_and_accept", "fallback" },
      },
    },
  },
  {
    "voldikss/vim-floaterm",
    cmd = {
      "FloatermNext",
      "FloatermPrev",
      "FloatermToggle",
      "FloatermUpdate",
      "FloatermLast",
      "FloatermFirst",
      "FloatermHide",
      "FloatermShow",
      "FloatermKill",
      "FloatermSend",
    },
    keys = {
      { "<Leader>ft", "<cmd>FloatermToggle<cr>", mode = "n", desc = "Open floating terminal" },
    },
  },
  {
    "folke/zen-mode.nvim",
    ---@type ZenOptions
    opts = {
      plugins = {
        wezterm = {
          enabled = true,
          font = "+4",
        },
      },
    },
  },
  {
    "folke/twilight.nvim",
    ---@type TwilightOptions
    opts = {
      dimming = { alpha = 0.5 },
    },
  },
  {
    "folke/flash.nvim",
    ---@type Flash.Config
    opts = {
      modes = {
        search = {
          enabled = false,
        },
      },
    },
  },
  {
    "ahmedkhalf/project.nvim",
    opts = {
      manual_mode = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        taplo = {
          mason = false,
          cmd = { "taplo", "lsp", "stdio" },
        },
      },
    },
  },
  ---@type LazySpec
  {
    "mikavilpas/yazi.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>-",
        function()
          require("yazi").yazi()
        end,
        desc = "Open the file manager",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        function()
          require("yazi").yazi(nil, vim.fn.getcwd())
        end,
        desc = "Open the file manager in nvim's working directory",
      },
    },
    ---@type YaziConfig
    opts = {
      open_for_directories = false,
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      pickers = {
        find_files = {
          follow = true,
        },
      },
    },
  },
  {
    "isobit/vim-caddyfile",
  },
  {
    "stevearc/conform.nvim",
    ---@type ConformOpts
    opts = {
      formatters = {
        caddyfmt = {
          command = "caddy",
          args = { "fmt", "-" },
          stdin = true,
        },
      },
      formatters_by_ft = {
        caddyfile = { "caddyfmt" },
      },
    },
  },
  {
    "folke/lazydev.nvim",
    dependencies = {
      "justinsgithub/wezterm-types",
      "LuaCATS/love2d",
    },
    ---@class lazydev.Config
    opts = {
      library = {
        {
          path = "wezterm-types",
          mods = { "wezterm" },
        },
        {
          path = "love2d",
          words = { "love" },
        },
      },
    },
  },
  {
    "rpdelaney/vim-sourcecfg",
  },
}
