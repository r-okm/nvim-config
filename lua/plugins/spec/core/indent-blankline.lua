---@type LazyPluginSpec
return {
  "https://github.com/lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile", "VeryLazy" },
  ---@module "ibl"
  ---@type ibl.config
  opts = {
    scope = { enabled = false },
  },
}
