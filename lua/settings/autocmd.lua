-- LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("r-okm.LspAttach", {}),
  callback = require("r-okm.lsp.handler").on_lsp_attach,
})

-- terminal mode hook
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function(_)
    -- set nonumber
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "yes"
    -- start insert mode
    vim.cmd("startinsert")
  end,
})

local session_file_name = require("r-okm.types.const").SESSION_FILE_NAME

-- セッションファイルを指定して neovim 起動時にセッションファイルを読み込む
vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  pattern = session_file_name,
  callback = function()
    if vim.fn.filereadable(session_file_name) == 1 then
      vim.cmd("SessionLoad")

      -- バッファの .session.vim を閉じる
      local buffers = vim.api.nvim_list_bufs()
      for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(buf) then
          local buf_name = vim.api.nvim_buf_get_name(buf)
          if buf_name:match(session_file_name) then
            vim.api.nvim_buf_delete(buf, { force = true })
            break
          end
        end
      end
    end

    return true
  end,
})

-- neovim 終了時にセッションファイルを保存
vim.api.nvim_create_autocmd("VimLeavePre", {
  nested = true,
  callback = function()
    if SessionLoaded then
      vim.cmd("SessionSave")
    end

    return true
  end,
})

-- yaml.docker-compose filetype を設定する
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "docker-compose.yaml", "docker-compose.yml", "compose.yaml", "compose.yml" },
  callback = function()
    vim.bo.filetype = "yaml.docker-compose"
  end,
})
