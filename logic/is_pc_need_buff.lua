---@type Mq
local mq = require('mq')

---Checks if a player is buffed with spellID provided
---@param spawnID number
---@param spellID number # spell of buff to inspect
---@returns IsBuffed boolean # Returns true when buff won't land on target
function IsPCNeedBuff(spawnID, spellID)
    local spawn = mq.TLO.Spawn(spawnID)
    if not spawn() then return false end
    if spawn.Type() ~= "PC" then return false end
    if mq.TLO.Target() and mq.TLO.Target.ID() == spawnID and mq.TLO.Target.BuffsPopulated() then
        return mq.TLO.Spell(spellID).StacksTarget() and not mq.TLO.Target.Buff(mq.TLO.Spell(spellID).Name())
    end

    if IsPCDannet(spawn.Name()) then
        local parse = string.format("Spell[%d].Stacks", spellID)
        --if not mq.TLO.DanNet(spawn.Name()).ObserveSet("Me.Buffed.ID") then
        local isStacking = mq.TLO.DanNet(spawn.Name()).Observe(parse)()
        if isStacking == nil then
            mq.cmdf('/dobserve %s -q "%s"', spawn.Name(), parse)
            return false
        end
        if isStacking ~= 'TRUE' then return false end
        parse = string.format("Me.Buff[%s].ID", mq.TLO.Spell(spellID).Name())
        --if not mq.TLO.DanNet(spawn.Name()).ObserveSet("Me.Buffed.ID") then
        local isExisting = mq.TLO.DanNet(spawn.Name()).Observe(parse)()
        if isExisting == nil then
            mq.cmdf('/dobserve %s -q "%s"', spawn.Name(), parse)
            return false
        end
        return isExisting == 'NULL'
    end

    if IsPCNetbots(spawn.Name()) then
        return mq.TLO.NetBots(spawn.Name()).Stacks(spellID)
    end

    if spawn.Buff(0)() and
    spawn.Buff(0).Staleness() < 60000 then
        return spawn.Buff().WillStack(mq.TLO.Spell(spellID).Name())
    end
    return false
end