---@type LazyPluginSpec
return {
  "https://github.com/famiu/bufdelete.nvim",
  keys = {
    { "<leader>w", ":<C-u>Bdelete<CR>", mode = { "n" }, silent = true },
  },
  cmd = { "Bdelete", "Bwipeout" },
}
