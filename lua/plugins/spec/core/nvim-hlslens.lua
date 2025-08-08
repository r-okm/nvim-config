local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "kevinhwang91/nvim-hlslens",
  dependencies = { "haya14busa/vim-asterisk" },
  keys = {
    { "*", mode = { "n", "x" } },
    { "n", mode = { "n" } },
    { "N", mode = { "n" } },
  },
  config = function()
    require("hlslens").setup({
      calm_down = true,
      nearest_only = true,
      nearest_float_when = "never",
    })
    util.keymap({ "n", "x" }, "*", [[<Plug>(asterisk-gz*)<Cmd>lua require("hlslens").start()<CR>]])
    util.keymap({ "n" }, "n", [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]])
    util.keymap({ "n" }, "N", [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]])
  end,
}
