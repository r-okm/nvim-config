---@type LazyPluginSpec
return {
  dir = "~/.config/nvim/lua/r-okm/husen",
  event = { "BufReadPre" },
  keys = {
    {
      "<leader>b",
      function()
        require("husen.commands").toggle_menu()
      end,
      desc = "Toggle buffer manager",
    },
    {
      "<C-h>",
      function()
        require("husen.commands").cycle(-1)
      end,
      desc = "Previous buffer",
    },
    {
      "<C-l>",
      function()
        require("husen.commands").cycle(1)
      end,
      desc = "Next buffer",
    },
    {
      "H",
      function()
        require("husen.commands").move(-1)
      end,
      desc = "Move buffer left",
    },
    {
      "L",
      function()
        require("husen.commands").move(1)
      end,
      desc = "Move buffer right",
    },
  },
  init = function()
    vim.opt.sessionoptions:append("globals")
  end,
  opts = {},
}
