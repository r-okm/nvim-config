---@type LazyPluginSpec
return {
  "https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
  event = { "BufReadPost" },
  dependencies = {
    { "nvim-treesitter/nvim-treesitter" },
  },
  main = "rainbow-delimiters.setup",
  ---@type rainbow_delimiters.config
  opts = {
    query = {
      ["tsx"] = "rainbow-parens",
    },
    highlight = {
      "RainbowDelimiterYellow",
      "RainbowDelimiterOrange",
      "RainbowDelimiterViolet",
      "RainbowDelimiterCyan",
    },
  },
}
