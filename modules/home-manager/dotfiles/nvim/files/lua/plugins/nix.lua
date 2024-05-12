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
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        util.list_insert_unique(opts.ensure_installed, "nix")
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    ---@type PluginLspOpts
    opts = {
      servers = {
        -- Ensure mason installs the server
        nil_ls = {},
        nixd = {},
      },
      setup = {
        nil_ls = function(_, opts)
          opts.settings = {
            ["nil"] = {
              formatting = {
                command = { "alejandra" },
              },
            },
          }
        end,
        nixd = function(_, opts) end,
      },
    },
  },
}

return spec
