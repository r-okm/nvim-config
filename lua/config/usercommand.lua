local util = require("r-okm.util")

-- カレントバッファのファイルパスをレジスタにヤンクする
local function yankCurrentBufferPathToClipboard(opts)
  local result = ""
  local filepath = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")

  -- 範囲選択時は、選択範囲もコードブロックとしてレジスタにヤンクする
  if opts.range == 2 then
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
    local selection = table.concat(lines, "\n")
    local ft = vim.bo.filetype or ""
    result = "@" .. filepath .. "\n```" .. ft .. "\n" .. selection .. "\n```"
  else
    result = filepath
  end

  vim.fn.setreg("+", result)
end
vim.api.nvim_create_user_command(
  "YankPath",
  yankCurrentBufferPathToClipboard,
  { nargs = "*", range = true, desc = "Copy current buffer filepath to register" }
)

--- 現在のファイルをGitHub WebのURLで開く
---
--- Visual modeで選択した範囲またはカーソル位置の行を含むGitHubのURLを構築し、
--- デフォルトのブラウザで開きます。SSH URLやHTTPS URLの両方に対応し、
--- 現在のコミットSHAを使用してパーマリンクを生成します。
---
--- @param opts {args?: string, range: number, line1?: number, line2?: number} コマンドオプション
---   - args: リモート名（省略時は "origin"）
---   - range: 範囲指定の種類 (0: なし, 1: 行数指定, 2: 範囲指定/visual selection)
---   - line1: 開始行番号（range == 2の場合）
---   - line2: 終了行番号（range == 2の場合）
---
--- @usage
--- -- デフォルト（originリモート、現在行）
--- :GHOpen
---
--- -- upstreamリモートを指定
--- :GHOpen upstream
---
--- -- Visual modeで範囲選択してから実行
--- -- 選択範囲がGitHubのURLに反映される
---
--- @see vim.api.nvim_create_user_command
local function openCurrentFileInGitHub(opts)
  local filepath = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  if filepath == "" then
    vim.notify("No file is currently open", vim.log.levels.WARN)
    return
  end

  -- リモート名を取得（引数で指定されていない場合は "origin" を使用）
  local remote_name = opts.args and opts.args ~= "" and opts.args or "origin"

  -- Git リモートURLを取得
  local git_remote_cmd = string.format("git remote get-url %s 2>/dev/null", remote_name)
  local handle = io.popen(git_remote_cmd)
  if not handle then
    vim.notify("Failed to get git remote URL", vim.log.levels.ERROR)
    return
  end

  local remote_url = handle:read("*a"):gsub("\n", "")
  handle:close()

  if remote_url == "" then
    vim.notify(string.format("No git remote '%s' found", remote_name), vim.log.levels.WARN)
    return
  end

  -- SSH URLをHTTPS URLに変換
  local github_url
  if remote_url:match("^git@github.com:") then
    -- git@github.com:user/repo.git -> https://github.com/user/repo
    github_url = remote_url:gsub("^git@github.com:", "https://github.com/"):gsub(".git$", "")
  elseif remote_url:match("^ssh://git@github.com/") then
    -- ssh://git@github.com/user/repo.git -> https://github.com/user/repo
    github_url = remote_url:gsub("^ssh://git@github.com/", "https://github.com/"):gsub(".git$", "")
  elseif remote_url:match("^https://github.com/") then
    -- https://github.com/user/repo.git -> https://github.com/user/repo
    github_url = remote_url:gsub(".git$", "")
  elseif remote_url:match("^work.github.com:") then
    -- work.github.com:user/repo.git -> https://github.com/user/repo
    github_url = remote_url:gsub("^work.github.com:", "https://github.com/"):gsub(".git$", "")
  else
    vim.notify("Unsupported remote URL format: " .. remote_url, vim.log.levels.ERROR)
    return
  end

  -- 現在のコミットSHAを取得
  local commit_handle = io.popen("git rev-parse HEAD 2>/dev/null")
  if not commit_handle then
    vim.notify("Failed to get current commit SHA", vim.log.levels.ERROR)
    return
  end

  local commit_sha = commit_handle:read("*a"):gsub("\n", "")
  commit_handle:close()

  if commit_sha == "" then
    vim.notify("Failed to get commit SHA", vim.log.levels.ERROR)
    return
  end

  -- 行番号を取得（Visual modeの場合は選択範囲、そうでなければカーソル位置）
  local line_info
  if opts.range == 2 then
    -- Visual selectionまたは範囲指定の場合
    local start_line = opts.line1
    local end_line = opts.line2

    if start_line == end_line then
      line_info = string.format("L%d", start_line)
    else
      line_info = string.format("L%d-L%d", start_line, end_line)
    end
  else
    -- 通常モードの場合
    local line_number = vim.api.nvim_win_get_cursor(0)[1]
    line_info = string.format("L%d", line_number)
  end

  -- GitHub URLを構築（コミットSHAを使用）
  local final_url = string.format("%s/blob/%s/%s#%s", github_url, commit_sha, filepath, line_info)

  -- URLを開く
  util.open_in_browser(final_url)

  vim.notify("Opened in GitHub: " .. final_url, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("GHOpen", openCurrentFileInGitHub, {
  nargs = "?",
  range = true,
  desc = "Open current file in GitHub web interface (optional remote name, defaults to 'origin')",
})

-- Open url under cursor
vim.api.nvim_create_user_command("OpenUrl", function()
  local url = vim.fn.expand("<cfile>")
  util.open_in_browser(url)
end, { nargs = 0, desc = "Open URL under cursor in web browser" })
