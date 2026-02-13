---@type LazyPluginSpec
return {
  "https://github.com/kevinhwang91/nvim-bqf",
  branch = "main",
  dependencies = {
    { "https://github.com/junegunn/fzf" },
  },
  ft = { "qf" },
  config = function()
    require("bqf").setup({
      func_map = {
        vsplit = "",
      },
    })
  end,
}
