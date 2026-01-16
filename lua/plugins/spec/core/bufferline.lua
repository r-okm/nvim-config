---@type LazyPluginSpec
return {
  "akinsho/bufferline.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    { "catppuccin/nvim", name = "catppuccin" },
  },
  cond = false,
  event = { "BufReadPre" },
  keys = {
    {
      "<C-l>",
      function()
        require("bufferline").cycle(1)
      end,
      mode = { "n", "x" },
    },
    {
      "<C-h>",
      function()
        require("bufferline").cycle(-1)
      end,
      mode = { "n", "x" },
    },
    {
      "L",
      function()
        require("bufferline").move(1)
      end,
      mode = { "n", "x" },
    },
    {
      "H",
      function()
        require("bufferline").move(-1)
      end,
      mode = { "n", "x" },
    },
  },
  init = function()
    vim.opt.sessionoptions:append("globals")
  end,
  config = function()
    require("bufferline").setup({
      options = {
        middle_mouse_command = "Bdelete %d",
        diagnostics = "nvim_lsp",
        move_wraps_at_ends = true,
        separator_style = "thick",
        show_buffer_close_icons = false,
        indicator = {
          style = "underline",
        },
      },
      highlights = require("catppuccin.groups.integrations.bufferline").get(),
    })
  end,
}
