require("config.options")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  spec = {
    { import = "plugins.spec.edit_command_line" },
    { import = "plugins.spec.theme" },
  },
})

require("config.keymaps")
require("config.usercommand")
require("config.autocmd")

-- Set autowriteall option locally
vim.opt_local.autowriteall = true
-- Set filetype to zsh
vim.bo.filetype = "zsh"
