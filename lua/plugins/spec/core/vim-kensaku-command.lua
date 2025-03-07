return {
  "lambdalisue/vim-kensaku-command",
  dependencies = {
    { "vim-denops/denops.vim", lazy = false },
    { "lambdalisue/vim-kensaku", lazy = false },
  },
  keys = {
    { "?", ":<C-u>Kensaku ", mode = { "n" } },
  },
}
