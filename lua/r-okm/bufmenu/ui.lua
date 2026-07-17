--- bufmenu の描画層。状態を受け取ってフロートを描くだけで、状態は一切持たない
--- (フロートのウィンドウ/バッファハンドルのみ管理する)。
local M = {}

local ns = vim.api.nvim_create_namespace("r_okm_bufmenu")

---@type integer|nil
local float_win = nil
---@type integer|nil
local float_buf = nil

function M.define_highlights()
  local hl = vim.api.nvim_set_hl
  -- NormalFloat はエディタ背景と微妙に違う色になるカラースキームが多いため、
  -- 背景を指定せずエディタ背景に溶け込ませる
  hl(0, "BufMenuNormal", { bg = "NONE", fg = "NONE", default = true })
  hl(0, "BufMenuCurrent", { bold = true, default = true })
  hl(0, "BufMenuModified", { link = "DiagnosticWarn", default = true })
  hl(0, "BufMenuInactive", { link = "Comment", default = true })
  hl(0, "BufMenuLabelIdle", { link = "Visual", default = true })
  hl(0, "BufMenuLabel", { link = "DiagnosticVirtualTextHint", default = true })
  hl(0, "BufMenuLabelDelete", { link = "DiagnosticVirtualTextError", default = true })
  hl(0, "BufMenuLabelSplit", { link = "DiagnosticVirtualTextInfo", default = true })
end

---@return boolean
function M.is_open()
  return float_win ~= nil
    and vim.api.nvim_win_is_valid(float_win)
    and float_buf ~= nil
    and vim.api.nvim_buf_is_valid(float_buf)
    -- フロートはタブページローカル。別タブに取り残された有効ウィンドウを
    -- 「開いている」と数えると現在タブに一切表示されなくなるため、
    -- 現在タブに無ければ閉じて開き直す対象とする
    and vim.api.nvim_win_get_tabpage(float_win) == vim.api.nvim_get_current_tabpage()
end

function M.close()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, true)
  end
  float_win, float_buf = nil, nil
end

---@return integer editor_width, integer editor_height
local function editor_size()
  -- headless (UI 未接続) では nvim_list_uis() が空になるため options に落とす
  local ui = vim.api.nvim_list_uis()[1]
  if ui then
    return ui.width, ui.height
  end
  return vim.o.columns, vim.o.lines
end

---@param width integer
---@param height integer
---@return table win_config
local function float_config(width, height)
  local editor_w, editor_h = editor_size()
  return {
    relative = "editor",
    style = "minimal",
    focusable = false,
    width = width,
    height = height,
    row = math.max(0, math.floor((editor_h - height) / 2)),
    col = math.max(0, editor_w - width),
  }
end

---@param width integer
---@param height integer
local function ensure_window(width, height)
  if M.is_open() then
    local config = float_config(width, height)
    config.style = nil
    config.focusable = nil
    vim.api.nvim_win_set_config(float_win, config)
    return
  end
  M.close()
  float_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[float_buf].bufhidden = "wipe"
  vim.bo[float_buf].swapfile = false
  local config = float_config(width, height)
  -- noautocmd: フロート生成が WinNew を発火させると自前の autocmd が
  -- 再描画をスケジュールしてしまうため抑止する
  config.noautocmd = true
  float_win = vim.api.nvim_open_win(float_buf, false, config)
  vim.wo[float_win].winhighlight = "Normal:BufMenuNormal"
  vim.wo[float_win].wrap = false
end

--- basename が衝突するパスに対し、一意になる最短のパスサフィックスを表示名にする
---@param paths string[]
---@return table<string, string> path -> display name
function M.display_names(paths)
  local by_base = {}
  for _, path in ipairs(paths) do
    local base = vim.fs.basename(path)
    by_base[base] = by_base[base] or {}
    table.insert(by_base[base], path)
  end

  local result = {}
  for base, group in pairs(by_base) do
    if #group == 1 then
      result[group[1]] = base
    else
      local components = {}
      for _, path in ipairs(group) do
        components[path] = vim.split(path, "/", { plain = true, trimempty = true })
      end
      for _, path in ipairs(group) do
        local comps = components[path]
        for depth = 2, #comps do
          local suffix = table.concat(vim.list_slice(comps, #comps - depth + 1), "/")
          local unique = true
          for _, other in ipairs(group) do
            if other ~= path then
              local oc = components[other]
              local other_suffix = table.concat(vim.list_slice(oc, math.max(1, #oc - depth + 1)), "/")
              if other_suffix == suffix then
                unique = false
                break
              end
            end
          end
          if unique then
            result[path] = suffix
            break
          end
        end
        result[path] = result[path] or path
      end
    end
  end
  return result
end

--- カレント行が見える表示スライスを返す (ページネーションの代わり)
---@param total integer
---@param cur_idx integer
---@param max_height integer
---@return integer first, integer last
local function visible_range(total, cur_idx, max_height)
  if total <= max_height then
    return 1, total
  end
  local first = cur_idx - math.floor(max_height / 2)
  first = math.max(1, math.min(first, total - max_height + 1))
  return first, first + max_height - 1
end

---@return table<integer, boolean> bufnr -> is displayed in some window
local function displayed_buffers()
  local displayed = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    displayed[vim.api.nvim_win_get_buf(win)] = true
  end
  return displayed
end

---@class BufMenuHl
---@field [1] integer line (0-indexed)
---@field [2] integer col_start (byte)
---@field [3] integer col_end (byte)
---@field [4] string hl_group

---@param bufs integer[]
---@param cur integer
---@return string[] lines, BufMenuHl[] hls
local function build_dashed(bufs, cur)
  local lines, hls = {}, {}
  for i, buf in ipairs(bufs) do
    local is_cur = buf == cur
    local dash = is_cur and "──" or " ─"
    table.insert(lines, dash .. " ")
    local group = "BufMenuInactive"
    if vim.bo[buf].modified then
      group = "BufMenuModified"
    elseif is_cur then
      group = "BufMenuCurrent"
    end
    table.insert(hls, { i - 1, 0, #dash, group })
  end
  return lines, hls
end

---@param bufs integer[]
---@param state BufMenuRenderState
---@param cur integer
---@return string[] lines, BufMenuHl[] hls
local function build_full(bufs, state, cur)
  local paths = {}
  for _, buf in ipairs(bufs) do
    table.insert(paths, vim.api.nvim_buf_get_name(buf))
  end
  local names = M.display_names(paths)

  local name_width = 0
  for _, path in ipairs(paths) do
    name_width = math.max(name_width, vim.fn.strwidth(names[path]))
  end

  -- 通常時は控えめな色にし、ジャンプモード (アクション待ち) 中だけ
  -- アクションに応じた色に変えて状態を判別できるようにする
  local label_group = "BufMenuLabelIdle"
  if state.jump_mode == "open" then
    label_group = "BufMenuLabel"
  elseif state.jump_mode == "delete" then
    label_group = "BufMenuLabelDelete"
  elseif state.jump_mode == "vsplit" or state.jump_mode == "split" then
    label_group = "BufMenuLabelSplit"
  end

  local displayed = displayed_buffers()
  local lines, hls = {}, {}
  for i, buf in ipairs(bufs) do
    local name = names[paths[i]]
    local label = state.labels[buf] or " "
    local pad = string.rep(" ", name_width - vim.fn.strwidth(name))
    local line = " " .. name .. pad .. "  " .. label .. " "
    table.insert(lines, line)

    local name_end = 1 + #name
    if buf == cur then
      table.insert(hls, { i - 1, 1, name_end, "BufMenuCurrent" })
    elseif not displayed[buf] then
      table.insert(hls, { i - 1, 1, name_end, "BufMenuInactive" })
    end
    if vim.bo[buf].modified then
      table.insert(hls, { i - 1, 1, name_end, "BufMenuModified" })
    end
    local label_start = #line - #label - 1
    table.insert(hls, { i - 1, label_start, label_start + #label, label_group })
  end
  return lines, hls
end

---@class BufMenuRenderState
---@field items integer[]
---@field labels table<integer, string>
---@field style "full"|"dashed"
---@field jump_mode nil|"open"|"delete"|"vsplit"|"split"

-- 直前の描画内容の署名。WinClosed 等の頻発イベントで同一内容を再構築しない
---@type string|nil
local last_signature = nil

---@param lines string[]
---@param hls BufMenuHl[]
---@param editor_w integer
---@param editor_h integer
---@return string
local function render_signature(lines, hls, editor_w, editor_h)
  local parts = { editor_w .. "x" .. editor_h, table.concat(lines, "\n") }
  for _, hl in ipairs(hls) do
    table.insert(parts, string.format("%d:%d:%d:%s", hl[1], hl[2], hl[3], hl[4]))
  end
  return table.concat(parts, "\0")
end

---@param state BufMenuRenderState
function M.render(state)
  if #state.items == 0 then
    M.close()
    last_signature = nil
    return
  end

  -- ジャンプ中はラベルが見えないと操作できないため full を強制する
  local style = state.jump_mode and "full" or state.style

  local editor_w, editor_h = editor_size()
  local max_height = math.max(1, editor_h - 4)
  local cur = vim.api.nvim_get_current_buf()
  local cur_idx = 1
  for i, buf in ipairs(state.items) do
    if buf == cur then
      cur_idx = i
    end
  end
  local first, last = visible_range(#state.items, cur_idx, max_height)
  local bufs = vim.list_slice(state.items, first, last)

  local lines, hls
  if style == "dashed" then
    lines, hls = build_dashed(bufs, cur)
  else
    lines, hls = build_full(bufs, state, cur)
  end

  -- ウィンドウが開いたまま内容も位置も変わらないなら再構築しない
  -- (閉じているときは :only 後の開き直しが必要なのでスキップしない)
  local signature = render_signature(lines, hls, editor_w, editor_h)
  if M.is_open() and signature == last_signature then
    return
  end

  local width = 1
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strwidth(line))
  end

  ensure_window(width, #lines)

  vim.bo[float_buf].modifiable = true
  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
  vim.bo[float_buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(float_buf, ns, 0, -1)
  for _, hl in ipairs(hls) do
    vim.api.nvim_buf_set_extmark(float_buf, ns, hl[1], hl[2], {
      end_col = hl[3],
      hl_group = hl[4],
    })
  end
  last_signature = signature
end

return M
