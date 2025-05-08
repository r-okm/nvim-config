---@type LazyPluginSpec
return {
  "mason-org/mason.nvim",
  tag = "v1.11.0",
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
