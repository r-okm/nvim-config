---@type LazyPluginSpec
return {
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  dependencies = {
    { "https://github.com/nvim-treesitter/nvim-treesitter" },
  },
  event = { "BufReadPost" },
  config = function()
    require("treesitter-context").setup({})
  end,
}
