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
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsCharmAI then return "charm ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end

end

return charm