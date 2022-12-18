---@type Mq
local mq = require('mq')

---Checks if a player is cursed
---@param spawnID number
---@returns IsCursed boolean # Returns true when a spawn appears cursed
function IsPCCursed(spawnID)
    local spawn = mq.TLO.Spawn(spawnID)
    if not spawn() then return false end
    if spawn.Type() ~= "PC" then return false end
    if mq.TLO.Target() and mq.TLO.Target.ID() == spawnID and mq.TLO.Target.BuffsPopulated() then
        local buff = spawn.FindBuff("spa curse")
        return buff ~= nil and buff.ID() and not buff.Beneficial()
    end
    if IsPCDannet(spawn.Name()) then
        --if not mq.TLO.DanNet(spawn.Name()).ObserveSet("Me.Cursed.ID") then
        local curseID = mq.TLO.DanNet(spawn.Name()).Observe("Me.Cursed.ID")()
        if curseID == nil then
            mq.cmdf('/dobserve %s -q "%s"', spawn.Name(), "Me.Cursed.ID")
            return false
        end
        return curseID ~= 'NULL'
    end

    if IsPCNetbots(spawn.Name()) then
        return mq.TLO.NetBots(spawn.Name()).Cursed() > 0
    end

    if spawn.Buff(0)() and
    spawn.Buff(0).Staleness() < 60000 then
        local buff = spawn.FindBuff("spa curse")
        return buff ~= nil and buff.ID() and not buff.Beneficial()
    end
    return false
end