local util = {}

function util.list_insert_unique(tbl, vals)
  if type(vals) ~= "table" then
    vals = { vals }
  end
  for _, val in ipairs(vals) do
    if not vim.tbl_contains(tbl, val) then
      table.insert(tbl, val)
    end
  end
end

---@type LazySpec
local spec = {
  -- -- Add C# to treesitter
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = function(_, opts)
  --     if type(opts.ensure_installed) == "table" then
  --       util.list_insert_unique(opts.ensure_installed, "rust")
  --     end
  --   end,
  -- },
  -- {
  --   "neovim/nvim-lspconfig",
  --   dependencies = {
  --     {
  --       "simrat39/rust-tools.nvim",
  --       ---@diagnostic disable-next-line: unused-local
  --       config = function(_, _opts) end,
  --     },
  --   },
  --   ---@type PluginLspOpts
  --   opts = {
  --     servers = {
  --       -- Ensure mason installs the server
  --       rust_analyzer = {},
  --     },
  --     ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
  --     setup = {
  --       rust_analyzer = function(_, opts)
  --         local rt = require("rust-tools")
  --         require("lazyvim.util").on_attach(function(client, buffer) ---@param client lspconfig.options.rust_analyzer
  --           if client.name == "rust_analyzer" then
  --             vim.keymap.set("n", "<leader>ca", rt.code_action_group.code_action_group, { buffer = buffer })
  --             vim.keymap.set("n", "gh", rt.hover_actions.hover_actions, { buffer = buffer })
  --           end
  --         end)
  --
  --         rt.setup({
  --           server = opts,
  --         })
  --
  --         return true
  --       end,
  --     },
  --   },
  -- },
  {
    "Saecki/crates.nvim",
    opts = {
      lsp = {
        enabled = true,
        hover = true,
        completion = true,
        actions = true,
      },
    },
  },
  -- "hrsh7th/nvim-cmp",
  -- dependencies = {
  --   "Saecki/crates.nvim",
  -- },
  -- ---@param opts cmp.ConfigSchema
  -- opts = function(_, opts)
  --   local cmp = require("cmp")
  --   opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "crates" } }))
  -- end,
}

return spec
