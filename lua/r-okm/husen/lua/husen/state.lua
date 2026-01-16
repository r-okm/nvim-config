local M = {}

---@type husen.State
local state = {
  components = {},
  current_element_index = nil,
  custom_sort = nil,
  win_id = nil,
  buf_id = nil,
}

---@param updates table
function M.set(updates)
  for k, v in pairs(updates) do
    state[k] = v
  end
end

---@return husen.Component[]
function M.get_components()
  return state.components
end

---@param id integer
---@return integer?
function M.get_index_by_id(id)
  for i, comp in ipairs(state.components) do
    if comp.id == id then
      return i
    end
  end
  return nil
end

return setmetatable(M, {
  __index = function(_, k)
    return state[k]
  end,
  __newindex = function(_, k, v)
    state[k] = v
  end,
})
