---@type LazyPluginSpec
return {
  "https://github.com/WilliamHsieh/overlook.nvim",
  opts = {
    ui = {
      border = "single",
      size_ratio = 0.9,
    },
  },
  keys = {
    {
      "goo",
      function()
        require("overlook.api").peek_definition()
      end,
      desc = "Overlook: Peek definition",
    },
    {
      "gow",
      function()
        require("overlook.api").open_in_original_window()
      end,
      desc = "Overlook: Open in original window",
    },
    {
      "gos",
      function()
        require("overlook.api").open_in_vsplit()
      end,
      desc = "Overlook: Open in vertical split window",
    },
  },
}
