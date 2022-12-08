---@type Mq
local mq = require('mq')

---Attempts to find the most hurt ally
---@returns spawnID number # spawn ID of heal target
function MostHurtAlly()
    local spawnPctHPs = 101
    local finalSpawnID = 0

    if mq.TLO.Me.PctHPs() < spawnPctHPs then
        spawnPctHPs = mq.TLO.Me.PctHPs()
        finalSpawnID = mq.TLO.Me.ID()
    end

    if mq.TLO.Group.GroupSize() then
        for i = 0, mq.TLO.Group.Members() do
            local pG = mq.TLO.Group.Member(i)
            if pG() and
            pG.Type() ~= "CORPSE" and
            pG.Distance() < 150 and      
            not pG.Offline() then      
                local pSpawn = pG.Spawn
                if elixir.config.IsHealAIPets and
                pSpawn.Pet() and
                pSpawn.Distance() < 150 and
                pSpawn.PctHPs() < spawnPctHPs then
                    spawnPctHPs = pSpawn.Pet.PctHPs()
                    finalSpawnID = pSpawn.Pet.ID()
                end
                if pSpawn.PctHPs() < spawnPctHPs then
                    spawnPctHPs = pSpawn.PctHPs()
                    finalSpawnID = pSpawn.ID()
                end
            end
        end
    end

    if elixir.Config.IsHealAIRaid and
    mq.TLO.Raid.Members() then
        for i = 0, mq.TLO.Raid.Members() do
            local pR = mq.TLO.Raid.Member(i)
            if pR() and
            pR.Type() ~= "CORPSE" and
            pR.Distance() < 150 then
                local pSpawn = pR.Spawn
                if elixir.config.IsHealAIPets and
                pSpawn.Pet() and
                pSpawn.Pet.Distance() < 150 and
                pSpawn.Pet.PctHPs() < spawnPctHPs then
                    spawnPctHPs = pSpawn.Pet.PctHPs()
                    finalSpawnID = pSpawn.Pet.ID()
                end
                if pSpawn.PctHPs() < spawnPctHPs then
                    spawnPctHPs = pSpawn.PctHPs()
                    finalSpawnID = pSpawn.ID()
                end
            end
        end
    end
    if elixir.Config.IsHealAIXTarget and
    mq.TLO.Me.XTarget() then
        for i = 0, mq.TLO.Me.XTarget() do
            local xt = mq.TLO.Me.XTarget(i)
            if xt() and
            xt.TargetType() == 2 and
            xt.Type() ~= "CORPSE" and
            xt.Distance() < 150 and
            xt.PctHPs() > spawnPctHPs then
                spawnPctHPs = xt.PctHPs()
                finalSpawnID = xt.ID()
            end
        end
    end
    return finalSpawnID
end