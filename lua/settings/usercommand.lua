-- ヘルプコマンドを垂直分割で表示する
local function openHelpVertically(opts)
  local command = string.format("vertical help %s", opts.args)
  vim.cmd(command)
end
vim.api.nvim_create_user_command("HelpVertical", openHelpVertically, { nargs = 1, complete = "help" })
vim.keymap.set("ca", "H", "HelpVertical")

-- プラグインを表示する
local function printPlugins()
  vim.print(vim.tbl_keys(require("lazy.core.config").plugins))
end
vim.api.nvim_create_user_command("PrintPlugins", printPlugins, {})
vim.keymap.set("ca", "PP", "PrintPlugins")

-- セッションを保存する
local function makeSession()
  local session_file_name = os.getenv("NEOVIM_SESSION_FILE_NAME") or ".session.vim"
  vim.cmd("mksession! " .. session_file_name)
  vim.schedule(function()
    vim.print("session file saved: " .. session_file_name)
  end)
end
vim.api.nvim_create_user_command("MakeSession", makeSession, {})
vim.keymap.set("ca", "ms", "MakeSession")

-- セッションを保存して終了する
local function makeSessionQuit()
  makeSession()
  vim.cmd("quitall")
end
vim.api.nvim_create_user_command("MakeSessionQuit", makeSessionQuit, {})
vim.keymap.set("ca", "qq", "MakeSessionQuit")
