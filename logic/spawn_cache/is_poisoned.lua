---@type Mq
local mq = require('mq')

---Checks various locations for a spawn's state
---@param spawnID number
---@returns IsPoisoned boolean # Returns true when a spawn appears poisoned
function IsSpawnPoisoned(spawnID)
    local spawn = mq.TLO.Spawn(spawnID)
    if not spawn() then return false end
    if spawn.Type() ~= "PC" then return false end

    local spawnEntry = SpawnCache(spawn.Name())
    if spawnEntry.Source == 'netbots' then
        spawnEntry.IsPoisoned = mq.TLO.NetBots(spawn.Name()).Poisoned() > 0
    end
    if spawnEntry.Source == 'dannet' and
    not mq.TLO.DanNet(spawn.Name()).ObserveSet("Me.IsPoisoned") then
        mq.cmdf('/dobserve %s -q "%s"', spawn.Name(), "Me.IsPoisoned")
        spawnEntry.IsPoisoned = mq.TLO.DanNet(spawn.Name()).Observe("Me.IsPoisoned")() == 'TRUE'
    end
    if spawnEntry.Source == 'none' and
    spawn.Buff(0)() and spawn.Buff(0).Staleness() < 60000 then
        local buff = spawn.FindBuff("spa poison")
        spawnEntry.IsPoisoned = buff ~= nil and buff.ID() and not buff.Beneficial()
    end

    SetSpawnCache(spawn.Name(), spawnEntry)
    return spawnEntry.IsPoisoned
end