return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "zh", mode = { "n" } },
    { "zh", mode = { "x" } },
    { "zl", mode = { "n" } },
  },
  cmd = { "DiffviewFileHistory" },
  config = function()
    vim.keymap.set({ "n" }, "zh", ":<C-u>DiffviewFileHistory %<CR>", { silent = true })
    vim.keymap.set({ "x" }, "zh", ":'<,'>DiffviewFileHistory<CR>", { silent = true })
    vim.keymap.set({ "n" }, "zl", ":<C-u>DiffviewFileHistory<CR>", { silent = true })

    require("diffview").setup({
      keymaps = {
        view = {
          { "n", "q", ":<C-u>tabc<CR>" },
        },
        file_history_panel = {
          { "n", "q", ":<C-u>tabc<CR>" },
        },
      },
    })
  end,
}
