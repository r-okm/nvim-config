-- 過去に踏んだバグの回帰テスト:
-- タブローカルフロート / qf ウィンドウ保護 / 無名バッファからの cycle /
-- 新規ファイルでの遅延ロード / 実行中インスタンスでのセッション順序復元 /
-- :colorscheme 切替後のハイライト再定義
local H = dofile(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/harness.lua")

for _, f in ipairs({ "a.txt", "b.txt", "c.txt", "d.txt" }) do
  H.fixture(f)
end

-- タブページを跨いでもメニューが表示される
local t = H.start({ H.dir .. "/a.txt", H.dir .. "/b.txt" })
H.inject(t)
H.send(t, ":tabnew " .. H.dir .. "/c.txt\r", 900)
local d = H.dump(t)
H.eq("menu visible in new tab", H.menu_rows(d), { "a.txt  a", "b.txt  b", "c.txt  c" })
H.send(t, ":tabclose\r", 900)
d = H.dump(t)
H.eq("menu back in tab 1", H.menu_rows(d), { "a.txt  a", "b.txt  b", "c.txt  c" })

-- quickfix ウィンドウから jump しても qf が壊れない
H.send(t, ":cexpr ['" .. H.dir .. "/a.txt:1:1:hit']\r", 500)
H.send(t, ":copen\r", 700)
H.send(t, ";", 400)
H.send(t, "b", 700)
vim.fn.delete(H.dir .. "/dbg.txt")
H.send(
  t,
  ':lua vim.fn.writefile({ vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t"), tostring(#vim.fn.filter(vim.api.nvim_tabpage_list_wins(0), function(_, w) return vim.bo[vim.api.nvim_win_get_buf(w)].buftype == "quickfix" end)) }, "'
    .. H.dir
    .. '/dbg.txt")\r',
  600
)
local ok, dbg = pcall(vim.fn.readfile, H.dir .. "/dbg.txt")
H.eq("jump from qf opens in normal window", ok and dbg[1] or "?", "b.txt")
H.eq("qf window survives", ok and dbg[2] or "?", "1")
H.send(t, ":cclose\r", 500)

-- :enew の無名バッファから cycle で一覧へ戻れる
H.send(t, ":enew\r", 500)
H.send(t, "\12", 600) -- <C-l>
d = H.dump(t)
H.eq("cycle from unnamed buffer -> first item", H.get(d, "cur"), "a.txt")

-- :colorscheme 切替後もハイライト定義が生きている
H.send(t, ":colorscheme habamax\r", 700)
vim.fn.delete(H.dir .. "/dbg.txt")
H.send(
  t,
  ':lua vim.fn.writefile({ tostring(vim.api.nvim_get_hl(0, { name = "BufMenuCurrent", link = false }).bold) }, "'
    .. H.dir
    .. '/dbg.txt")\r',
  600
)
local ok2, dbg2 = pcall(vim.fn.readfile, H.dir .. "/dbg.txt")
H.eq("highlights redefined after colorscheme", ok2 and dbg2[1] or "?", "true")
H.stop(t)

-- 新規 (未作成) ファイルでもプラグインが読み込まれメニューが出る
local t2 = H.start({ H.dir .. "/newfile.txt" })
H.inject(t2)
local d2 = H.dump(t2)
H.eq("loaded for brand-new file", H.get(d2, "loaded"), "true")
H.eq("menu shows new file", H.menu_rows(d2), { "newfile.txt  n" })
H.stop(t2)

-- 実行中インスタンスでの :LoadSession でも並び順が復元される
local t3 = H.start({}, { cwd = H.dir })
H.inject(t3)
for _, f in ipairs({ "a.txt", "b.txt", "c.txt" }) do
  H.send(t3, ":edit " .. H.dir .. "/" .. f .. "\r", 400)
end
H.send(t3, ":bfirst\r", 400)
H.send(t3, "L", 500) -- a を右へ: b,a,c
local d3 = H.dump(t3)
H.eq("order before quit", H.menu_rows(d3), { "b.txt  b", "a.txt  a", "c.txt  c" })
H.send(t3, ":qa!\r", 800)
pcall(vim.fn.jobstop, t3.chan)
vim.wait(500)

local t4 = H.start({}, { cwd = H.dir })
H.inject(t4)
H.send(t4, ":edit " .. H.dir .. "/d.txt\r", 700) -- 先にプラグインをロードさせる
H.send(t4, ":LoadSession\r", 2500)
vim.wait(1000)
local d4 = H.dump(t4)
-- 事前に開いていた d.txt は保存順に無いため末尾に付く
H.eq("order restored in running instance", H.menu_rows(d4), { "b.txt  b", "a.txt  a", "c.txt  c", "d.txt  d" })
H.stop(t4)

H.finish()
