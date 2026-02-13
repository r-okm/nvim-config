local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "https://github.com/haya14busa/vim-asterisk",
  keys = {
    { "*", mode = { "n", "x" } },
  },
  config = function()
    util.keymap({ "n", "x" }, "*", "<Plug>(asterisk-gz*)")
  end,
}
