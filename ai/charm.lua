---@type Mq
local mq = require('mq')

---@class charm
---@field public Output string # AI Debug String
charm = {
    Output = '',
}

---Attempts to cast a charm spell
---@param elixir elixir
function charm:Cast(elixir)
    if mq.TLO.EverQuest.Foreground() then
        return
    end
end

return charm