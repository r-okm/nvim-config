-- stale エントリの自己修復 (headless 直接検証。子 nvim を使わない):
-- noautocmd bwipeout で BufWipeout ハンドラが抑止されても save_order が
-- エラーにならず、stale エントリが prune で除去されること
local H = dofile(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/harness.lua")

H.fixture("a.txt")
H.fixture("b.txt")
H.fixture("c.txt")

vim.cmd("edit " .. H.dir .. "/a.txt")
vim.cmd("edit " .. H.dir .. "/b.txt")
vim.wait(500)

local b_buf = vim.fn.bufnr(H.dir .. "/b.txt")
vim.cmd("noautocmd bwipeout! " .. b_buf)

-- stale エントリが残った状態で新規バッファ追加 (add_buffer -> save_order)
local ok = pcall(vim.cmd, "edit " .. H.dir .. "/c.txt")
vim.wait(600) -- scheduled add_buffer を実行させる
H.ok("edit succeeds with stale entry", ok)

local saved = vim.g.BufMenuOrder
H.ok("order global saved", type(saved) == "string")
H.ok("stale b not in saved order", saved ~= nil and not saved:find("b%.txt"))
H.ok("c tracked in saved order", saved ~= nil and saved:find("c%.txt") ~= nil)

H.finish()
