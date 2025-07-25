---@type LazyPluginSpec
return {
  "OXY2DEV/markview.nvim",
  enabled = false,
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
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
