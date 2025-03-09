local keymap = function(mode, lhs, rhs)
  local opts = { noremap = true, silent = true }
  vim.keymap.set(mode, lhs, rhs, opts)
end

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
    local bufferline = require("bufferline")

    keymap({ "n", "x" }, "<C-l>", function()
      bufferline.cycle(1)
    end)
    keymap({ "n", "x" }, "<C-h>", function()
      bufferline.cycle(-1)
    end)
    keymap({ "n", "x" }, "L", function()
      bufferline.move(1)
    end)
    keymap({ "n", "x" }, "H", function()
      bufferline.move(-1)
    end)
    keymap("ca", "bco", "BufferLineCloseOthers")
    keymap("ca", "bcr", "BufferLineCloseRight")
    keymap("ca", "bcl", "BufferLineCloseLeft")

    bufferline.setup({
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
