return {
  "shellRaining/hlchunk.nvim",
  version = "v1.1.0",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  event = { "BufReadPre" },
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = true,
        use_treesitter = true,
        exclude_filetypes = {
          dockerfile = true,
          gitcommit = true,
          ["copilot-chat"] = true,
        },
      },
      indent = {
        enable = true,
        use_treesitter = true,
        exclude_filetypes = {
          dockerfile = true,
          gitcommit = true,
          ["copilot-chat"] = true,
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
