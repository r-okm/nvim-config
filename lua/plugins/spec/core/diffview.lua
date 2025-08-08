local util = require("r-okm.util")

---@type LazyPluginSpec
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
    util.keymap({ "n" }, "zh", ":<C-u>DiffviewFileHistory %<CR>")
    util.keymap({ "x" }, "zh", ":'<,'>DiffviewFileHistory<CR>")
    util.keymap({ "n" }, "zl", ":<C-u>DiffviewFileHistory<CR>")

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
