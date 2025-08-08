local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  vim.env.LAZY_PATH = lazypath
  load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins.spec.core" },
    { import = "plugins.spec.edit_command_line" },
    { import = "plugins.spec.theme" },
  },
  defaults = {
    version = "*",
  },
  install = {
    missing = false,
  },
})

local util = require("r-okm.util")
util.keymap("ca", "lz", "Lazy")
