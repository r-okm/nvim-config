---@type LazyPluginSpec
return {
  "https://github.com/yutkat/wb-only-current-line.nvim",
  keys = {
    { "w", mode = { "n", "x", "o" } },
    { "b", mode = { "n", "x", "o" } },
  },
}
