-- terminal モードで nonumber
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function(_)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "yes"
  end,
})
