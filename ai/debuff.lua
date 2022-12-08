---@type Mq
local mq = require('mq')

---@class debuff
---@field public Output string # AI Debug String
debuff = {
    Output = '',
}

---Attempts to cast a debuff spell
---@param elixir elixir
function debuff:Cast(elixir)
    debuff.Output = "Rawr"
end

return debuff