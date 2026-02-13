---@type LazyPluginSpec
return {
  "https://github.com/shellRaining/hlchunk.nvim",
  enabled = false,
  version = "v1.1.0",
  dependencies = {
    "https://github.com/nvim-treesitter/nvim-treesitter",
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
