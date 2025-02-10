return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre" },
  config = function()
    require("gitsigns").setup({
      current_line_blame_opts = {
        delay = 500,
      },
    })
    vim.keymap.set("ca", "gst", "Gitsigns toggle_current_line_blame")
  end,
}
