---@type LazyPluginSpec
return {
  "https://github.com/tyru/columnskip.vim",
  keys = {
    { "zj", "<Plug>(columnskip:nonblank:next)", mode = { "n", "x", "o" } },
    { "zk", "<Plug>(columnskip:nonblank:prev)", mode = { "n", "x", "o" } },
  },
}
