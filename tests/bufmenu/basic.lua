-- 基本操作: 起動引数/BufAdd 両経路の追跡、cycle/move の折り返し
local H = dofile(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/harness.lua")

for _, f in ipairs({ "a.txt", "b.txt", "c.txt", "d.txt" }) do
  H.fixture(f)
end

-- 起動引数経由 (initial_scan の経路)
local t = H.start({ H.dir .. "/a.txt", H.dir .. "/b.txt", H.dir .. "/c.txt" })
H.inject(t)

local d = H.dump(t)
H.eq("initial rows", H.menu_rows(d), { "a.txt  a", "b.txt  b", "c.txt  c" })
H.eq("current is first arg", H.get(d, "cur"), "a.txt")

-- :e で開く経路 (BufAdd)
H.send(t, ":edit " .. H.dir .. "/d.txt\r", 600)
d = H.dump(t)
H.eq("BufAdd appends", H.menu_rows(d), { "a.txt  a", "b.txt  b", "c.txt  c", "d.txt  d" })
H.eq("current is d", H.get(d, "cur"), "d.txt")

-- cycle: d (末尾) から <C-l> で先頭 a へ折り返し
H.send(t, "\12", 400)
d = H.dump(t)
H.eq("cycle wraps to head", H.get(d, "cur"), "a.txt")

-- <C-h> で d へ戻る折り返し
H.send(t, "\8", 400)
d = H.dump(t)
H.eq("cycle wraps to tail", H.get(d, "cur"), "d.txt")

-- move: d を L で先頭へ折り返し
H.send(t, "L", 400)
d = H.dump(t)
H.eq("move wraps to head", H.menu_rows(d), { "d.txt  d", "a.txt  a", "b.txt  b", "c.txt  c" })

-- d を H で末尾へ折り返し
H.send(t, "H", 400)
d = H.dump(t)
H.eq("move wraps to tail", H.menu_rows(d), { "a.txt  a", "b.txt  b", "c.txt  c", "d.txt  d" })

-- 中間の移動
H.send(t, ":buffer " .. H.dir .. "/b.txt\r", 400)
H.send(t, "L", 400)
d = H.dump(t)
H.eq("move right", H.menu_rows(d), { "a.txt  a", "c.txt  c", "b.txt  b", "d.txt  d" })

H.stop(t)
H.finish()
