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
    local is_session_enable = require("utils.os").is_session_enable()
    if not is_session_enable then
      return true
    end

    local session_file = require("utils.os").get_session_file_name()
    if vim.fn.filereadable(session_file) == 1 then
      vim.cmd("source " .. session_file)
    end

    return true
  end,
})

-- neovim 終了時にセッションファイルを保存
vim.api.nvim_create_autocmd("VimLeavePre", {
  nested = true,
  callback = function()
    local is_session_enable = require("utils.os").is_session_enable()
    if not is_session_enable then
      return true
    end

    local session_file = require("utils.os").get_session_file_name()
    vim.cmd("mksession! " .. session_file)

    return true
  end,
})
