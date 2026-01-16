local state = require("husen.state")

local M = {}

---@type husen.Config
local config = {
  ui = {
    width = nil,
    position = "top-right",
    offset_x = 0,
    offset_y = 0,
  },
  wrap_at_ends = true,
}

---@param opts husen.Config?
function M.set_config(opts)
  if opts then
    config = vim.tbl_deep_extend("force", config, opts)
  end
end

---@return husen.Config
function M.get_config()
  return config
end

--- Check if a buffer is valid (listed and has a name)
---@param buf_id integer
---@param buf_name string
---@return boolean
local function buffer_is_valid(buf_id, buf_name)
  return vim.fn.buflisted(buf_id) == 1 and buf_name ~= ""
end

--- Extract the filename from a full file path
---@param file string
---@return string
local function get_file_name(file)
  return file:match("[^/\\]*$") or file
end

--- Split a path into components
---@param path string
---@return string[]
local function split_path(path)
  local components = {}
  for part in string.gmatch(path, "[^/\\]+") do
    table.insert(components, part)
  end
  return components
end

--- Compute minimal distinguishing display names
---@param paths string[]
---@return table<string, string>
local function get_display_names(paths)
  local display_names = {}
  local by_filename = {}

  for _, path in ipairs(paths) do
    local filename = get_file_name(path)
    if not by_filename[filename] then
      by_filename[filename] = {}
    end
    table.insert(by_filename[filename], path)
  end

  for filename, group in pairs(by_filename) do
    if #group == 1 then
      display_names[group[1]] = filename
    else
      local path_components = {}
      for _, path in ipairs(group) do
        path_components[path] = split_path(path)
      end

      for _, path in ipairs(group) do
        local components = path_components[path]
        local num_components = #components

        for depth = 1, num_components do
          local candidate_parts = {}
          for i = num_components - depth + 1, num_components do
            table.insert(candidate_parts, components[i])
          end
          local candidate = table.concat(candidate_parts, "/")

          local is_unique = true
          for _, other_path in ipairs(group) do
            if other_path ~= path then
              local other_components = path_components[other_path]
              local other_num = #other_components

              if other_num >= depth then
                local other_parts = {}
                for i = other_num - depth + 1, other_num do
                  table.insert(other_parts, other_components[i])
                end
                local other_candidate = table.concat(other_parts, "/")

                if candidate == other_candidate then
                  is_unique = false
                  break
                end
              end
            end
          end

          if is_unique then
            display_names[path] = candidate
            break
          end
        end

        if not display_names[path] then
          display_names[path] = path
        end
      end
    end
  end

  return display_names
end

--- Update components from current buffers
function M.update_components()
  -- Remove invalid buffers
  local components = state.components
  for idx = #components, 1, -1 do
    local comp = components[idx]
    if not vim.api.nvim_buf_is_valid(comp.id) or not buffer_is_valid(comp.id, comp.path) then
      table.remove(components, idx)
    end
  end

  -- Add new buffers
  local paths = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.api.nvim_buf_get_name(buf)
    if buffer_is_valid(buf, bufname) then
      local found = false
      for _, comp in ipairs(components) do
        if comp.id == buf then
          found = true
          break
        end
      end
      if not found then
        table.insert(components, {
          id = buf,
          name = get_file_name(bufname),
          path = bufname,
          modified = vim.bo[buf].modified,
        })
        table.insert(paths, bufname)
      else
        table.insert(paths, bufname)
      end
    end
  end

  -- Update display names
  local display_names = get_display_names(paths)
  for _, comp in ipairs(components) do
    if display_names[comp.path] then
      comp.name = display_names[comp.path]
    end
    comp.modified = vim.bo[comp.id].modified
  end

  -- Apply custom sort if exists
  if state.custom_sort and #state.custom_sort > 0 then
    local order_map = {}
    for i, id in ipairs(state.custom_sort) do
      order_map[id] = i
    end
    table.sort(components, function(a, b)
      local a_order = order_map[a.id] or 9999
      local b_order = order_map[b.id] or 9999
      if a_order == b_order then
        return a.id < b.id
      end
      return a_order < b_order
    end)
  end

  -- Update current index
  local current_buf = vim.api.nvim_get_current_buf()
  for i, comp in ipairs(components) do
    if comp.id == current_buf then
      state.current_element_index = i
      break
    end
  end
end

--- Calculate window position
---@param width integer
---@param height integer
---@return integer row
---@return integer col
local function calculate_position(width, height)
  local ui = vim.api.nvim_list_uis()[1]
  local position = config.ui.position
  local offset_x = config.ui.offset_x
  local offset_y = config.ui.offset_y

  local row, col

  if position:match("^top") then
    row = 0
  elseif position:match("^bottom") then
    row = ui.height - height
  else
    row = math.floor((ui.height - height) / 2)
  end

  if position:match("left$") then
    col = 0
  elseif position == "center" then
    col = math.floor((ui.width - width) / 2)
  else
    col = ui.width - width
  end

  return row + offset_y, col + offset_x
end

--- Create floating window
---@param width integer
---@param height integer
---@return integer bufnr
---@return integer win_id
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
  vim.api.nvim_buf_set_var(bufnr, "husen_menu", true)

  vim.api.nvim_set_option_value("wrap", false, { win = win_id })
  vim.api.nvim_set_option_value("winblend", 0, { win = win_id })
  vim.api.nvim_set_option_value("winhighlight", "Normal:", { win = win_id })

  return bufnr, win_id
end

--- Render buffer list
local function render_buffer_list()
  if not state.buf_id or not vim.api.nvim_buf_is_valid(state.buf_id) then
    return
  end

  local components = state.components
  local current_buf = vim.api.nvim_get_current_buf()

  local lines = {}
  local highlights = {}

  for i, comp in ipairs(components) do
    local is_current = comp.id == current_buf
    local prefix = is_current and "▸" or " "
    local modified_marker = comp.modified and " +" or ""
    local line = string.format("%s%s%s", prefix, comp.name, modified_marker)
    table.insert(lines, line)

    if is_current then
      table.insert(highlights, { line = i - 1, hl = "Bold" })
    elseif comp.modified then
      table.insert(highlights, { line = i - 1, hl = "DiagnosticWarn" })
    end
  end

  if #lines == 0 then
    lines = { " No buffers" }
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = state.buf_id })
  vim.api.nvim_buf_set_lines(state.buf_id, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = state.buf_id })

  local ns_id = vim.api.nvim_create_namespace("husen")
  vim.api.nvim_buf_clear_namespace(state.buf_id, ns_id, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(state.buf_id, ns_id, hl.hl, hl.line, 0, -1)
  end
end

--- Update window size
local function update_window_size()
  if not state.win_id or not vim.api.nvim_win_is_valid(state.win_id) then
    return
  end

  local components = state.components
  local current_buf = vim.api.nvim_get_current_buf()
  local max_width = 0
  local height = #components

  for _, comp in ipairs(components) do
    local is_current = comp.id == current_buf
    local prefix = is_current and "▸" or " "
    local modified_marker = comp.modified and " +" or ""
    local line = string.format("%s%s%s", prefix, comp.name, modified_marker)
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
  end

  if height == 0 then
    height = 1
    max_width = vim.fn.strdisplaywidth(" No buffers")
  end

  local width = config.ui.width or max_width
  local row, col = calculate_position(width, height)

  pcall(vim.api.nvim_win_set_config, state.win_id, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
  })
end

function M.refresh_menu()
  if not M.is_open_menu() then
    return
  end

  M.update_components()
  update_window_size()
  render_buffer_list()
end

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
  if M.is_open_menu() then
    return
  end

  M.update_components()

  local components = state.components
  local current_buf = vim.api.nvim_get_current_buf()
  local max_width = 0
  local height = #components

  for _, comp in ipairs(components) do
    local is_current = comp.id == current_buf
    local prefix = is_current and "▸" or " "
    local modified_marker = comp.modified and " +" or ""
    local line = string.format("%s%s%s", prefix, comp.name, modified_marker)
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
  end

  if height == 0 then
    height = 1
    max_width = vim.fn.strdisplaywidth(" No buffers")
  end

  local width = config.ui.width or max_width

  local bufnr, win_id = create_window(width, height)
  state.buf_id = bufnr
  state.win_id = win_id

  render_buffer_list()
end

function M.close_menu()
  if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
    vim.api.nvim_win_close(state.win_id, true)
  end
  state.win_id = nil
  state.buf_id = nil
end

return M
