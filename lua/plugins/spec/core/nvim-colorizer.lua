---@type LazyPluginSpec
return {
  "https://github.com/catgoose/nvim-colorizer.lua",
  event = { "BufReadPost" },
  config = function()
    require("colorizer").setup({
      filetypes = {
        "*",
        css = { parsers = { names = { enable = true } } },
      },
      options = {
        parsers = {
          names = { enable = false },
          rgb = { enable = true },
        },
      },
    })
  end,
}
