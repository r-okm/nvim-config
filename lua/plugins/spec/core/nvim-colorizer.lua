---@type LazyPluginSpec
return {
  "https://github.com/norcalli/nvim-colorizer.lua",
  event = { "BufReadPost" },
  config = function()
    local filetype_opts = { "*", "!toggleterm", css = { names = true } }
    local default_opts = {
      names = false,
      rgb_fn = true,
    }
    require("colorizer").setup(filetype_opts, default_opts)
  end,
}
