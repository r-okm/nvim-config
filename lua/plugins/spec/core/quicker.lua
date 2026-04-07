---@type LazyPluginSpec
return {
  "https://github.com/stevearc/quicker.nvim",
  branch = "master",
  ft = { "qf" },
  config = function()
    require("quicker").setup()
  end,
}
