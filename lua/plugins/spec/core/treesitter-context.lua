---@type LazyPluginSpec
return {
  "nvim-treesitter/nvim-treesitter-context",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter" },
  },
  event = { "BufReadPost" },
  config = function()
    require("treesitter-context").setup({})
  end,
}
