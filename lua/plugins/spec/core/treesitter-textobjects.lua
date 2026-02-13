---@type LazyPluginSpec
return {
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = {
    { "https://github.com/nvim-treesitter/nvim-treesitter" },
  },
  init = function()
    vim.g.no_plugin_maps = true
  end,
  ---@type TSTextObjects.UserConfig
  opts = {
    select = {
      lookahead = true,
      selection_modes = {
        ["@function.inner"] = "V",
      },
    },
  },
  keys = {
    {
      "af",
      function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
      end,
      mode = { "x", "o" },
      desc = "Select around function",
    },
    {
      "if",
      function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
      end,
      mode = { "x", "o" },
      desc = "Select inside function",
    },
    {
      "ac",
      function()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
      end,
      mode = { "x", "o" },
      desc = "Select around class",
    },
    {
      "ic",
      function()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
      end,
      mode = { "x", "o" },
      desc = "Select inside class",
    },
    {
      "ap",
      function()
        require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
      end,
      mode = { "x", "o" },
      desc = "Select around parameter",
    },
    {
      "ip",
      function()
        require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
      end,
      mode = { "x", "o" },
      desc = "Select inside parameter",
    },
  },
}
