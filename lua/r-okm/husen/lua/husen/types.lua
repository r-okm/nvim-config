---@class husen.Component
---@field id integer
---@field name string
---@field path string
---@field modified boolean

---@class husen.State
---@field components husen.Component[]
---@field current_element_index number?
---@field custom_sort integer[]?
---@field win_id integer?
---@field buf_id integer?

---@class husen.Config
---@field ui husen.UIConfig
---@field wrap_at_ends boolean

---@class husen.UIConfig
---@field width integer?
---@field position "top-right" | "top-left" | "bottom-right" | "bottom-left" | "center"
---@field offset_x integer
---@field offset_y integer
