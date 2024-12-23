local M = {}

---通常 visual モード時の選択範囲のテキストを取得する
---@return string|nil selected_text 選択範囲のテキスト
function M.getVisualSelection()
  -- Visualモードの確認
  local mode = vim.fn.mode()

  if mode ~= "v" then
    return nil
  else
    -- ヤンク前のテキスト
    local previous_register = vim.fn.getreg("z")
    -- Visualモードで選択された範囲をzレジスタにヤンク
    vim.cmd('noautocmd normal! "zy')
    -- zレジスタからテキストを取得
    local selected_text = vim.fn.getreg("z")
    -- 改行コードを取り除く
    selected_text = string.gsub(selected_text, "\n", "")
    -- zレジストの内容をリセット
    vim.fn.setreg("z", previous_register)

    return selected_text
  end
end

local function _getModesTableFromStr(modeStr)
  -- 文字列を1字ずつ分割し配列に変換
  -- ex) "nx" => {"n", "x"}
  local modes = {}
  if modeStr == "" then
    table.insert(modes, "")
  else
    for i = 1, string.len(modeStr) do
      local mode = string.sub(modeStr, i, i)
      table.insert(modes, mode)
    end
  end
  return modes
end

local function _appendCommonOpts(opts)
  local _opts = opts or {}

  if _opts.noremap == nil then
    _opts.noremap = true
  end
  if _opts.silent == nil then
    _opts.silent = true
  end

  return _opts
end

local function _getRhsFromVsCmd(cmd, vs_args)
  local rhs
  if vs_args ~= nil then
    rhs = string.format("<Cmd> call VSCodeNotify('%s', %s)<Cr>", cmd, vs_args)
  else
    rhs = string.format("<Cmd> call VSCodeNotify('%s')<Cr>", cmd)
  end

  return rhs
end

local function _getRhsFromVsVisualCmd(cmd, vs_args)
  local rhs
  if vs_args ~= nil then
    -- <Cmd> call VSCodeNotifyVisual()<Cr> の後に <Esc> を追記することでコマンド実行後にノーマルモードに移行する
    -- VSCodeNotifyVisual の第二引数に 0 を入れることで､コマンド実行後の vscode の文字選択状態を解除する
    rhs = string.format("<Cmd> call VSCodeCall('%s', %s)<Cr><Esc>", cmd, vs_args)
  else
    rhs = string.format("<Cmd> call VSCodeCall('%s')<Cr><Esc>", cmd)
  end

  return rhs
end

---vscode コマンドのキーマップを設定する
---@param modeStr string コマンドを有効化するモード
---@param lhs string コマンドを発火させるキー
---@param cmd string vscode command id
---@param vs_args? string vscode コマンドの引数
---@param opts? table オプション
function M.keymapVsc(modeStr, lhs, cmd, vs_args, opts)
  local _modes = _getModesTableFromStr(modeStr)
  local _rhs = _getRhsFromVsCmd(cmd, vs_args)
  local _opts = _appendCommonOpts(opts)

  vim.keymap.set(_modes, lhs, _rhs, _opts)
end

---visual モード時の vscode コマンドのキーマップを設定する
---@param modeStr string コマンドを有効化するモード
---@param lhs string コマンドを発火させるキー
---@param cmd string vscode command id
---@param vs_args? string vscode コマンドの引数
---@param opts? table オプション
function M.keymapVscVisual(modeStr, lhs, cmd, vs_args, opts)
  local _modes = _getModesTableFromStr(modeStr)
  local _rhs = _getRhsFromVsVisualCmd(cmd, vs_args)
  local _opts = _appendCommonOpts(opts)

  vim.keymap.set(_modes, lhs, _rhs, _opts)
end

return M
