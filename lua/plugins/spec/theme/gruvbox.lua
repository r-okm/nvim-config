---@type LazyPluginSpec
return {
  "https://github.com/ellisonleao/gruvbox.nvim",
  enabled = false,
  config = function()
    require("gruvbox").setup({
      italic = {
        strings = false,
        emphasis = false,
        comments = false,
        operators = false,
        folds = false,
      },
    })
    vim.cmd([[colorscheme gruvbox]])
  end,
}
