local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "famiu/bufdelete.nvim",
  keys = {
    { "<leader>w", mode = { "n" } },
  },
  cmd = { "Bdelete", "Bwipeout" },
  config = function()
    util.keymap("n", "<leader>w", ":<C-u>Bdelete<CR>")
  end,
}
