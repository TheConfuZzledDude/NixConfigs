return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "frappe",
      transparent_background = true,
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
    ---@type notify.Config
    opts = {
      background_colour = "#000000",
    },
  },
}
