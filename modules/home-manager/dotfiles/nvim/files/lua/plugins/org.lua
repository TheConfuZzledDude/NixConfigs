---@type LazySpec
local spec = {
  {
    "nvim-orgmode/orgmode",
    config = function(_, opts)
      require("orgmode").setup(opts)
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter", "danilshvalov/org-modern.nvim" },
    opts = {
      ui = {
        menu = {
          handler = function(data)
            local Menu = require("org-modern.menu")
            Menu:new({
              window = {
                margin = { 1, 0, 1, 0 },
                padding = { 0, 1, 0, 1 },
                title_pos = "center",
                border = "single",
                zindex = 1000,
              },
              icons = {
                separator = "➜",
              },
            }):open(data)
          end,
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = {
        enable = true,
        -- Required for spellcheck, some LaTex highlights and
        -- code block highlights that do not have ts grammar
        additional_vim_regex_highlighting = { "org" },
      },
      ensure_installed = { "org" }, -- Or run :TSUpdate org
    },
  },
  {
    "vhyrro/luarocks.nvim",
    priority = 1000, -- We'd like this plugin to load first out of the rest
    config = true, -- This automatically runs `require("luarocks-nvim").setup()`
  },
  {
    "nvim-neorg/neorg",
    dependencies = { "luarocks.nvim" },
    lazy = false,
    version = "*",
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = {}, -- Adds pretty icons to your documents
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = "~/notes",
              },
            },
          },
          ["core.completion"] = {
            config = { engine = "nvim-cmp" },
          },
        },
      })
    end,
  },
  {
    "saghen/blink.compat",
    -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
    version = "*",
    -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
    lazy = true,
    -- make sure to set opts so that lazy.nvim calls blink.compat's setup
    opts = {},
  },
  {
    "saghen/blink.cmp",
    dependencies = { "nvim-neorg/neorg" },
    opts = {
      sources = {
        default = { "neorg" },
        providers = {
          neorg = {
            name = "neorg",
            module = "blink.compat.source",
          },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}

return spec
