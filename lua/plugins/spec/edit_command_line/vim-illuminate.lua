local const = require("r-okm.types.const")

---@type LazyPluginSpec
return {
  "RRethy/vim-illuminate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  event = { "BufReadPre" },
  config = function()
    require("illuminate").configure({
      filetypes_denylist = const.HIGHLIGHT_DISABLED_FILETYPES,
      large_file_cutoff = 1000,
    })
  end,
}
