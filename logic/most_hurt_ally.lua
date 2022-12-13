---@type Mq
local mq = require('mq')

---Attempts to find the most hurt ally
---@param threshold number # % threshold to be considered hurt
---@returns spawnCount number, spawnID number # spawn ID of heal target
function MostHurtAlly(threshold)
    local spawnPctHPs = 101
    local finalSpawnID = 0
    local spawnCount  = 0

    if mq.TLO.Me.PctHPs() < threshold then spawnCount = spawnCount + 1 end
    if mq.TLO.Me.PctHPs() < spawnPctHPs then
        spawnPctHPs = mq.TLO.Me.PctHPs()
        finalSpawnID = mq.TLO.Me.ID()
    end

    if mq.TLO.Group.GroupSize() then
        for i = 0, mq.TLO.Group.Members() do
            local pG = mq.TLO.Group.Member(i)
            if pG() and
            pG.Present() and
            pG.Type() ~= "CORPSE" and
            pG.Distance() < 200 and
            not pG.Offline() then
                local pSpawn = pG.Spawn
                if elixir.Config.IsHealPets and
                pSpawn() and
                pSpawn.Pet() and
                pSpawn.Pet.ID() > 0 and
                pSpawn.Distance() < 200 then
                    if pSpawn.Pet.PctHPs() < threshold then spawnCount = spawnCount + 1 end
                    if pSpawn.Pet.PctHPs() < spawnPctHPs then
                        spawnPctHPs = pSpawn.Pet.PctHPs()
                        finalSpawnID = pSpawn.Pet.ID()
                    end
                end
                if pSpawn() and pSpawn.PctHPs() < threshold then spawnCount = spawnCount + 1 end
                if pSpawn() and pSpawn.PctHPs() < spawnPctHPs then
                    spawnPctHPs = pSpawn.PctHPs()
                    finalSpawnID = pSpawn.ID()
                end
            end
        end
    end

    if elixir.Config.IsHealRaid and
    mq.TLO.Raid.Members() then
        for i = 0, mq.TLO.Raid.Members() do
            local pR = mq.TLO.Raid.Member(i)
            if pR() and
            pR.Type() ~= "CORPSE" and
            pR.Distance() < 200 then
                local pSpawn = pR.Spawn
                if elixir.Config.IsHealPets and
                pSpawn.Pet() and
                pSpawn.Pet.Distance() < 200 then
                    if pSpawn.Pet.PctHPs() < threshold then spawnCount = spawnCount + 1 end
                    if pSpawn.Pet.PctHPs() < spawnPctHPs then
                        spawnPctHPs = pSpawn.Pet.PctHPs()
                        finalSpawnID = pSpawn.Pet.ID()
                    end
                end
                if pSpawn.PctHPs() < threshold then spawnCount = spawnCount + 1 end
                if pSpawn.PctHPs() < spawnPctHPs then
                    spawnPctHPs = pSpawn.PctHPs()
                    finalSpawnID = pSpawn.ID()
                end
            end
        end
    end
    if elixir.Config.IsHealXTarget and
    mq.TLO.Me.XTarget() then
        for i = 0, mq.TLO.Me.XTarget() do
            local xt = mq.TLO.Me.XTarget(i)
            if xt() and
            (xt.TargetType() == "Specific PC" or
            xt.TargetType() == "Raid Assist 1" or
            xt.TargetType() == "Raid Assist 2" or
            xt.TargetType() == "Raid Assist 3") and
            xt.Type() ~= "CORPSE" and
            xt.Distance() < 200 then
                if xt.PctHPs() <= threshold then spawnCount = spawnCount+1 end
                if xt.PctHPs() < spawnPctHPs then
                    spawnPctHPs = xt.PctHPs()
                    finalSpawnID = xt.ID()
                end
            end
        end
    end
    return spawnCount, finalSpawnID
end