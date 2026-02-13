---@type LazyPluginSpec
return {
  "https://github.com/nvimdev/lspsaga.nvim",
  cmd = { "Lspsaga" },
  opts = {
    breadcrumbs = { enable = false },
    code_action = {
      show_server_name = true,
      extend_gitsings = true,
    },
    lightbulb = { enable = false },
    rename = {
      in_select = false,
    },
    symbol_in_winbar = { enable = false },
    ui = {
      border = "rounded",
    },
  },
  keys = {
    {
      "g.",
      "<cmd>Lspsaga diagnostic_jump_next<CR>",
      desc = "Lspsaga: Jump to next diagnostic",
    },
    {
      "g,",
      "<cmd>Lspsaga diagnostic_jump_prev<CR>",
      desc = "Lspsaga: Jump to previous diagnostic",
    },
    {
      "gW",
      "<cmd>Lspsaga show_workspace_diagnostics<CR>",
      desc = "Lspsaga: Show workspace diagnostics",
      mode = { "n", "v" },
    },
    {
      "grn",
      "<cmd>Lspsaga rename<CR>",
      desc = "Lspsaga: Rename symbol",
    },
  },
}
