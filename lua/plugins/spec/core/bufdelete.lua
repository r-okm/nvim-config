return {
  "famiu/bufdelete.nvim",
  keys = {
    { "<leader>w", mode = { "n" } },
  },
  cmd = { "Bdelete", "Bwipeout" },
  config = function()
    vim.keymap.set("n", "<leader>w", ":<C-u>Bdelete<CR>", { noremap = true, silent = true })
  end,
}
