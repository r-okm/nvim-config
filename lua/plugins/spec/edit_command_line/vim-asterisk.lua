local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "haya14busa/vim-asterisk",
  keys = {
    { "*", mode = { "n", "x" } },
  },
  config = function()
    util.keymap({ "n", "x" }, "*", "<Plug>(asterisk-gz*)")
  end,
}
