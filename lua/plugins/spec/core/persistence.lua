return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  init = function()
    local function loadSession()
      require("persistence").load()
    end
    vim.api.nvim_create_user_command("LoadSession", loadSession, {})
    vim.keymap.set("ca", "ls", "LoadSession")
  end,
  opts = {},
}
