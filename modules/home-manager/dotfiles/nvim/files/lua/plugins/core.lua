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
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = {
        ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-h>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<C-l>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<S-CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }
    end,
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
    "kevinhwang91/rnvimr",
    keys = {
      { "<leader>r", "<cmd>RnvimrToggle<cr>", mode = "n", desc = "Open Ranger" },
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
      ---@type lspconfig.options
      servers = {
        taplo = {
          mason = false,
          cmd = { "taplo", "lsp", "stdio" },
        },
      },
    },
  },
}
