---@type Mq
local mq = require('mq')

---@class dot
---@field public Output string # AI Debug String
dot = {
    Output = '',
}

---Attempts to cast a dot spell
---@param elixir elixir
function dot:Cast(elixir)
    dot.Output = "Rawr"
end

return dot