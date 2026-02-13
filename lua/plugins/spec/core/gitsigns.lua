local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "https://github.com/lewis6991/gitsigns.nvim",
  event = { "BufReadPre" },
  cmd = { "Gitsigns" },
  init = function()
    util.keymap("ca", "gs", "Gitsigns")
  end,
  opts = {
    signcolumn = true,
    current_line_blame = false,
    current_line_blame_opts = {
      delay = 500,
    },
    on_attach = function(bufnr)
      local buf_keymap = function(mode, lhs, rhs)
        util.keymap(mode, lhs, rhs, { buffer = bufnr })
      end

      buf_keymap("n", "zn", ":<C-u>Gitsigns toggle_current_line_blame<CR>")
      buf_keymap("n", "zm", ":<C-u>Gitsigns preview_hunk<CR>")
      buf_keymap("n", "zM", ":<C-u>Gitsigns reset_hunk<CR>")
      buf_keymap("n", "z.", ":<C-u>Gitsigns next_hunk<CR>")
      buf_keymap("n", "z,", ":<C-u>Gitsigns prev_hunk<CR>")
    end,
  },
}
