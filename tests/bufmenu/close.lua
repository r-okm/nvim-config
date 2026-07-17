-- close コマンド: 表示順基準の CloseRight / CloseLeft / CloseOthers
local H = dofile(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/harness.lua")

local args = {}
for _, f in ipairs({ "a.txt", "b.txt", "c.txt", "d.txt" }) do
  table.insert(args, H.fixture(f))
end

-- CloseRight: b で実行 → c,d が閉じる
local t = H.start(args)
H.inject(t)
H.send(t, ":buffer " .. H.dir .. "/b.txt\r", 400)
H.send(t, ":BufMenuCloseRight\r", 800)
local d = H.dump(t)
H.eq("CloseRight", H.menu_rows(d), { "a.txt  a", "b.txt  b" })
H.eq("CloseRight keeps current", H.get(d, "cur"), "b.txt")
H.stop(t)

-- CloseLeft: c で実行 → a,b が閉じる
local t2 = H.start(args)
H.inject(t2)
H.send(t2, ":buffer " .. H.dir .. "/c.txt\r", 400)
H.send(t2, ":BufMenuCloseLeft\r", 800)
local d2 = H.dump(t2)
H.eq("CloseLeft", H.menu_rows(d2), { "c.txt  c", "d.txt  d" })
H.eq("CloseLeft keeps current", H.get(d2, "cur"), "c.txt")
H.stop(t2)

-- CloseOthers: 並べ替え後の表示順にも追従することを確認
local t3 = H.start(args)
H.inject(t3)
H.send(t3, ":buffer " .. H.dir .. "/b.txt\r", 400)
H.send(t3, "HL", 500) -- 一度動かして順序を崩す
H.send(t3, ":BufMenuCloseOthers\r", 800)
local d3 = H.dump(t3)
H.eq("CloseOthers leaves only current", H.menu_rows(d3), { "b.txt  b" })
H.eq("CloseOthers keeps current", H.get(d3, "cur"), "b.txt")
H.stop(t3)

H.finish()
