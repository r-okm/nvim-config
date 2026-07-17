-- bufmenu の全テストスイートを順に実行する。
-- 使い方: nvim --headless -S tests/bufmenu/run.lua
-- (各スイートは独立した nvim プロセスとして実行される。全体で 2 分程度)
local root = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))

local suites = {
  "basic",
  "style",
  "jump",
  "robust",
  "session",
  "lazy_load",
  "close",
  "regressions",
  "stale",
}

local failed = {}
for _, suite in ipairs(suites) do
  print("=== " .. suite .. " ===")
  local result = vim
    .system({ "nvim", "--headless", "-S", root .. "/" .. suite .. ".lua" }, { text = true })
    :wait(300 * 1000)
  local output = (result.stdout or "") .. (result.stderr or "")
  for _, line in ipairs(vim.split(output, "\n", { trimempty = true })) do
    -- headless で bento 由来の UI エラー等は出ないが、素の print はそのまま流す
    print(line)
  end
  if result.code ~= 0 then
    table.insert(failed, suite)
  end
end

if #failed > 0 then
  print("FAILED suites: " .. table.concat(failed, ", "))
  vim.cmd("cquit")
else
  print("ALL SUITES PASSED")
  vim.cmd("qa!")
end
