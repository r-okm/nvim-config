require("config.options")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  spec = {
    { import = "plugins.spec.edit_command_line" },
    { import = "plugins.spec.theme" },
    { import = "plugins.spec.core.avante" },
    { import = "plugins.spec.core.mcphub" },
  },
})

require("config.keymaps")
require("config.usercommand")
require("config.autocmd")
