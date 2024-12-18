return {
  "shellRaining/hlchunk.nvim",
  version = "v1.1.0",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  event = { "UIEnter" },
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = true,
        use_treesitter = true,
        exclude_filetypes = {
          dockerfile = true,
        },
      },
      indent = {
        enable = true,
        use_treesitter = true,
        exclude_filetypes = {
          dockerfile = true,
        },
      },
      line_num = {
        enable = false,
      },
      blank = {
        enable = false,
      },
    })
  end,
}
