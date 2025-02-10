return {
  "akinsho/bufferline.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    { "famiu/bufdelete.nvim" },
  },
  event = { "BufReadPre" },
  init = function()
    vim.opt.sessionoptions:append("globals")
  end,
  config = function()
    vim.keymap.set("n", "<C-l>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-h>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "L", ":BufferLineMoveNext<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "H", ":BufferLineMovePrev<CR>", { noremap = true, silent = true })
    vim.keymap.set("ca", "bco", "BufferLineCloseOthers")
    vim.keymap.set("ca", "bcr", "BufferLineCloseRight")
    vim.keymap.set("ca", "bcl", "BufferLineCloseLeft")

    require("bufferline").setup({
      options = {
        middle_mouse_command = "Bdelete %d",
        diagnostics = "nvim_lsp",
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
