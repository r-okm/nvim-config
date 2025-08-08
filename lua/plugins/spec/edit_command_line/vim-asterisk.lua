local util = require("r-okm.util")

---@type vim.lsp.Config
return {
  "haya14busa/vim-asterisk",
  keys = {
    { "*", mode = { "n", "x" } },
  },
  config = function()
    util.keymap({ "n", "x" }, "*", "<Plug>(asterisk-gz*)")
  end,
}
