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

local util = require("r-okm.util")

-- Set abbreviation for quitting all and saving
util.keymap("ca", "qq", "execute 'wqa'")
-- Set filetype to markdown
vim.bo.filetype = "markdown"
-- Start in insert mode
vim.cmd("startinsert")
