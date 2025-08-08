---@type LazyPluginSpec
return {
  "j-hui/fidget.nvim",
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
