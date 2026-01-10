local M = {}

---@type slip.State
local state = {
  components = {},
  menu_type = "expand",
}

return setmetatable(M, {
  __index = function(_, k)
    return state[k]
  end,
  __newindex = function(_, k, v)
    state[k] = v
  end,
})
