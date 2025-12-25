---@type LazyPluginSpec
return {
  "kevinhwang91/nvim-bqf",
  branch = "main",
  dependencies = {
    { "junegunn/fzf" },
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
