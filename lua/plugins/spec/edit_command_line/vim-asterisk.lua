return {
  "haya14busa/vim-asterisk",
  keys = {
    { "*", mode = { "n", "x" } },
  },
  config = function()
    vim.keymap.set({ "n", "x" }, "*", "<Plug>(asterisk-gz*)")
  end,
}
