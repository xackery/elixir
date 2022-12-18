---@type Mq
local mq = require('mq')

---Checks if a player is poisoned
---@param spawnID number
---@returns IsPoisoned boolean # Returns true when a spawn appears poisoned
function IsPCPoisoned(spawnID)
    local spawn = mq.TLO.Spawn(spawnID)
    if not spawn() then return false end
    if spawn.Type() ~= "PC" then return false end

    if mq.TLO.Target() and mq.TLO.Target.ID() == spawnID and mq.TLO.Target.BuffsPopulated() then
        local buff = spawn.FindBuff("spa poison")
        return buff ~= nil and buff.ID() and not buff.Beneficial()
    end
    if IsPCDannet(spawn.Name()) then
        --if not mq.TLO.DanNet(spawn.Name()).ObserveSet("Me.Poisoned.ID") then
        local poisonID = mq.TLO.DanNet(spawn.Name()).Observe("Me.Poisoned.ID")()
        if poisonID == nil then
            mq.cmdf('/dobserve %s -q "%s"', spawn.Name(), "Me.Poisoned.ID")
            return false
        end
        return poisonID ~= 'NULL'
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