---@type LazyPluginSpec
return {
  "WilliamHsieh/overlook.nvim",
  opts = {
    ui = {
      border = "single",
      size_ratio = 0.9,
    },
  },
  keys = {
    {
      "gd",
      function()
        require("overlook.api").peek_definition()
      end,
      desc = "Overlook: Peek definition",
    },
    {
      "grw",
      function()
        require("overlook.api").open_in_original_window()
      end,
      desc = "Overlook: Open in original window",
    },
    {
      "grs",
      function()
        require("overlook.api").open_in_vsplit()
      end,
      desc = "Overlook: Open in vertical split window",
    },
  },
}
