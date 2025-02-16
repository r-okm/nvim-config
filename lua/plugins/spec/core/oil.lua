return {
  "stevearc/oil.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
  },
  branch = "master",
  lazy = false,
  config = function()
    local oil = require("oil")
    oil.setup({
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        ["<C-l>"] = "actions.preview",
        ["q"] = { "actions.close", mode = "n" },
        ["<C-h>"] = { "actions.parent", mode = "n" },
        ["-"] = { "actions.open_cwd", mode = "n" },
      },
      use_default_keymaps = false,
      view_options = {
        show_hidden = true,
      },
    })
    vim.keymap.set({ "n" }, "<space>e", function()
      oil.open(nil, {
        preview = { vertical = true },
      })
    end)
    vim.keymap.set({ "n" }, "<space>E", function()
      oil.open()
    end)
    vim.keymap.set("ca", "os", "e oil-ssh://")
  end,
}
