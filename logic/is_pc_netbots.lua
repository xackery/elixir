---@type Mq
local mq = require('mq')

---Checks if a PC is using netbots and is connected
---@param name string
---@returns IsNetbotsEnabled boolean # Returns true when a spawn appears poisoned
function IsPCNetbots(name)
    if not mq.TLO.Plugin('mq2eqbc').IsLoaded() then return false end
    if not mq.TLO.EQBC.Connected() then return false end
    for i= 1, mq.TLO.NetBots.Counts() do
        if mq.TLO.NetBots.Client.Arg(i)() == name then return true end
    end
    return false
end