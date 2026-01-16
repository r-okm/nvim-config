local state = require("husen.state")
local ui = require("husen.ui")

local M = {}

--- Get current buffer index in components
---@return integer?
local function get_current_index()
  local current_buf = vim.api.nvim_get_current_buf()
  return state.get_index_by_id(current_buf)
end

--- Save custom sort order
local function save_sort_order()
  local ids = {}
  for _, comp in ipairs(state.components) do
    table.insert(ids, comp.id)
  end
  state.custom_sort = ids
end

--- Cycle through buffers
---@param direction number 1 for next, -1 for previous
function M.cycle(direction)
  ui.update_components()

  local index = get_current_index()
  if not index then
    return
  end

  local length = #state.components
  if length <= 1 then
    return
  end

  local next_index = index + direction
  local config = ui.get_config()

  if next_index <= length and next_index >= 1 then
    next_index = index + direction
  elseif config.wrap_at_ends then
    if index + direction <= 0 then
      next_index = length
    else
      next_index = 1
    end
  else
    return
  end

  local item = state.components[next_index]
  if item and vim.api.nvim_buf_is_valid(item.id) then
    vim.api.nvim_set_current_buf(item.id)
  end
end

--- Move current buffer position
---@param direction number 1 for right, -1 for left
function M.move(direction)
  ui.update_components()

  local index = get_current_index()
  if not index then
    return
  end

  local length = #state.components
  if length <= 1 then
    return
  end

  local next_index = index + direction
  local config = ui.get_config()

  if config.wrap_at_ends then
    if next_index <= 0 then
      next_index = length
    elseif next_index > length then
      next_index = 1
    end
  else
    if next_index <= 0 or next_index > length then
      return
    end
  end

  -- Swap positions
  local item = state.components[index]
  local destination = state.components[next_index]
  state.components[next_index] = item
  state.components[index] = destination

  save_sort_order()
  ui.refresh_menu()
end

function M.toggle_menu()
  ui.toggle_menu()
end

return M
