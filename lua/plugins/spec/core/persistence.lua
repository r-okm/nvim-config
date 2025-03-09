return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  init = function()
    vim.api.nvim_create_user_command(
      "LoadSession",
      require("persistence").load,
      { desc = "Persistence: Restore previous session" }
    )
    vim.keymap.set("ca", "ls", "LoadSession")
  end,
  opts = {},
}
