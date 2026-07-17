-- 表示スタイル: 手動トグル、縦分割での自動切替、待機ラベル色、Modified ハイライト
local H = dofile(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/harness.lua")

H.fixture("a.txt")
H.fixture("b.txt")

local t = H.start({ H.dir .. "/a.txt", H.dir .. "/b.txt" })
H.inject(t)

local d = H.dump(t)
H.eq("startup full", H.menu_rows(d), { "a.txt  a", "b.txt  b" })
H.ok("labels use idle hl when not in jump mode", H.has_hl(d, "BufMenuLabelIdle"))
H.ok("no action hl when idle", not H.has_hl(d, "BufMenuLabel"))

-- 手動トグル
H.send(t, "+", 400)
d = H.dump(t)
H.eq("+ -> dashed", H.menu_rows(d), { "──", "─" })
H.send(t, "+", 400)
d = H.dump(t)
H.eq("+ -> full", H.menu_rows(d), { "a.txt  a", "b.txt  b" })

-- 縦分割で自動 dashed、解消で full
H.send(t, ":vsplit\r", 700)
d = H.dump(t)
H.eq("vsplit -> dashed", H.menu_rows(d), { "──", "─" })
H.send(t, ":vsplit\r", 700)
d = H.dump(t)
H.eq("2nd vsplit stays dashed", H.menu_rows(d), { "──", "─" })
H.send(t, ":close\r", 700)
d = H.dump(t)
H.eq("still 1 vsplit stays dashed", H.menu_rows(d), { "──", "─" })
H.send(t, ":close\r", 700)
d = H.dump(t)
H.eq("no split -> full", H.menu_rows(d), { "a.txt  a", "b.txt  b" })

-- 分割中の手動 + は維持される (レイアウト変化まで)
H.send(t, ":vsplit\r", 700)
H.send(t, "+", 400)
d = H.dump(t)
H.eq("manual + during split -> full", H.menu_rows(d), { "a.txt  a", "b.txt  b" })
H.send(t, ":close\r", 700)
d = H.dump(t)
H.eq("split closed -> full (no flip)", H.menu_rows(d), { "a.txt  a", "b.txt  b" })

-- modified ハイライト
H.send(t, "ix", 300)
H.send(t, "\27", 400)
d = H.dump(t)
H.ok("modified hl on", H.has_hl(d, "BufMenuModified"))
H.send(t, "u", 500)
d = H.dump(t)
H.ok("modified hl off after undo", not H.has_hl(d, "BufMenuModified"))

H.stop(t)
H.finish()
