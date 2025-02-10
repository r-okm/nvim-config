return {
  "lambdalisue/vim-kensaku-command",
  dependencies = {
    { "vim-denops/denops.vim" },
    { "lambdalisue/vim-kensaku" },
  },
  lazy = false,
  keys = {
    { "?", ":<C-u>Kensaku ", mode = { "n" } },
  },
}
