---@type LazyPluginSpec
return {
  "lukas-reineke/indent-blankline.nvim",
  dependencies = {
    "TheGLander/indent-rainbowline.nvim",
  },
  main = "ibl",
  event = { "BufReadPost" },
  config = function()
    local opts = require("indent-rainbowline").make_opts({
      scope = { enabled = false },
    })
    require("ibl").setup(opts)
  end,
}
