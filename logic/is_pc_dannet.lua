---@type Mq
local mq = require('mq')

---Checks if a PC is using dannet and is connected
---@param name string
---@returns IsDannetEnabled boolean # Returns true when a spawn appears poisoned
function IsPCDannet(name)
    if not mq.TLO.Plugin('mq2dannet').IsLoaded() then return false end
    local zone = mq.TLO.Zone.ShortName()
    if zone:find('_') then
        zone = string.format("zone_%s", zone)
    else
        zone = string.format("zone_%s_%s", mq.TLO.EverQuest.Server(), zone)
    end

    local peerName = string.lower(name)
    local peers = mq.TLO.DanNet.Peers(zone)()
    if mq.TLO.DanNet.FullNames() then
        peerName = string.format("%s_%s", mq.TLO.EverQuest.Server(), string.lower(name))
    end
    
    for str in string.gmatch(peers, "([^|]+)") do
        if str == peerName then return true end
    end
    return false
end