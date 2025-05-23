---@type LazyPluginSpec
return {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "bundled_build.lua",
  cmd = "MCPHub",
  ---@module 'MCPHub'
  ---@type MCPHub.Config
  opts = {
    use_bundled_binary = true,
  },
}
