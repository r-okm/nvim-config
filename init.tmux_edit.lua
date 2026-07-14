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
-- Flush the buffer to disk on every change so a cancelled (:cq) or crashed
-- edit keeps its content
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
  command = "silent! write",
})
-- Set filetype to markdown
vim.bo.filetype = "markdown"
-- Start in insert mode
vim.cmd("startinsert")
