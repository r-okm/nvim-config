return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
  },
  config = function()
    local markview = require("markview")
    markview.setup({
      preview = {
        enable = false,
        icon_provider = "devicons",
      },
    })

    local keymap = vim.keymap.set
    keymap({ "n", "x" }, "<C-k><C-v>", function()
      markview.commands.splitToggle()
    end, { silent = true, noremap = true })
  end,
}
