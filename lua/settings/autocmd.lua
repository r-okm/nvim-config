-- terminal モードで nonumber
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function(_)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "yes"
  end,
})

-- neovim 起動時にセッションファイルを読み込む
vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  callback = function()
    local session_file = os.getenv("NEOVIM_SESSION_FILE_NAME") or ".session.vim"
    if vim.fn.filereadable(session_file) == 1 then
      vim.cmd("source " .. session_file)
    end
    return true
  end,
})
