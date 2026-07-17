-- bufmenu の E2E テストハーネス。
-- headless の driver nvim から子 nvim (実設定の TUI) を PTY 上に起動し、
-- キー送信 + 子に注入したヘルパー (MenuDump) のファイルダンプで観測する。
-- 実行方法: nvim --headless -S tests/bufmenu/run.lua (一括) または各スイートを -S で個別実行
local H = {}

-- このファイルのあるディレクトリ (child_helpers.lua の解決に使う)
H.root = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))

-- テスト作業ディレクトリ (実行ごとに一意。フィクスチャとダンプの置き場)
H.dir = vim.fn.tempname()
vim.fn.mkdir(H.dir, "p")

local pass, fail = 0, 0
local dump_file = H.dir .. "/menu_dump.txt"

--- フィクスチャファイルを作る
---@param name string H.dir 相対のファイル名
---@param lines string[]|nil 省略時は 1 行
---@return string absolute path
function H.fixture(name, lines)
  local path = H.dir .. "/" .. name
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(lines or { name }, path)
  return path
end

---@param args string[] 子 nvim への引数
---@param opts { cwd?: string }|nil
function H.start(args, opts)
  vim.o.columns = 100
  vim.o.lines = 30
  vim.cmd("tabnew")
  local cmd = { "nvim" }
  vim.list_extend(cmd, args or {})
  local chan = vim.fn.jobstart(cmd, {
    term = true,
    env = { TERM = "xterm-256color" },
    cwd = (opts and opts.cwd) or nil,
  })
  local buf = vim.api.nvim_get_current_buf()
  vim.wait(3000)
  return { chan = chan, buf = buf }
end

function H.stop(t)
  vim.api.nvim_chan_send(t.chan, "\27\27:qa!\r")
  vim.wait(500)
  pcall(vim.fn.jobstop, t.chan)
end

function H.send(t, keys, wait)
  vim.api.nvim_chan_send(t.chan, keys)
  vim.wait(wait or 400)
end

--- 子の画面 (terminal バッファ) を行配列で返す
function H.screen(t)
  return vim.api.nvim_buf_get_lines(t.buf, 0, -1, false)
end

--- 子に観測ヘルパーを注入する (ダンプ先パスをテンプレート置換して配置)
function H.inject(t)
  local template = table.concat(vim.fn.readfile(H.root .. "/child_helpers.lua"), "\n")
  local injected = template:gsub("@DIR@", (H.dir:gsub("%%", "%%%%")))
  local path = H.dir .. "/child_helpers.lua"
  vim.fn.writefile(vim.split(injected, "\n"), path)
  H.send(t, ":luafile " .. path .. "\r", 300)
end

--- 子のメニュー状態をダンプして読み込む (ファイル出現をポーリング)
function H.dump(t)
  vim.fn.delete(dump_file)
  vim.api.nvim_chan_send(t.chan, ":lua MenuDump()\r")
  vim.wait(3000, function()
    return vim.fn.filereadable(dump_file) == 1
  end, 50)
  vim.wait(100) -- 書き込み完了の余裕
  local ok, lines = pcall(vim.fn.readfile, dump_file)
  return ok and lines or { "(dump failed)" }
end

--- dump からメニューの行 (前後空白をトリム) を順に取り出す
function H.menu_rows(dump)
  local rows = {}
  for _, l in ipairs(dump) do
    local row = l:match("^row:(.*)$")
    if row then
      table.insert(rows, (row:gsub("%s+$", ""):gsub("^%s+", "")))
    end
  end
  return rows
end

--- dump から "prefix:value" 形式の値を取り出す
function H.get(dump, prefix)
  for _, l in ipairs(dump) do
    local v = l:match("^" .. prefix .. ":(.*)$")
    if v then
      return v
    end
  end
  return nil
end

function H.has_hl(dump, group)
  for _, l in ipairs(dump) do
    if l:match("^hl:%d+:" .. group .. "$") then
      return true
    end
  end
  return false
end

function H.eq(label, actual, expected)
  local a = type(actual) == "table" and table.concat(actual, " / ") or tostring(actual)
  local e = type(expected) == "table" and table.concat(expected, " / ") or tostring(expected)
  if a == e then
    pass = pass + 1
    print("PASS " .. label)
  else
    fail = fail + 1
    print(string.format("FAIL %s\n  expected: %s\n  actual:   %s", label, e, a))
  end
end

function H.ok(label, cond)
  H.eq(label, cond and "true" or "false", "true")
end

--- 結果を出力して終了する (失敗があれば非ゼロ終了)
function H.finish()
  print(string.format("== %d passed, %d failed ==", pass, fail))
  vim.cmd(fail > 0 and "cquit" or "qa!")
end

return H
