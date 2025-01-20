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
  cmd = { "DiffviewFileHistory", "DiffviewOpen" },
  config = function()
    vim.keymap.set({ "n" }, "zh", ":<C-u>DiffviewFileHistory %<CR>", { silent = true })
    vim.keymap.set({ "x" }, "zh", ":'<,'>DiffviewFileHistory<CR>", { silent = true })
    vim.keymap.set({ "n" }, "zl", ":<C-u>DiffviewFileHistory<CR>", { silent = true })

    local actions = require("diffview.config").actions
    require("diffview").setup({
      view = {
        merge_tool = {
          layout = "diff3_mixed",
        },
      },
      keymaps = {
        view = {
          { "n", "q", ":<C-u>tabc<CR>" },
          ["g."] = actions.next_conflict,
          ["g,"] = actions.prev_conflict,
          ["g1"] = actions.conflict_choose("ours"),
          ["g2"] = actions.conflict_choose("theirs"),
        },
        file_history_panel = {
          { "n", "q", ":<C-u>tabc<CR>" },
        },
        file_panel = {
          { "n", "q", ":<C-u>tabc<CR>" },
        },
      },
    })
  end,
}
