---@type LazyPluginSpec
return {
  "serhez/bento.nvim",
  event = { "BufReadPre" },
  opts = {
    ui = {
      floating = {
        position = "top-right",
        minimal_menu = "full",
      },
    },
    actions = {
      delete = {
        key = "<C-d>",
      },
    },
  },
}
