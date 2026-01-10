---@type LazyPluginSpec
return {
  dir = "~/.config/nvim/lua/r-okm/husen",
  cond = false,
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
      "[b",
      function()
        require("husen.commands").cycle(-1)
      end,
      desc = "Previous buffer",
    },
    {
      "]b",
      function()
        require("husen.commands").cycle(1)
      end,
      desc = "Next buffer",
    },
    {
      "[B",
      function()
        require("husen.commands").move(-1)
      end,
      desc = "Move buffer left",
    },
    {
      "]B",
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
