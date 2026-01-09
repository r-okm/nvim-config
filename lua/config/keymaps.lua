local util = require("r-okm.util")

-- Disable keymap
util.keymap({ "n" }, "gh", "")

-- Add newline with Enter in Normal Mode
util.keymap({ "n" }, "<CR>", "o<ESC>")
util.keymap({ "n" }, "<S-CR>", "O<ESC>")
-- Remember cursor position when yanking in Visual Mode
util.keymap({ "x" }, "y", "mzy`z")
-- Maintain Visual Mode after adjusting indentation
util.keymap({ "x" }, "<", "<gv")
util.keymap({ "x" }, ">", ">gv")
-- Black hole register
util.keymap({ "n", "x" }, "<leader>q", '"_')
-- Don't yank to register when using 'c'
util.keymap({ "n", "x" }, "c", '"_c')
util.keymap({ "n", "x" }, "C", '"_C')

-- yank to clipboard
util.keymap(
  { "n", "x" },
  "gy",
  require("general_converter").operator_convert(function(text)
    local current_reg = vim.fn.getreg("+")
    vim.fn.setreg("+", text)
    vim.fn.setreg("", current_reg)
    return text
  end),
  { expr = true }
)

-- paste from clipboard
util.keymap({ "n" }, "gp", '"+p')
util.keymap({ "x" }, "gp", '"+P')

-- Map `a"` to `2i"`
-- Ref: https://zenn.dev/vim_jp/articles/2024-06-05-vim-middle-class-features#%E5%BC%95%E7%94%A8%E7%AC%A6%E3%81%A7%E5%9B%B2%E3%81%BE%E3%82%8C%E3%81%9F%E7%AE%87%E6%89%80%E5%85%A8%E4%BD%93%E3%82%92%E9%81%B8%E6%8A%9E%E3%81%99%E3%82%8B
for _, quote in ipairs({ '"', "'", "`" }) do
  local lhs = "a" .. quote
  local rhs = "2i" .. quote
  util.keymap({ "x", "o" }, lhs, rhs)
end

util.keymap({ "n" }, "<leader>s", ":<C-u>write<CR>")
util.keymap({ "n" }, "<leader>S", ":<C-u>noa write<CR>")

-- Buffer Manager
local buffer_manager = require("r-okm.buffer_manager")
util.keymap({ "n" }, "<leader>b", function()
  buffer_manager.toggle_ui()
end, { desc = "Toggle buffer manager" })
util.keymap({ "n" }, "[b", function()
  buffer_manager.cycle(-1)
end, { desc = "Previous buffer" })
util.keymap({ "n" }, "]b", function()
  buffer_manager.cycle(1)
end, { desc = "Next buffer" })
util.keymap({ "n" }, "[B", function()
  buffer_manager.move(-1)
end, { desc = "Move buffer left" })
util.keymap({ "n" }, "]B", function()
  buffer_manager.move(1)
end, { desc = "Move buffer right" })
