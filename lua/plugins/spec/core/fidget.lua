---@type LazyPluginSpec
return {
  "https://github.com/j-hui/fidget.nvim",
  event = { "BufReadPost" },
  opts = {
    progress = {
      ignore = { "null-ls" },
    },
    notification = {
      window = {
        winblend = 0,
      },
    },
  },
}
