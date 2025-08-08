local util = require("r-okm.util")

-- キーマップの無効
util.keymap({ "n" }, "gh", "")

-- Normal Mode の Enter で改行
util.keymap({ "n" }, "<CR>", "o<ESC>")
util.keymap({ "n" }, "<S-CR>", "O<ESC>")
-- Visual Mode の yank 時にカーソル位置を記憶
util.keymap({ "x" }, "y", "mzy`z")
-- Visual Mode のインデント調整後に Visual Mode を維持
util.keymap({ "x" }, "<", "<gv")
util.keymap({ "x" }, ">", ">gv")
-- 無名レジスタ
util.keymap({ "n", "x" }, "<leader>q", '"_')

-- `a"` を `2i"` にマッピング
-- https://zenn.dev/vim_jp/articles/2024-06-05-vim-middle-class-features#%E5%BC%95%E7%94%A8%E7%AC%A6%E3%81%A7%E5%9B%B2%E3%81%BE%E3%82%8C%E3%81%9F%E7%AE%87%E6%89%80%E5%85%A8%E4%BD%93%E3%82%92%E9%81%B8%E6%8A%9E%E3%81%99%E3%82%8B
for _, quote in ipairs({ '"', "'", "`" }) do
  local lhs = "a" .. quote
  local rhs = "2i" .. quote
  util.keymap({ "x", "o" }, lhs, rhs)
end

util.keymap({ "n" }, "<leader>s", ":<C-u>write<CR>")
util.keymap({ "n" }, "<leader>S", ":<C-u>noa write<CR>")
