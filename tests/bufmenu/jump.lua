-- ラベルジャンプ: open / delete (confirm 含む) / vsplit / 解除 / 未知キー再送 / 0 件ガード
local H = dofile(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/harness.lua")

-- 未知キー再送テスト (j でカーソル移動) 用に複数行にしておく
H.fixture("a.txt", { "line1", "line2", "line3" })
H.fixture("b.txt")
H.fixture("c.txt")

local t = H.start({ H.dir .. "/a.txt", H.dir .. "/b.txt", H.dir .. "/c.txt" })
H.inject(t)

-- ラベルジャンプ (open)
local d = H.dump(t)
H.eq("current before jump", H.get(d, "cur"), "a.txt")
H.send(t, ";", 400)
H.send(t, "b", 500)
d = H.dump(t)
H.eq("label jump opens b", H.get(d, "cur"), "b.txt")

-- delete モード: c を削除 → 継続 → Esc で抜ける
H.send(t, ";", 400)
H.send(t, "\127", 400) -- <BS>
H.send(t, "c", 600)
H.send(t, "\27", 400) -- <Esc>
d = H.dump(t)
H.eq("delete removes c", H.menu_rows(d), { "a.txt  a", "b.txt  b" })
H.eq("layout preserved", H.get(d, "wins"), "1")
H.eq("current unchanged", H.get(d, "cur"), "b.txt")

-- modified バッファの delete → confirm プロンプト → キャンセル → ループ継続
H.send(t, ":buffer " .. H.dir .. "/a.txt\r", 400)
H.send(t, "ix", 300)
H.send(t, "\27", 400)
H.send(t, ";", 400)
H.send(t, "\127", 400)
H.send(t, "a", 800) -- 未保存の a を削除しようとする → confirm
local screen = table.concat(H.screen(t), "\n")
H.ok("confirm prompt shown", screen:match("No write since") ~= nil)
H.send(t, "c", 600) -- キャンセル (delete しない)
H.send(t, "\27", 400) -- ジャンプモードを抜ける
d = H.dump(t)
H.ok("a still listed after cancel", H.menu_rows(d)[1]:match("a%.txt") ~= nil)
H.send(t, "u", 400) -- 変更を戻す

-- vsplit モード
H.send(t, ";", 400)
H.send(t, "|", 400)
H.send(t, "b", 600)
d = H.dump(t)
H.eq("vsplit opens b", H.get(d, "cur"), "b.txt")
H.eq("two windows", H.get(d, "wins"), "2")
H.send(t, ":close\r", 600)

-- Esc 解除
H.send(t, ";", 400)
H.send(t, "\27", 400)
d = H.dump(t)
H.eq("esc cancels (no move)", H.get(d, "cur"), "a.txt")

-- 未知キー再送: ; の後に j → モード解除してカーソルが 1 行下がる
H.send(t, "gg", 300)
d = H.dump(t)
H.eq("cursor at line 1", H.get(d, "line"), "1")
H.send(t, ";", 400)
H.send(t, "j", 400)
d = H.dump(t)
H.eq("unknown key replayed (cursor moved)", H.get(d, "line"), "2")

H.stop(t)

-- バッファ 0 件で ; が即 return (ハングしない)
local t2 = H.start({})
H.inject(t2)
H.send(t2, ";", 500)
local d2 = H.dump(t2)
H.eq("plugin loaded by ; trigger", H.get(d2, "loaded"), "true")
H.eq("no menu with zero buffers", H.menu_rows(d2)[1] or "(none)", "(none)")
H.stop(t2)

H.finish()
