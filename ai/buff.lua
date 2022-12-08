---@type Mq
local mq = require('mq')

---@class buff
---@field public Output string # AI Debug String
buff = {
    Output = '',
}

---Attempts to cast a buff spell
---@param elixir elixir
function buff:Cast(elixir)
    buff.Output = "Rawr"
end

return buff