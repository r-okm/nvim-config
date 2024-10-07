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

-- セッションを読み込む
local function sessionLoad()
  vim.cmd("source " .. require("r-okm.types.const").SESSION_FILE_NAME)
  SessionLoaded = true
end
vim.api.nvim_create_user_command("SessionLoad", sessionLoad, {})
vim.keymap.set("ca", "sl", "SessionLoad")

-- セッションを保存する
local function sessionSave()
  vim.cmd("mksession! " .. require("r-okm.types.const").SESSION_FILE_NAME)
end
vim.api.nvim_create_user_command("SessionSave", sessionSave, {})
vim.keymap.set("ca", "ss", "SessionSave")
