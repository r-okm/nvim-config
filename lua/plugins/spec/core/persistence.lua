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
    util.keymap("ca", "ls", "LoadSession", { silent = false })

    -- mksession は arglist を無条件に保存し、復元時の $argadd が :Bdelete 済み
    -- バッファを listed として復活させてしまうため、保存前に arglist を空にする
    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceSavePre",
      callback = function()
        vim.cmd("silent! %argdelete")
      end,
    })
  end,
  opts = {},
}
