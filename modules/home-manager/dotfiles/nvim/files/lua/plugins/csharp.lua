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

local spec = {

  -- Add C# to treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        util.list_insert_unique(opts.ensure_installed, "c_sharp")
      end
    end,
  },
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
  },
  -- Correctly setup lspconfig for C# 🚀
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "Hoffs/omnisharp-extended-lsp.nvim",
    },
    opts = {
      servers = {
        -- Ensure mason installs the server
        omnisharp = {},
      },
      -- configure omnisharp to fix the semantic tokens bug (really annoying)
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        omnisharp = function(_, opts)
          ---@param input string
          ---@return string
          local function toCamelCase(input)
            local words = {} ---@type string[]
            local sanitized_input = input:gsub("[^%w%s]", " ")
            for word in sanitized_input:gmatch("%S+") do
              table.insert(words, word:lower())
            end

            for i = 2, #words do
              words[i] = words[i]:gsub("^%l", string.upper)
            end

            return table.concat(words)
          end

          local on_attach = function(client, bufnr)
            client.server_capabilities = vim.tbl_extend("keep", client.server_capabilities, {
              codeActionProvider = {
                codeActionKinds = { "", "quickfix", "refactor.rewrite", "refactor.extract" },
              },
              documentFormattingProvider = true,
              documentRangeFormattingProvider = true,
              renameProvider = {
                prepareProvider = true,
              },
            })

            opts.on_attach(client, bufnr)
          end

          opts.on_attach = on_attach

          require("lazyvim.util").lsp.on_attach(function(client, _) ---@param client lspconfig.options.omnisharp
            if client.name == "omnisharp" then
              local tokenModifiers = client.server_capabilities.semanticTokensProvider.legend.tokenModifiers ---@type string[]
              for i, v in ipairs(tokenModifiers) do
                if v:match(" name$") then
                  tokenModifiers[i] = v:gsub(" name$", "")
                end
                tokenModifiers[i] = toCamelCase(tokenModifiers[i])
              end

              local tokenTypes = client.server_capabilities.semanticTokensProvider.legend.tokenTypes ---@type string[]
              for i, v in ipairs(tokenTypes) do
                if v:match(" name$") then
                  tokenTypes[i] = v:gsub(" name$", "")
                end
                tokenTypes[i] = toCamelCase(tokenTypes[i])
              end

              vim.keymap.set("n", "gd", require("omnisharp_extended").telescope_lsp_definitions, { buffer = true })
            end
          end)

          opts.handlers = { ["textDocument/definition"] = require("omnisharp_extended").handler }

          return false
        end,
      },
    },
  },
  {
    "adamclerk/vim-razor",
  },
}

return {} -- spec
