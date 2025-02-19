return {
  "kevinhwang91/nvim-bqf",
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
