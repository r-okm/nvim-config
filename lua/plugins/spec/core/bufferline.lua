local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "akinsho/bufferline.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
  },
  enabled = false,
  event = { "BufReadPre" },
  init = function()
    vim.opt.sessionoptions:append("globals")
  end,
  config = function()
    local bufferline = require("bufferline")

    util.keymap({ "n", "x" }, "<C-l>", function()
      bufferline.cycle(1)
    end)
    util.keymap({ "n", "x" }, "<C-h>", function()
      bufferline.cycle(-1)
    end)
    util.keymap({ "n", "x" }, "L", function()
      bufferline.move(1)
    end)
    util.keymap({ "n", "x" }, "H", function()
      bufferline.move(-1)
    end)

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
