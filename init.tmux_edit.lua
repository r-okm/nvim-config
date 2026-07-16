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
-- Flush the buffer to disk so a cancelled (:cq) or crashed edit keeps its
-- content. Writes are debounced to avoid a synchronous disk write per
-- keystroke; InsertLeave and VimLeavePre flush immediately.
local uv = vim.uv or vim.loop
local write_timer = assert(uv.new_timer())
local function write_buf()
  write_timer:stop()
  vim.cmd("silent! update")
end
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  callback = function()
    write_timer:start(500, 0, vim.schedule_wrap(write_buf))
  end,
})
vim.api.nvim_create_autocmd({ "InsertLeave", "VimLeavePre" }, {
  callback = write_buf,
})
-- Set filetype to markdown
vim.bo.filetype = "markdown"
-- Start in insert mode
vim.cmd("startinsert")
