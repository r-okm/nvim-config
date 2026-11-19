-- go-grip(r-okm/go-grip の fork)でバッファのファイルをブラウザにプレビューする。
-- サーバーはファイルを監視して保存のたびに再描画し、SIGTERM で止まるとプレビューのタブを閉じようとするので、
-- nvim 側は起動と停止だけを受け持つ。タブが閉じるのはブラウザが許す場合だけで、閉じられないタブには停止の表示が出る。
-- Windows ネイティブの nvim では jobstop が強制終了になるので、タブは閉じない。
local util = require("r-okm.util")

local M = {}

local CMD = "go-grip"

-- 異常終了時の通知に添えるログの行数
local LOG_TAIL = 5

---@type table<integer, integer> bufnr -> job id
local jobs = {}

---@param bufnr integer
local function augroup_name(bufnr)
  return "r-okm.md_preview." .. bufnr
end

---@param bufnr integer
local function stop(bufnr)
  local job = jobs[bufnr]
  if job then
    jobs[bufnr] = nil
    pcall(vim.api.nvim_del_augroup_by_name, augroup_name(bufnr))
    vim.fn.jobstop(job)
    vim.notify("Markdown プレビューを停止しました")
  end
end

---@param bufnr integer
local function start(bufnr)
  if vim.fn.executable(CMD) == 0 then
    vim.notify(CMD .. " が見つかりません", vim.log.levels.ERROR)
    return
  end
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" or vim.fn.filereadable(file) == 0 then
    vim.notify("プレビューするにはファイルを保存してください", vim.log.levels.WARN)
    return
  end

  local opened = false
  local tail = {}

  local function handle_line(line)
    if line == "" then
      return
    end
    table.insert(tail, line)
    if #tail > LOG_TAIL then
      table.remove(tail, 1)
    end
    if opened then
      return
    end
    -- URL はログ行 `🚀 Starting server: http://...` から取る(`-p 0` で空いているポートを選ばせるため)
    local url = line:match("Starting server: (%S+)")
    if url then
      opened = true
      util.open_in_browser(url)
      vim.notify("Markdown プレビューを起動しました: " .. url)
    end
  end

  ---チャンクを行に組み立てて、完全な行だけを handle_line に渡すコールバックを作る。
  ---stdout と stderr で部分行が混ざらないよう、ストリームごとに作る。
  local function line_reader()
    -- 末尾は次のチャンクに続く部分行の可能性がある
    local pending = { "" }
    local reader = {}
    function reader.on_data(_, data)
      pending[#pending] = pending[#pending] .. data[1]
      for i = 2, #data do
        pending[#pending + 1] = data[i]
      end
      while #pending > 1 do
        handle_line(table.remove(pending, 1))
      end
    end
    function reader.flush()
      handle_line(pending[1])
      pending = { "" }
    end
    return reader
  end
  local stdout = line_reader()
  local stderr = line_reader()

  -- -b=false: ブラウザは URL を取ってから nvim 側で開く
  -- -p 6419 --find-port: 6419 から順に空いているポートを使う。ポートを固定すると origin が変わらず、
  --   ブラウザに保存したテーマや表示幅が残る。-p 0 だと WSL2 で Windows の予約ポートに当たることもある
  -- --replace-history: プレビュー内でリンクをたどっても、停止時にタブを閉じられるようにする
  local job = vim.fn.jobstart({ CMD, "-b=false", "-p", "6419", "--find-port", "--replace-history", file }, {
    on_stdout = stdout.on_data,
    on_stderr = stderr.on_data,
    on_exit = function(id, code)
      stdout.flush()
      stderr.flush()
      if jobs[bufnr] == id then
        jobs[bufnr] = nil
        pcall(vim.api.nvim_del_augroup_by_name, augroup_name(bufnr))
        if code ~= 0 then
          -- 本家の go-grip には fork で足したフラグがない
          local unknown_flag = vim.iter(tail):any(function(l)
            return l:find("unknown flag", 1, true) ~= nil
          end)
          if unknown_flag then
            vim.notify(
              CMD .. " が fork 版ではありません。go install github.com/r-okm/go-grip@main で入れ直してください",
              vim.log.levels.ERROR
            )
            return
          end
          vim.notify(
            ("%s が終了しました (code %d)\n%s"):format(CMD, code, table.concat(tail, "\n")),
            vim.log.levels.WARN
          )
        end
      end
    end,
  })
  if job <= 0 then
    vim.notify(CMD .. " を起動できませんでした", vim.log.levels.ERROR)
    return
  end
  jobs[bufnr] = job

  vim.api.nvim_create_autocmd("BufDelete", {
    group = vim.api.nvim_create_augroup(augroup_name(bufnr), { clear = true }),
    buffer = bufnr,
    callback = function()
      stop(bufnr)
    end,
  })
end

function M.toggle()
  local bufnr = vim.api.nvim_get_current_buf()
  if jobs[bufnr] then
    stop(bufnr)
  else
    start(bufnr)
  end
end

return M
