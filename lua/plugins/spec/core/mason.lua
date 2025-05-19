---@type LazyPluginSpec
return {
  "mason-org/mason.nvim",
  version = "^1",
  lazy = false,
  opts = {
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  },
}
