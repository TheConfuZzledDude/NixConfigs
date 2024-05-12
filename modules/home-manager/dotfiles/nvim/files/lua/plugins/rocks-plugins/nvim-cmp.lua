local cmp = require("cmp")
require'cmp_nvim_lsp'.setup {}
require'cmp_buffer'.setup {}
require'cmp_path'.setup{}

cmp.setup({
    completion = {
        completeopt= "menu,menuone,noinsert",
    },
    sources = {
        { name = 'nvim_lsp'},
        { name = 'path'},
        { name = 'buffer'},
        { name = 'snippets'},
    },
    mapping = cmp.mapping.preset.insert {
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
    }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items
},
    snippet = {
      expand = function(args)
        vim.snippet.expand(args.body)
      end,
  },
})
