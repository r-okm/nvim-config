local M = {}

local state = require("husen.state")

-- Find main content window (non-floating)
local function find_main_window()
  local current_win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_config(current_win).relative == "" then
    return current_win
  end
  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win_id).relative == "" then
      return win_id
    end
  end
  return current_win
end

-- Calculate window position
local function calculate_position(width, height)
  local ui = vim.api.nvim_list_uis()[1]
  local floating = config.ui.floating
  local position = floating.position or "middle-right"
  local offset_x = floating.offset_x or 0
  local offset_y = floating.offset_y or 0

  local row, col

  -- Vertical positioning
  if position:match("^top") then
    row = 0
  elseif position:match("^bottom") then
    row = ui.height - height
  else
    row = math.floor((ui.height - height) / 2)
  end

  -- Horizontal positioning
  if position:match("left$") then
    col = 0
  else
    col = ui.width - width + 1
  end

  return row + offset_y, col + offset_x
end

-- Create the transparent floating window
local function create_window(width, height)
  local row, col = calculate_position(width, height)

  local bufnr = vim.api.nvim_create_buf(false, true)
  local win_id = vim.api.nvim_open_win(bufnr, false, {
    relative = "editor",
    style = "minimal",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "none",
    focusable = false,
  })

  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
  vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
  vim.api.nvim_set_option_value("wrap", false, { win = win_id })
  vim.api.nvim_set_option_value("winblend", 0, { win = win_id })
  vim.api.nvim_set_option_value("winhighlight", "Normal:", { win = win_id })

  return { bufnr = bufnr, win_id = win_id }
end

-- Update window size dynamically
local function update_window_size(width, height)
  if not state.win_id or not vim.api.nvim_win_is_valid(state.win_id) then
    return
  end

  local row, col = calculate_position(width, height)

  pcall(vim.api.nvim_win_set_config, state.win_id, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
  })
end

function M.refresh_menu() end

function M.is_open_menu()
  return state.win_id and vim.api.nvim_win_is_valid(state.win_id)
end

function M.toggle_menu()
  if M.is_open_menu() then
    M.close_menu()
  else
    M.open_menu()
  end
end

function M.open_menu()
  state.buffers = get_display_names()

  local current_buf = vim.api.nvim_get_current_buf()
  local max_width = 0
  local height = 0

  for _, buf_info in ipairs(state.buffers) do
    local modified_marker = buf_info.modified and " +" or ""
    local is_current = buf_info.id == current_buf
    local prefix = is_current and "▸" or " "
    local line = string.format("%s%s%s", prefix, buf_info.display_name, modified_marker)
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
    height = height + 1
  end

  if height == 0 then
    height = 1
    max_width = vim.fn.strdisplaywidth(" No buffers available")
  end

  create_window(max_width, height)

  render_buffer_list()
end

function M.close_menu()
  if M.is_open_menu() then
    vim.api.nvim_win_close(state.win_id, true)
  end
  state.win_id = nil
  state.buf_id = nil
end

return M
