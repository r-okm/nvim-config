-- セッション永続化: persistence 自動保存 → :LoadSession での並び順復元
local H = dofile(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/harness.lua")

for _, f in ipairs({ "a.txt", "b.txt", "c.txt", "d.txt", "e.txt" }) do
  H.fixture(f)
end

-- セッション A: 開いて並べ替えて終了 (persistence が VimLeavePre で自動保存)
local t = H.start({}, { cwd = H.dir })
H.inject(t)
for _, f in ipairs({ "a.txt", "b.txt", "c.txt", "d.txt" }) do
  H.send(t, ":edit " .. H.dir .. "/" .. f .. "\r", 400)
end
H.send(t, ":bfirst\r", 400)
H.send(t, "LL", 600) -- a を 2 つ右へ: b,c,a,d
local d = H.dump(t)
H.eq("order before quit", H.menu_rows(d), { "b.txt  b", "c.txt  c", "a.txt  a", "d.txt  d" })
H.send(t, ":qa!\r", 800)
pcall(vim.fn.jobstop, t.chan)
vim.wait(500)

-- セッション B: LoadSession で復元
local t2 = H.start({}, { cwd = H.dir })
H.inject(t2)
H.send(t2, ":LoadSession\r", 2500)
local d2 = H.dump(t2)
H.eq("order restored after LoadSession", H.menu_rows(d2), { "b.txt  b", "c.txt  c", "a.txt  a", "d.txt  d" })

-- 保存順に無い新規ファイルは末尾に付く
H.send(t2, ":edit " .. H.dir .. "/e.txt\r", 600)
d2 = H.dump(t2)
H.eq("unknown file appended at tail", H.menu_rows(d2), { "b.txt  b", "c.txt  c", "a.txt  a", "d.txt  d", "e.txt  e" })

H.stop(t2)
H.finish()
