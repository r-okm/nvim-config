---@type LazyPluginSpec
return {
  "https://github.com/OXY2DEV/markview.nvim",
  enabled = false,
  dependencies = {
    { "https://github.com/nvim-tree/nvim-web-devicons" },
  },
  lazy = false,
  config = function()
    local markview = require("markview")
    markview.setup({
      preview = {
        enable = false,
        icon_provider = "devicons",
      },
    })

    local keymap = require("r-okm.util").keymap
    keymap({ "n", "x" }, "<C-k><C-v>", function()
      markview.commands.splitToggle()
    end)
  end,
}
