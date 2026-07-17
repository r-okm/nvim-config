--- 手動順序のバッファリスト + 右中央フロートメニュー。
--- bufferline 相当のバッファ管理 (サイクル・手動並べ替え) と、bento.nvim 風の
--- ミニマル UI (常時表示・ラベルジャンプ) を提供する。
local ui = require("r-okm.bufmenu.ui")

local M = {}

-- グローバルキーマップは登録しない。cycle / move / toggle_style / jump を
-- 公開 API として提供するので、キー割当は利用側 (plugin spec の keys) で行う

---@class BufMenuJumpActionKeys ジャンプモード中のアクション切り替えキー (false で無効化)
---@field delete? string|false 削除モードをトグル
---@field vsplit? string|false vsplit モードをトグル
---@field split? string|false split モードをトグル
---@field cancel? string|false ジャンプモードを解除

---@class BufMenuConfig
---@field jump_action_keys BufMenuJumpActionKeys

-- デフォルト設定。setup(opts) で上書きできる
---@type BufMenuConfig
local config = {
  jump_action_keys = {
    delete = "<BS>",
    vsplit = "|",
    split = "_",
    cancel = "<Esc>",
  },
}

---@type integer[] 表示順の bufnr リスト (唯一の真実)
local items = {}
---@type table<integer, string> bufnr -> ラベル文字 (バッファ生存中は固定)
local labels = {}
---@type table<string, boolean>
local label_used = {}
---@type "full"|"dashed"
local style = "full"
---@type nil|"open"|"delete"|"vsplit"|"split" ジャンプモード中のアクション
local jump_mode = nil
local last_has_vsplit = false

local LABEL_POOL = "abcdefghijklmnopqrstuvwxyz"
---@type table<string, boolean> ジャンプ関連キーと衝突する文字はラベルに使わない
local reserved_labels = {}

---@return BufMenuRenderState
local function state()
  return { items = items, labels = labels, style = style, jump_mode = jump_mode }
end

---@param buf integer
---@return boolean
local function is_eligible(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.fn.buflisted(buf) == 1
    and vim.bo[buf].buftype == ""
    and vim.api.nvim_buf_get_name(buf) ~= ""
end

---@param buf integer
---@return integer|nil
local function find_index(buf)
  for i, b in ipairs(items) do
    if b == buf then
      return i
    end
  end
  return nil
end

---@param buf integer
local function release_label(buf)
  local label = labels[buf]
  if label then
    label_used[label] = nil
    labels[buf] = nil
  end
end

---@param buf integer
local function assign_label(buf)
  local candidates = {}
  -- basename 先頭の英数字を優先。英数字を含まない名前 (全角のみ等) はプールから割当
  local first = vim.fs.basename(vim.api.nvim_buf_get_name(buf)):match("%w")
  if first then
    table.insert(candidates, first:lower())
  end
  for c in LABEL_POOL:gmatch(".") do
    table.insert(candidates, c)
  end
  for _, c in ipairs(candidates) do
    if not label_used[c] and not reserved_labels[c] then
      label_used[c] = true
      labels[buf] = c
      return
    end
  end
  -- 空きが無い場合はラベルなし (ジャンプ不可だが cycle は可能)
end

--- 個別イベントの取りこぼしに対するバックストップ。
--- invalid / unlisted になったエントリを除去する
local function prune()
  for i = #items, 1, -1 do
    local buf = items[i]
    if not is_eligible(buf) then
      table.remove(items, i)
      release_label(buf)
    end
  end
end

function M.render()
  prune()
  ui.render(state())
end

-- 並び順は bufmenu 自身では再構築できない (バッファ作成順に戻る) ため、
-- sessionoptions "globals" で保存される大文字始まりのグローバル変数に永続化する
local function save_order()
  -- セッション読み込み中 (:h SessionLoad) の保存は、セッションから復元された
  -- 並び順を restore_order が読む前に上書きしてしまうためスキップする
  if vim.g.SessionLoad == 1 then
    return
  end
  -- noautocmd な wipeout で BufWipeout ハンドラが抑止された stale エントリが
  -- 残っていることがあるため、名前を引く前に除去する
  prune()
  local names = {}
  for _, buf in ipairs(items) do
    table.insert(names, vim.api.nvim_buf_get_name(buf))
  end
  vim.g.BufMenuOrder = vim.json.encode(names)
end

---@param saved_json string|nil 復元に使う保存値 (省略時は vim.g.BufMenuOrder)
local function restore_order(saved_json)
  saved_json = saved_json or vim.g.BufMenuOrder
  if type(saved_json) ~= "string" then
    return
  end
  local ok, saved = pcall(vim.json.decode, saved_json)
  if not ok or type(saved) ~= "table" then
    return
  end
  local pos = {}
  for i, name in ipairs(saved) do
    pos[name] = i
  end
  prune()
  -- table.sort は不安定なため、保存順に無いバッファは元の相対順を明示的に保って末尾へ
  local fallback = {}
  for i, buf in ipairs(items) do
    fallback[buf] = i
  end
  table.sort(items, function(a, b)
    local pa, pb = pos[vim.api.nvim_buf_get_name(a)], pos[vim.api.nvim_buf_get_name(b)]
    if pa and pb then
      return pa < pb
    end
    if pa or pb then
      return pa ~= nil
    end
    return fallback[a] < fallback[b]
  end)
  -- 途中の add_buffer が vim.g.BufMenuOrder を上書きしていても、ここで正す
  save_order()
  M.render()
end

---@param buf integer
local function add_buffer(buf)
  if not is_eligible(buf) or find_index(buf) then
    return
  end
  table.insert(items, buf)
  assign_label(buf)
  save_order()
  M.render()
end

---@param buf integer
local function remove_buffer(buf)
  local idx = find_index(buf)
  if not idx then
    return
  end
  table.remove(items, idx)
  release_label(buf)
  save_order()
  M.render()
end

---@param dir integer
function M.cycle(dir)
  prune()
  local cur = vim.api.nvim_get_current_buf()
  local idx = find_index(cur)
  if not idx then
    -- 追跡外でも通常バッファ (:enew の無名バッファ等) からは一覧へ戻れるようにする。
    -- quickfix 等の特殊ウィンドウ (buftype ~= "") では何もしない
    if #items > 0 and vim.bo[cur].buftype == "" then
      vim.api.nvim_set_current_buf(dir > 0 and items[1] or items[#items])
    end
    return
  end
  if #items < 2 then
    return
  end
  local next_buf = items[(idx - 1 + dir) % #items + 1]
  vim.api.nvim_set_current_buf(next_buf)
end

---@param dir integer
function M.move(dir)
  prune()
  local idx = find_index(vim.api.nvim_get_current_buf())
  if not idx or #items < 2 then
    return
  end
  local target = idx + dir
  if target < 1 then
    target = #items
  elseif target > #items then
    target = 1
  end
  local buf = table.remove(items, idx)
  table.insert(items, target, buf)
  save_order()
  M.render()
end

function M.toggle_style()
  style = style == "full" and "dashed" or "full"
  M.render()
end

--- winlayout の木に "row" ノードがあれば縦分割が存在する
---@param layout table|nil
---@return boolean
local function has_vertical_split(layout)
  layout = layout or vim.fn.winlayout()
  if layout[1] == "row" then
    return true
  end
  if layout[1] == "col" then
    for _, child in ipairs(layout[2]) do
      if has_vertical_split(child) then
        return true
      end
    end
  end
  return false
end

--- 縦分割中は full 表示がエディタ領域と重なりやすいため dashed に切り替える。
--- 有無が変化したときだけ設定することで、+ による手動切り替えと共存できる
local function sync_style()
  local has = has_vertical_split()
  if has == last_has_vsplit then
    return
  end
  last_has_vsplit = has
  style = has and "dashed" or "full"
  M.render()
end

---@param bufs integer[]
local function delete_buffers(bufs)
  local loaded, unloaded = {}, {}
  for _, buf in ipairs(bufs) do
    table.insert(vim.api.nvim_buf_is_loaded(buf) and loaded or unloaded, buf)
  end
  if #loaded > 0 then
    -- bufdelete.nvim でウィンドウレイアウトを保って削除 (未保存時は確認プロンプト)。
    -- 1 回のリスト呼び出しにすることで全ターゲットがウィンドウ切替先の候補から
    -- 除外され、個別呼びで起きる「削除予定バッファへの一時切替」のちらつきを防ぐ
    require("bufdelete").bufdelete(loaded, false)
  end
  for _, buf in ipairs(unloaded) do
    -- 未ロードのバッファは bufdelete が黙ってスキップする。未ロードなら
    -- どのウィンドウにも表示されていないため素の bdelete で問題ない
    pcall(vim.cmd.bdelete, buf)
  end
end

---@param win integer
---@return boolean
local function is_normal_window(win)
  return vim.api.nvim_win_get_config(win).relative == "" and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
end

-- quickfix などの特殊ウィンドウでバッファを開くと元の表示ごと壊れるため、
-- 直前のウィンドウ → タブ内の最初の通常ウィンドウの順で移ってから開く
local function goto_normal_window()
  if is_normal_window(vim.api.nvim_get_current_win()) then
    return
  end
  local candidates = { vim.fn.win_getid(vim.fn.winnr("#")) }
  vim.list_extend(candidates, vim.api.nvim_tabpage_list_wins(0))
  for _, win in ipairs(candidates) do
    if win ~= 0 and vim.api.nvim_win_is_valid(win) and is_normal_window(win) then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

---@param action "open"|"delete"|"vsplit"|"split"
---@param buf integer
local function do_action(action, buf)
  if action == "open" then
    goto_normal_window()
    vim.api.nvim_set_current_buf(buf)
  elseif action == "delete" then
    delete_buffers({ buf })
  elseif action == "vsplit" then
    goto_normal_window()
    vim.cmd("vsplit")
    vim.api.nvim_set_current_buf(buf)
  elseif action == "split" then
    goto_normal_window()
    vim.cmd("split")
    vim.api.nvim_set_current_buf(buf)
  end
end

-- bufferline の BufferLineCloseRight / CloseLeft / CloseOthers 相当。
-- 表示順で対象を決め、削除中のリスト変化に備えて先に対象を確定する
---@param filter fun(i: integer, current_idx: integer): boolean
local function close_filtered(filter)
  prune()
  local idx = find_index(vim.api.nvim_get_current_buf())
  if not idx then
    return
  end
  local targets = {}
  for i, buf in ipairs(items) do
    if filter(i, idx) then
      table.insert(targets, buf)
    end
  end
  delete_buffers(targets)
end

function M.close_right()
  close_filtered(function(i, idx)
    return i > idx
  end)
end

function M.close_left()
  close_filtered(function(i, idx)
    return i < idx
  end)
end

function M.close_others()
  close_filtered(function(i, idx)
    return i ~= idx
  end)
end

---@param key string
---@return integer|nil
local function find_by_label(key)
  for _, buf in ipairs(items) do
    if labels[buf] == key then
      return buf
    end
  end
  return nil
end

---@return table<string, string> 受信キー -> アクション名 ("cancel" 含む)
local function jump_key_lookup()
  local lookup = {}
  for action, lhs in pairs(config.jump_action_keys) do
    if lhs then
      lookup[vim.api.nvim_replace_termcodes(lhs, true, false, true)] = action
      if lhs == "<BS>" then
        -- <BS> は経路により K_BS ("\128kb") / ^H / DEL のいずれでも届く
        lookup["\8"] = action
        lookup["\127"] = action
      end
    end
  end
  return lookup
end

--- ラベルジャンプモード。getcharstr のブロッキングループで入力を消費する
--- (一時キーマップの save/restore が不要になり、マクロ・マルチバイトにも安全)。
--- ラベル = 開く / jump_action_keys でアクションモード切替 (再押下で open に戻る) /
--- cancel キー = 解除 / その他のキー = 解除して再送
function M.jump()
  prune()
  if #items == 0 then
    return
  end
  local action_of = jump_key_lookup()
  jump_mode = "open"
  pcall(function()
    while jump_mode do
      ui.render(state())
      vim.cmd("redraw")
      local ok, key = pcall(vim.fn.getcharstr)
      if not ok then -- <C-c>
        break
      end
      local action = action_of[key]
      if action == "cancel" then
        break
      elseif action then
        jump_mode = jump_mode == action and "open" or action
      else
        local buf = find_by_label(key)
        if buf then
          local action = jump_mode
          do_action(action, buf)
          if action ~= "delete" then
            break
          end
          -- delete モードは連続で削除できるよう継続する
          prune()
          if #items == 0 then
            break
          end
        else
          -- 未知キーはモード解除して通常のキーとして再送する。
          -- escape_ks=false だとマルチバイト文字中の 0x80 バイトが K_SPECIAL と
          -- 誤解釈されて化ける (例: 怒 E6 80 92 → æ)。true でも特殊キー
          -- ("\128kb" 等) の再送は正常に機能することを実測済み
          vim.api.nvim_feedkeys(key, "t", true)
          break
        end
      end
    end
  end)
  jump_mode = nil
  M.render()
end

---@class BufMenuSetupOpts config のデフォルトに deep merge される
---@field jump_action_keys? BufMenuJumpActionKeys

---@param opts? BufMenuSetupOpts
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  -- ジャンプ関連キーに 1 文字の英数字を割り当てた場合はラベル候補から除外する
  reserved_labels = {}
  for _, lhs in pairs(config.jump_action_keys) do
    if type(lhs) == "string" and lhs:match("^%w$") then
      reserved_labels[lhs:lower()] = true
    end
  end

  ui.define_highlights()

  vim.api.nvim_create_user_command("BufMenuCloseOthers", M.close_others, {
    desc = "Close all buffers except the current buffer",
  })
  vim.api.nvim_create_user_command("BufMenuCloseRight", M.close_right, {
    desc = "Close all buffers to the right of the current buffer",
  })
  vim.api.nvim_create_user_command("BufMenuCloseLeft", M.close_left, {
    desc = "Close all buffers to the left of the current buffer",
  })

  local group = vim.api.nvim_create_augroup("r-okm.BufMenu", {})
  local autocmd = vim.api.nvim_create_autocmd

  -- 発火時点では name や buflisted が未確定のことがあるため schedule で判定する
  autocmd({ "BufAdd", "BufFilePost" }, {
    group = group,
    callback = function(args)
      vim.schedule(function()
        add_buffer(args.buf)
      end)
    end,
    desc = "Track new buffers in bufmenu",
  })

  -- バックグラウンドバッファの削除は BufEnter を発火させないため remove 側で描画する
  autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    callback = function(args)
      remove_buffer(args.buf)
    end,
    desc = "Untrack removed buffers in bufmenu",
  })

  autocmd("BufEnter", {
    group = group,
    callback = function(args)
      -- 自己修復: eligible なのに未登録なら登録する (setlocal buflisted 等)
      if is_eligible(args.buf) and not find_index(args.buf) then
        add_buffer(args.buf)
      else
        M.render()
      end
    end,
    desc = "Re-render bufmenu on buffer switch",
  })

  autocmd({ "BufModifiedSet", "VimResized" }, {
    group = group,
    callback = function()
      M.render()
    end,
    desc = "Re-render bufmenu",
  })

  -- WinClosed はウィンドウが実際に消える前に発火するため、レイアウト確定後に判定する。
  -- render は :only でフロートごと閉じられた場合の開き直しも兼ねる
  autocmd({ "WinNew", "WinClosed", "TabEnter" }, {
    group = group,
    callback = function()
      vim.schedule(function()
        sync_style()
        M.render()
      end)
    end,
    desc = "Switch bufmenu style depending on vertical splits",
  })

  -- セッション読み込みは単一の同期 :source で、その間の BufAdd ハンドラ
  -- (schedule 済み) は SessionLoadPost の同期発火時点では未実行。schedule の
  -- FIFO で add_buffer 群の後に並ぶようにする。
  -- また、それら add_buffer の save_order は :source 完了後 (unlet SessionLoad 後)
  -- に走って vim.g.BufMenuOrder を上書きしてしまうため、復元値は同期時点で
  -- スナップショットしておく
  autocmd("SessionLoadPost", {
    group = group,
    callback = function()
      local saved = vim.g.BufMenuOrder
      vim.schedule(function()
        restore_order(saved)
      end)
    end,
    desc = "Restore bufmenu order after session load",
  })

  -- 実行時の :colorscheme 切替は hi clear で属性ベースのグループ定義を消すため、
  -- 定義し直す (default=true なので colorscheme 側の上書きは尊重される)
  autocmd("ColorScheme", {
    group = group,
    callback = ui.define_highlights,
    desc = "Re-define bufmenu highlights after colorscheme switch",
  })

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_eligible(buf) and not find_index(buf) then
      table.insert(items, buf)
      assign_label(buf)
    end
  end
  save_order()

  -- nvim -O やセッション復元などで読み込み時点から縦分割が存在するケースにも
  -- 初期状態を反映する
  vim.schedule(function()
    sync_style()
    M.render()
  end)
end

return M
