return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre" },
  config = function()
    require("gitsigns").setup({
      current_line_blame_opts = {
        delay = 500,
      },
    })

    local keymap = function(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true })
    end
    keymap("n", "zn", ":<C-u>Gitsigns toggle_current_line_blame<CR>")
    keymap("n", "zm", ":<C-u>Gitsigns preview_hunk_inline<CR>")
    keymap("n", "zM", ":<C-u>Gitsigns reset_hunk<CR>")
    keymap("n", "z.", ":<C-u>Gitsigns next_hunk<CR>")
    keymap("n", "z,", ":<C-u>Gitsigns prev_hunk<CR>")
  end,
}
