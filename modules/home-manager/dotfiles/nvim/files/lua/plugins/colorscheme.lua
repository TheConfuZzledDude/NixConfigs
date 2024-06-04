return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    ---@type CatppuccinOptions
    opts = {
      flavour = "frappe",
      transparent_background = not vim.g.neovide,
      term_colors = true,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  {
    "rcarriga/nvim-notify",
    ---@class Config.Notify : notify.Config
    ---@type Config.Notify
    opts = {
      background_colour = vim.g.neovide and "#000000" or nil,
    },
  },
}
