---@type Mq
local mq = require('mq')

---Checks if a player is poisoned
---@param spawnID number
---@returns IsPoisoned boolean # Returns true when a spawn appears poisoned
function IsPCPoisoned(spawnID)
    local spawn = mq.TLO.Spawn(spawnID)
    if not spawn() then return false end
    if spawn.Type() ~= "PC" then return false end

    if IsPCDannet(spawn.Name()) then
        if not mq.TLO.DanNet(spawn.Name()).ObserveSet("Me.IsPoisoned") then
            mq.cmdf('/dobserve %s -q "%s"', spawn.Name(), "Me.IsPoisoned")
        end
        return mq.TLO.DanNet(spawn.Name()).Observe("Me.IsPoisoned")() == 'TRUE'
    end

    if IsPCNetbots(spawn.Name()) then
        return mq.TLO.NetBots(spawn.Name()).Poisoned() > 0
    end

    if spawn.Buff(0)() and
    spawn.Buff(0).Staleness() < 60000 then
        local buff = spawn.FindBuff("spa poison")
        return buff ~= nil and buff.ID() and not buff.Beneficial()
    end
    return false
end