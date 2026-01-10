local M = {}

local state = {
  buffers = {},
  win_id = nil,
  buf_id = nil,
  ns_id = vim.api.nvim_create_namespace("husen"),
}

local function get_valid_buffers()
  local buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" then
        table.insert(buffers, {
          id = buf,
          name = name,
          modified = vim.bo[buf].modified,
          loaded = vim.api.nvim_buf_is_loaded(buf),
        })
      end
    end
  end

  table.sort(buffers, function(a, b)
    return a.id < b.id
  end)

  return buffers
end

local function get_display_names()
  local buffers = get_valid_buffers()
  local display_names = {}
  local filename_counts = {}

  for _, buf in ipairs(buffers) do
    local filename = vim.fn.fnamemodify(buf.name, ":t")
    filename_counts[filename] = (filename_counts[filename] or 0) + 1
  end

  for _, buf in ipairs(buffers) do
    local filename = vim.fn.fnamemodify(buf.name, ":t")
    local display_name

    if filename_counts[filename] > 1 then
      local parent = vim.fn.fnamemodify(buf.name, ":h:t")
      display_name = parent .. "/" .. filename
    else
      display_name = filename
    end

    table.insert(display_names, {
      id = buf.id,
      name = buf.name,
      display_name = display_name,
      modified = buf.modified,
      loaded = buf.loaded,
    })
  end

  return display_names
end

-- Calculate window position
local function calculate_position(width, height)
  local ui = vim.api.nvim_list_uis()[1]

  local row = 0
  local col = ui.width - width + 1

  return row, col
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

local function get_current_buffer_index()
  local current = vim.api.nvim_get_current_buf()
  state.buffers = get_display_names()

  for i, buf in ipairs(state.buffers) do
    if buf.id == current then
      return i
    end
  end
  return nil
end

local function render_buffer_list()
  if not state.buf_id or not vim.api.nvim_buf_is_valid(state.buf_id) then
    return
  end

  state.buffers = get_display_names()
  local current_buf = vim.api.nvim_get_current_buf()

  local lines = {}
  local highlights = {}
  local max_width = 0

  -- First pass: calculate max width
  for _, buf_info in ipairs(state.buffers) do
    local modified_marker = buf_info.modified and " +" or ""
    local is_current = buf_info.id == current_buf
    local prefix = is_current and "▸" or " "
    local line = string.format("%s%s%s", prefix, buf_info.display_name, modified_marker)
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
  end

  -- Second pass: create right-aligned lines
  for i, buf_info in ipairs(state.buffers) do
    local modified_marker = buf_info.modified and " +" or ""
    local is_current = buf_info.id == current_buf
    local prefix = is_current and "▸" or " "
    local content = string.format("%s%s%s", prefix, buf_info.display_name, modified_marker)
    local content_width = vim.fn.strdisplaywidth(content)
    local padding = string.rep(" ", max_width - content_width)
    local line = padding .. content

    table.insert(lines, line)

    if is_current then
      table.insert(highlights, {
        line = i - 1,
        hl_group = "Visual",
      })
    elseif buf_info.modified then
      table.insert(highlights, {
        line = i - 1,
        hl_group = "DiffChange",
        col_start = #line - 1,
        col_end = #line,
      })
    end
  end

  if #lines == 0 then
    lines = { " No buffers available" }
    max_width = vim.fn.strdisplaywidth(lines[1])
  end

  vim.bo[state.buf_id].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf_id, 0, -1, false, lines)
  vim.bo[state.buf_id].modifiable = false

  vim.api.nvim_buf_clear_namespace(state.buf_id, state.ns_id, 0, -1)
  for _, hl in ipairs(highlights) do
    if hl.col_start then
      vim.api.nvim_buf_add_highlight(state.buf_id, state.ns_id, hl.hl_group, hl.line, hl.col_start, hl.col_end)
    else
      vim.api.nvim_buf_add_highlight(state.buf_id, state.ns_id, hl.hl_group, hl.line, 0, -1)
    end
  end

  return max_width, #lines
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
