local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  vim.env.LAZY_PATH = lazypath
  load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
end
vim.opt.rtp:prepend(lazypath)

local spec = {
  { import = "plugins.spec.edit_command_line" },
  { import = "plugins.spec.theme" },
}
if vim.env.EDITPROMPT ~= "1" then
  table.insert(spec, 1, { import = "plugins.spec.core" })
end

require("lazy").setup({
  spec = spec,
  defaults = {
    version = "*",
  },
  install = {
    missing = false,
  },
})

local util = require("r-okm.util")
util.keymap("ca", "lz", "Lazy")

-- When started via editprompt
if vim.env.EDITPROMPT == "1" then
  vim.opt_local.autowriteall = true
  vim.cmd("startinsert")
end
