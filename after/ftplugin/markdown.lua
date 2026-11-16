local util = require("r-okm.util")

util.keymap({ "n", "x" }, "<C-k><C-v>", function()
  require("r-okm.md_preview").toggle()
end, { buffer = 0, desc = "Markdown Preview Toggle" })

-- :unmap は "|" を引数の一部として読むので、exe で包んでから連結する
local undo = [[sil! exe "nunmap <buffer> <C-k><C-v>" | sil! exe "xunmap <buffer> <C-k><C-v>"]]
-- 先頭の "|" は :print として実行されるので、既存の値があるときだけ連結する
vim.b.undo_ftplugin = vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | " .. undo) or undo
