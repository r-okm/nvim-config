---@type LazyPluginSpec
return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufReadPost" },
  config = function()
    require("colorizer").setup({ "*", css = { names = true } }, { names = false, rgb_fn = true })
  end,
}
