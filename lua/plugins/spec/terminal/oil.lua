return {
  "stevearc/oil.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
  },
  branch = "master",
  lazy = false,
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
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
  },
  keys = {
    {
      "<space>e",
      function()
        require("oil").open_float(nil, {
          preview = { vertical = true },
        })
      end,
      mode = { "n" },
    },
  },
}
