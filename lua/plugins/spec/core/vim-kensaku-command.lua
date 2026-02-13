---@type LazyPluginSpec
return {
  "https://github.com/lambdalisue/vim-kensaku-command",
  dependencies = {
    { "https://github.com/vim-denops/denops.vim", lazy = false },
    { "https://github.com/lambdalisue/vim-kensaku", lazy = false },
  },
  keys = {
    { "?", ":<C-u>Kensaku ", mode = { "n" } },
  },
}
