--- lazy.nvim で plugin を更新した際、更新差分(旧→新コミット)を Claude に渡して
--- サプライチェーン攻撃・悪意あるコードを検査し、専用バッファにレポートする。
---
--- `LazySync` / `LazyUpdate` の User autocmd でトリガし、`claude -p`(OAuth・追加費用なし)を
--- plugin ごとに非同期起動する。差分のみの検査なので「更新で新規に入った変更」の検出に特化する。
local M = {}

local uv = vim.uv or vim.loop

---@class LazyVulnCheckConfig
local config = {
  enabled = true, -- 機能全体の有効/無効
  auto = true, -- LazySync/LazyUpdate での自動起動
  model = "sonnet", -- claude のモデル(spec 側で opus に上書きする想定)
  max_diff_bytes = 200 * 1024, -- これを超える diff はファイル単位で切り詰める(省略内容をレポートに明記)
  concurrency = 3, -- claude の同時実行数
  timeout = 120, -- plugin ごとの claude タイムアウト(秒)
  save_to_file = false, -- true なら stdpath("state") にも Markdown 保存
}

-- claude 本体プロンプトを置換する(append だと指示文が会話応答に化けるため。ai_henkan の教訓)
local SYSTEM_PROMPT = table.concat({
  "あなたは Neovim プラグインの更新差分を監査するセキュリティ専門家です。",
  "標準入力に git diff が与えられます。これはプラグインがバージョン更新で取り込んだ変更です。",
  "サプライチェーン攻撃や悪意あるコードの兆候を検出してください。具体的には:",
  "- コードの難読化(eval、base64 等のデコード実行、エンコードされた文字列の実行)",
  "- 想定外の外部通信(不審な URL/IP への接続、データ送信)",
  "- 認証情報・トークン・環境変数・SSH 鍵などの窃取",
  "- 任意コード実行(シェル実行、ダウンロードして実行)",
  "- インストール/ビルドフックの悪用(post-install スクリプト等)",
  "- バックドア、隠しテレメトリ",
  "",
  "判定は次の JSON のみを返してください(前後に一切の文章を付けない):",
  '{"risk":"none|low|medium|high","summary":"日本語1-2文の要約",'
    .. '"findings":[{"severity":"low|medium|high","description":"説明","location":"file:line 等"}]}',
  "",
  "通常の機能追加・バグ修正・リファクタリングは risk=none とし、findings は空配列にしてください。",
}, "\n")

-- 実行中フラグ。sync 経由では LazyUpdate と LazySync が二重発火するため、2 回目をスキップする。
local running = false

local function short(sha)
  return tostring(sha or ""):sub(1, 7)
end

--- 更新された plugin を収集する。
--- `_.updated` は次の lazy 操作の M.clear で nil 化されるため、autocmd の同期部分で即座に呼ぶこと。
---@return table[]
local function collect_targets()
  local ok, lazy_config = pcall(require, "lazy.core.config")
  if not ok then
    return {}
  end
  local targets = {}
  for _, p in pairs(lazy_config.plugins) do
    local u = p._ and p._.updated
    if u and u.from and u.to and u.from ~= u.to and p.dir then
      targets[#targets + 1] = { name = p.name, dir = p.dir, from = u.from, to = u.to }
    end
  end
  return targets
end

-- `diff --git a/<path> b/<path>` 行からファイルパスを取り出す(取れなければ nil)。
local function diff_file_path(line)
  return line:match("^diff %-%-git a/(.-) b/")
end

--- diff(行配列)をバイト予算内に収める。ファイル(`diff --git`)境界で切り詰め、
--- 行は途中で割らない(マルチバイト破壊を避ける)。
---@param lines string[]
---@param max_bytes integer
---@return string diff, string|nil note  note は省略が発生した場合のみ(未検査部分の説明)
local function truncate_diff(lines, max_bytes)
  -- 行の合計バイト数(各行 + 改行1)
  local function bytes_of(from, to)
    local n = 0
    for i = from, to do
      n = n + #lines[i] + 1
    end
    return n
  end

  if #lines == 0 then
    return "", nil
  end
  if bytes_of(1, #lines) <= max_bytes then
    return table.concat(lines, "\n"), nil
  end

  -- ファイルセクションの開始行を特定。`diff --git` で始まらない形式は全体を 1 ブロック扱い。
  local starts = {}
  for i, l in ipairs(lines) do
    if l:match("^diff %-%-git ") then
      starts[#starts + 1] = i
    end
  end
  if #starts == 0 then
    starts = { 1 }
  end
  local total_files = #starts

  local kept = {}
  local kept_bytes = 0
  local kept_files = 0
  local partial_file = nil

  for s = 1, total_files do
    local from = starts[s]
    local to = (starts[s + 1] or (#lines + 1)) - 1
    local section_bytes = bytes_of(from, to)

    if kept_bytes + section_bytes <= max_bytes then
      for i = from, to do
        kept[#kept + 1] = lines[i]
      end
      kept_bytes = kept_bytes + section_bytes
      kept_files = kept_files + 1
    elseif kept_files == 0 then
      -- 先頭ファイル単体が予算超過 → 行単位(途中の行は割らない)で予算まで詰める。
      for i = from, to do
        if kept_bytes + #lines[i] + 1 > max_bytes and #kept > 0 then
          break
        end
        kept[#kept + 1] = lines[i]
        kept_bytes = kept_bytes + #lines[i] + 1
      end
      partial_file = diff_file_path(lines[from]) or "(先頭ファイル)"
      break
    else
      break
    end
  end

  local dropped = total_files - kept_files
  local note
  if partial_file then
    note = string.format(
      "`%s` がバイト上限(約%dKB)を超過、途中まで検査(残り %d ファイルは未検査)",
      partial_file,
      math.floor(max_bytes / 1024),
      dropped - 1
    )
  else
    note = string.format(
      "diff が大きいため %d/%d ファイルのみ検査(残り %d ファイルは未検査)",
      kept_files,
      total_files,
      dropped
    )
  end
  return table.concat(kept, "\n"), note
end

--- 1 plugin の git diff を非同期取得する。
---@param target table
---@param on_done fun(diff: string|nil, err: string|nil, note: string|nil)
local function get_diff(target, on_done)
  local range = target.from .. ".." .. target.to
  local out = {}
  local id = vim.fn.jobstart({ "git", "-C", target.dir, "diff", "--no-color", range }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      out = data
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        on_done(nil, "git diff 失敗 (code " .. code .. ")")
        return
      end
      -- jobstart は末尾に空文字列を 1 つ付けるので除去する
      while #out > 0 and out[#out] == "" do
        table.remove(out)
      end
      local diff, note = truncate_diff(out, config.max_diff_bytes)
      on_done(diff, nil, note)
    end,
  })
  if id <= 0 then
    on_done(nil, "git の起動に失敗")
  end
end

--- diff を claude に渡して判定 JSON を得る。
---@param diff string
---@param on_done fun(verdict: table|nil, err: string|nil)
local function run_claude(diff, on_done)
  local out, err = {}, {}
  local timer = nil
  local finished = false
  local function finish(verdict, e)
    if finished then
      return
    end
    finished = true
    if timer then
      timer:stop()
      timer:close()
      timer = nil
    end
    on_done(verdict, e)
  end

  local id = vim.fn.jobstart({
    "claude",
    "-p",
    "--model",
    config.model,
    "--system-prompt",
    SYSTEM_PROMPT,
    "--output-format",
    "json",
  }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      out = data
    end,
    on_stderr = function(_, data)
      err = data
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        local detail = table.concat(err, " "):gsub("^%s+", ""):sub(1, 200)
        finish(nil, "claude 終了コード " .. code .. (detail ~= "" and (": " .. detail) or ""))
        return
      end
      -- --output-format json は Claude Code の実行結果メタ JSON。.result に最終テキストが入る
      local ok, wrapper = pcall(vim.json.decode, table.concat(out, "\n"))
      if not ok or type(wrapper) ~= "table" then
        finish(nil, "claude 出力のパース失敗")
        return
      end
      if wrapper.is_error then
        finish(nil, "claude エラー: " .. tostring(wrapper.result or ""))
        return
      end
      -- .result はシステムプロンプトに従い我々の判定 JSON 文字列のはず
      local ok2, verdict = pcall(vim.json.decode, wrapper.result or "")
      if not ok2 or type(verdict) ~= "table" or not verdict.risk then
        finish(nil, "判定 JSON のパース失敗: " .. tostring(wrapper.result or ""):sub(1, 200))
        return
      end
      finish(verdict, nil)
    end,
  })
  if id <= 0 then
    finish(nil, "claude の起動に失敗")
    return
  end

  vim.fn.chansend(id, diff)
  vim.fn.chanclose(id, "stdin")

  timer = uv.new_timer()
  timer:start(config.timeout * 1000, 0, function()
    vim.schedule(function()
      vim.fn.jobstop(id)
    end)
    finish(nil, "claude タイムアウト (" .. config.timeout .. "s)")
  end)
end

--- 対象 plugin を concurrency 制限付きで順次処理する。
---@param targets table[]
---@param on_all_done fun(results: table[])
local function process(targets, on_all_done)
  local results = {}
  local next_idx = 1
  local active = 0
  local total = #targets
  local start_next

  local function complete(result)
    results[#results + 1] = result
    active = active - 1
    vim.notify(string.format("[VulnCheck] %d/%d 完了", #results, total), vim.log.levels.INFO)
    if #results == total then
      on_all_done(results)
    else
      start_next()
    end
  end

  start_next = function()
    while active < config.concurrency and next_idx <= total do
      local t = targets[next_idx]
      next_idx = next_idx + 1
      active = active + 1
      get_diff(t, function(diff, derr, note)
        if derr then
          complete({ name = t.name, from = t.from, to = t.to, error = derr })
          return
        end
        if diff == "" then
          complete({ name = t.name, from = t.from, to = t.to, risk = "none", summary = "差分なし", findings = {} })
          return
        end
        run_claude(diff, function(verdict, cerr)
          if cerr then
            complete({ name = t.name, from = t.from, to = t.to, error = cerr })
          else
            verdict.name = t.name
            verdict.from = t.from
            verdict.to = t.to
            verdict.truncation = note
            complete(verdict)
          end
        end)
      end)
    end
  end

  start_next()
end

local RISK_ORDER = { high = 4, medium = 3, low = 2, none = 1 }
local RISK_BADGE = { high = "🔴 HIGH", medium = "🟠 MEDIUM", low = "🟡 LOW", none = "🟢 NONE" }

---@param results table[]
---@return string[]
local function build_report(results)
  table.sort(results, function(a, b)
    local ra = a.error and 5 or (RISK_ORDER[a.risk] or 0)
    local rb = b.error and 5 or (RISK_ORDER[b.risk] or 0)
    return ra > rb
  end)

  local flagged = 0
  for _, r in ipairs(results) do
    if r.risk == "high" or r.risk == "medium" or r.risk == "low" then
      flagged = flagged + 1
    end
  end

  local lines = {}
  local function add(s)
    lines[#lines + 1] = s
  end

  add("# Lazy Plugin 脆弱性チェック結果")
  add("")
  add(string.format("- チェック対象: %d plugins", #results))
  add(string.format("- リスク検出: %d plugins", flagged))
  add("")
  add("> 差分のみの検査です。high/medium の判定は必ず手動で diff を確認してください。")
  add("")

  for _, r in ipairs(results) do
    add("---")
    add("")
    if r.error then
      add(string.format("## ⚠️ %s (検査エラー)", r.name))
      add(string.format("- `%s` → `%s`", short(r.from), short(r.to)))
      add(string.format("- エラー: %s", r.error))
    else
      add(string.format("## %s — %s", r.name, RISK_BADGE[r.risk] or r.risk))
      add(string.format("- `%s` → `%s`", short(r.from), short(r.to)))
      if r.truncation then
        add(string.format("- ⚠️ %s", r.truncation))
      end
      add(string.format("- 要約: %s", r.summary or ""))
      if r.findings and #r.findings > 0 then
        add("- 検出事項:")
        for _, f in ipairs(r.findings) do
          add(string.format("  - **[%s]** %s `(%s)`", f.severity or "?", f.description or "", f.location or ""))
        end
      end
    end
    add("")
  end

  return lines
end

---@param lines string[]
local function show_report(lines)
  vim.cmd("botright split")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  pcall(vim.api.nvim_buf_set_name, buf, "LazyVulnCheck://report")
end

---@param lines string[]
local function save_report(lines)
  local dir = vim.fn.stdpath("state") .. "/lazy_vuln_check"
  vim.fn.mkdir(dir, "p")
  local path = dir .. "/" .. vim.fn.strftime("%Y%m%d_%H%M%S") .. ".md"
  vim.fn.writefile(lines, path)
  vim.notify("[VulnCheck] レポートを保存しました: " .. path, vim.log.levels.INFO)
end

--- チェックを実行する。
---@param o? { manual?: boolean }
function M.run(o)
  o = o or {}
  if not config.enabled then
    return
  end
  if running then
    return -- 二重発火スキップ
  end

  -- _.updated が clear される前に同期で確定させる
  local targets = collect_targets()
  if #targets == 0 then
    if o.manual then
      vim.notify("[VulnCheck] 更新された plugin はありません。", vim.log.levels.INFO)
    end
    return
  end

  if vim.fn.executable("claude") == 0 then
    vim.notify(
      "[VulnCheck] claude コマンドが見つかりません。チェックをスキップします。",
      vim.log.levels.WARN
    )
    return
  end

  running = true
  vim.notify(
    string.format("[VulnCheck] %d plugin の更新差分をチェックします...", #targets),
    vim.log.levels.INFO
  )
  process(targets, function(results)
    running = false
    local lines = build_report(results)
    vim.schedule(function()
      show_report(lines)
      if config.save_to_file then
        save_report(lines)
      end
    end)
  end)
end

---@param opts? LazyVulnCheckConfig
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if config.auto then
    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("r-okm.LazyVulnCheck", {}),
      pattern = { "LazySync", "LazyUpdate" },
      callback = function()
        M.run()
      end,
    })
  end

  -- 手動トリガは auto の有無に関わらず常に使えるようにする
  vim.api.nvim_create_user_command("LazyVulnCheck", function()
    M.run({ manual = true })
  end, { nargs = 0, desc = "更新された plugin の差分を AI で脆弱性チェック" })
end

return M
