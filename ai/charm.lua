---@type Mq
local mq = require('mq')

---@class charm
---@field public Output string # AI Debug String
---@field private charmCooldown number
charm = {
    Output = '',
    charmCooldown = 0,
}

---Attempts to cast a charm spell
---@param elixir elixir
function charm:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsCharmAI then return "charm ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    return ""
end

return charm