---@type LazyPluginSpec
return {
  "https://github.com/stevearc/quicker.nvim",
  ft = { "qf" },
  config = function()
    require("quicker").setup()
  end,
}
