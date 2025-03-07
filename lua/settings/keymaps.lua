-- キーマップの無効
vim.keymap.set({ "" }, "<Space>", "")
vim.keymap.set({ "n" }, "gh", "")

-- Normal Mode の Enter で改行
vim.keymap.set({ "n" }, "<CR>", "o<ESC>")
vim.keymap.set({ "n" }, "<S-CR>", "O<ESC>")
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

vim.keymap.set({ "n" }, "gh", "<C-w>h")
vim.keymap.set({ "n" }, "gl", "<C-w>l")
vim.keymap.set({ "n" }, "<Space>s", ":<C-u>write<CR>", { silent = true })
vim.keymap.set({ "n" }, "<Space>S", ":<C-u>noa write<CR>", { silent = true })
