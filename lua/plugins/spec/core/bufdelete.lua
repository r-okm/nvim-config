---@type LazyPluginSpec
return {
  "famiu/bufdelete.nvim",
  keys = {
    { "<leader>w", ":<C-u>Bdelete<CR>", mode = { "n" } },
  },
  cmd = { "Bdelete", "Bwipeout" },
}
