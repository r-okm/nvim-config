return {
  "nvimdev/lspsaga.nvim",
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
}
