---@type Mq
local mq = require('mq')

---@class nuke
---@field public Output string # AI Debug String
nuke = {
    Output = '',
}

---Attempts to cast a nuke spell
---@param elixir elixir
function nuke:Cast(elixir)
    nuke.Output = "Rawr"
end

return nuke