-- 堅牢性: :only 復活、バックグラウンド削除、0 件で消滅、閉状態からの復活、同名識別
local H = dofile(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/harness.lua")

H.fixture("a.txt")
H.fixture("b.txt")
H.fixture("c.txt")
H.fixture("sub1/x.txt", { "x1" })
H.fixture("sub2/x.txt", { "x2" })

local t = H.start({ H.dir .. "/a.txt", H.dir .. "/b.txt" })
H.inject(t)

-- :only はフロートも閉じる → 開き直し
H.send(t, ":vsplit\r", 700)
H.send(t, ":only\r", 800)
local d = H.dump(t)
H.eq(":only reopens menu (full, no vsplit)", H.menu_rows(d), { "a.txt  a", "b.txt  b" })

-- バックグラウンドバッファの削除で即座に行が消える (BufEnter なし)
H.send(t, ":bdelete " .. H.dir .. "/b.txt\r", 700)
d = H.dump(t)
H.eq("background delete removes row", H.menu_rows(d), { "a.txt  a" })

-- 全バッファ削除でメニュー消滅
H.send(t, ":bdelete " .. H.dir .. "/a.txt\r", 700)
d = H.dump(t)
H.eq("menu gone with zero buffers", H.menu_rows(d)[1] or "(none)", "(none)")

-- 閉状態でバッファ追加 → 復活
H.send(t, ":edit " .. H.dir .. "/c.txt\r", 700)
d = H.dump(t)
H.eq("menu reappears on new buffer", H.menu_rows(d), { "c.txt  c" })

-- 同名ファイルはサフィックスで区別
H.send(t, ":edit " .. H.dir .. "/sub1/x.txt\r", 500)
H.send(t, ":edit " .. H.dir .. "/sub2/x.txt\r", 500)
d = H.dump(t)
H.eq("same basename disambiguated", H.menu_rows(d), { "c.txt       c", "sub1/x.txt  x", "sub2/x.txt  a" })

H.stop(t)
H.finish()
