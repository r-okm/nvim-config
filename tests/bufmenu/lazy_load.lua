-- 遅延ロード: ファイルを開くまでロードされず、開いたら読み込まれてメニューが出る
local H = dofile(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/harness.lua")

H.fixture("a.txt")

local t = H.start({})
H.inject(t)
local d = H.dump(t)
H.eq("not loaded before BufReadPre", H.get(d, "loaded"), "false")

H.send(t, ":edit " .. H.dir .. "/a.txt\r", 800)
d = H.dump(t)
H.eq("loaded after opening a file", H.get(d, "loaded"), "true")
H.eq("menu visible", H.menu_rows(d), { "a.txt  a" })

H.stop(t)
H.finish()
