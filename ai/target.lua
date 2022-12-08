---@type Mq
local mq = require('mq')

---@class target
---@field public Output string # AI Debug String
target = {
    Output = '',
}

---Attempts to cast a target spell
---@param elixir elixir
function target:Check(elixir)
    target.Output = "Rawr"
end

return target