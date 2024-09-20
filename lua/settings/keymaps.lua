-- キーマップの無効
vim.keymap.set({ "" }, "<Space>", "")
vim.keymap.set({ "n" }, "gh", "")

-- Normal Mode の Enter で改行
vim.keymap.set({ "n" }, "<CR>", "o<ESC>")
-- Visual Mode の yank 時にカーソル位置を記憶
vim.keymap.set({ "x" }, "y", "mzy`z")
-- Visual Mode のインデント調整後に Visual Mode を維持
vim.keymap.set({ "x" }, "<", "<gv")
vim.keymap.set({ "x" }, ">", ">gv")
-- 無名レジスタ
vim.keymap.set({ "n", "x" }, "<Space>q", '"_')

-- `a"` を `2i"` にマッピング
-- https://zenn.dev/vim_jp/articles/2024-06-05-vim-middle-class-features#%E5%BC%95%E7%94%A8%E7%AC%A6%E3%81%A7%E5%9B%B2%E3%81%BE%E3%82%8C%E3%81%9F%E7%AE%87%E6%89%80%E5%85%A8%E4%BD%93%E3%82%92%E9%81%B8%E6%8A%9E%E3%81%99%E3%82%8B
for _, quote in ipairs({ '"', "'", "`" }) do
  local lhs = "a" .. quote
  local rhs = "2i" .. quote
  vim.keymap.set({ "x", "o" }, lhs, rhs, { noremap = true, silent = true })
end

-- vscode
if vim.g.vscode then
  local keymapVsc = require("utils.setKeymap").keymapVsc
  local keymapVscVisual = require("utils.setKeymap").keymapVscVisual

  -- save
  keymapVsc("n", "<Space>s", "workbench.action.files.save")
  keymapVsc("n", "<Space>S", "workbench.action.files.saveWithoutFormatting")
  -- close
  keymapVsc("n", "<Space>w", "workbench.action.closeActiveEditor")
  -- tab
  keymapVsc("n", "L", "workbench.action.moveEditorRightInGroup")
  keymapVsc("n", "H", "workbench.action.moveEditorLeftInGroup")
  -- filer
  keymapVsc("n", "<Space>c", "workbench.action.closeSidebar")
  keymapVsc("n", "<Space>e", "workbench.view.explorer")
  -- global search
  keymapVsc("n", "#", "workbench.action.findInFiles", "{ 'query': expand('<cword>')}")
  -- comment
  keymapVsc("n", "gcc", "editor.action.commentLine")
  keymapVscVisual("x", "gc", "editor.action.commentLine")
  keymapVsc("n", "gbc", "editor.action.blockComment")
  keymapVscVisual("x", "gb", "editor.action.blockComment")
  -- エラージャンプ
  keymapVsc("n", "g.", "editor.action.marker.nextInFiles")
  keymapVsc("n", "g,", "editor.action.marker.prevInFiles")
  -- 定義ジャンプ
  keymapVsc("n", "gD", "editor.action.goToImplementation")
  -- フォーマット
  keymapVsc("n", "gf", "editor.action.formatDocument")
  keymapVscVisual("x", "gf", "editor.action.formatSelection")
  -- インポート整理
  keymapVsc("n", "go", "editor.action.organizeImports")
  -- notification
  keymapVsc("n", "zn", "notifications.showList")
  keymapVsc("n", "zc", "notifications.clearAll")
  -- project_files
  keymapVsc("n", "zp", "workbench.action.quickOpen")
  -- find_files
  keymapVsc("n", "zf", "workbench.action.findInFiles")
else
  vim.keymap.set({ "n" }, "<C-q>", "<C-w>w")

  vim.keymap.set({ "n" }, "<Space>s", ":<C-u>write<CR>", { silent = true })
  vim.keymap.set({ "n" }, "<Space>S", ":<C-u>noa write<CR>", { silent = true })
  -- terminal-job モードへ切り替える
  vim.keymap.set({ "t" }, "<C-k><C-n>", "<C-\\><C-n>", { silent = true })
  vim.keymap.set({ "n" }, "<C-k><C-n>", ":<C-u>terminal<CR>", { silent = true })
end
