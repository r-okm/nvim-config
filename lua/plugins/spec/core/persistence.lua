local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "https://github.com/folke/persistence.nvim",
  event = "BufReadPre",
  init = function()
    vim.api.nvim_create_user_command(
      "LoadSession",
      require("persistence").load,
      { desc = "Persistence: Restore previous session" }
    )
    util.keymap("ca", "ls", "LoadSession")
  end,
  opts = {},
}
