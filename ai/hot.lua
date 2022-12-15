---@type Mq
local mq = require('mq')

require('logic')

---@class hot
---@field public Output string # AI Debug String
---@field private hotCooldown number # cooldown timer to use hot
---@field private spawnHotSnapshot number[] # snapshot of spawns that have hots on them and when to reuse
hot = {
    spawnHotSnapshot = {},
    Output = '',
    hotCooldown = 0,
}

---Attempts to cast a hot
---@param elixir elixir
---@returns output string
function hot:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsHotAI then return "hot ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return string.format("on zone cooldown for %d seconds", math.ceil((elixir.ZoneCooldown-mq.gettime())/1000)) end
    if self.hotCooldown and self.hotCooldown > mq.gettime() then return string.format("on hot cooldown for %d seconds", math.ceil((self.hotCooldown-mq.gettime())/1000)) end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Me.Casting.ID() then return string.format("already casting %s", mq.TLO.Me.Casting.Name()) end
    if mq.TLO.Window("Casting").Open() then return "casting window open" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end

    local isFocusCasted, focusOutput = hot:FocusCast(elixir)
    if isFocusCasted then return focusOutput end
    if elixir.Config.IsHotFocus and not elixir.Config.IsHotFocusFallback then return focusOutput end

    local spawnCount, spawnID = MostHurtAlly(elixir.Config.HotPctNormal)
    local spawn = mq.TLO.Spawn(spawnID)
    if not spawn then return "spawn "..spawnID.." not found" end
    if spawn.PctHPs() > elixir.Config.HotPctNormal then return "no one is hurt enough yet, most hurt is "..spawn.Name().." at "..spawn.PctHPs().."%" end
    
    local isCasted = false
    local lastCastOutput = "no heal over times found"
    
    if spawnCount > 2 then
        for i = 1, mq.TLO.Me.NumGems() do
            if elixir.Gems[i].Tag.IsHot and
                elixir.Gems[i].Tag.IsTargetGroup and
                self.spawnHotSnapshot[spawnID] < mq.gettime() and
                not elixir.Gems[i].IsIgnored then
                
                elixir:DebugPrintf("found group hot at gem %d will cast on %d", i, spawnID)
                isCasted, lastCastOutput = hot:CastGem(elixir, spawnID, i)
                elixir.Gems[i].Output = " hot ai: " .. lastCastOutput
                if isCasted then
                    if mq.TLO.Group.GroupSize() then
                        for j = 0, mq.TLO.Group.Members() do
                            local pG = mq.TLO.Group.Member(j)
                            if pG() and
                            pG.Present() and
                            pG.Type() ~= "CORPSE" and
                            pG.Distance() < 200 and
                            not pG.Offline() then
                                self.spawnHotSnapshot[pG.ID] = mq.gettime()+32000                      
                            end
                        end
                    end
                    return lastCastOutput
                end
            end
        end
    end
    for i = 1, mq.TLO.Me.NumGems() do
        if elixir.Gems[i].Tag.IsHot and
        not elixir.Gems[i].Tag.IsTargetGroup and
        (not self.spawnHotSnapshot[spawnID] or self.spawnHotSnapshot[spawnID] < mq.gettime()) and
        not elixir.Gems[i].IsIgnored then
            elixir:DebugPrintf("found hot at gem %d will cast on %d", i, spawnID)
            isCasted, lastCastOutput = hot:CastGem(elixir, spawnID, i)
            elixir.Gems[i].Output = " hot ai: " .. lastCastOutput
            if isCasted then return lastCastOutput end
        end
    end
    return lastCastOutput
end

---Attempts to cast a focus hot gem
---@param elixir elixir
---@returns isSuccess boolean, castOutput string # isSuccess is true if a spell cast succeeded, and output gives context of it
function hot:FocusCast(elixir)
    if not elixir.Config.IsHotFocus then return false, "hot focus not enabled" end
    if not elixir.Config.HotFocusName then return false, "no hot focus set" end
    local spawn = mq.TLO.Spawn("="..elixir.Config.HotFocusName)
    if not spawn() then return false, "focus target "..elixir.Config.HotFocusName.." not found" end
    if spawn.PctHPs() > elixir.Config.HotFocusPctNormal then return false, "focus target "..spawn.Name().." is not hurt enough at "..spawn.PctHPs().."%" end

    local spawnID = spawn.ID()
    local isCasted = false
    local lastCastOutput = "no heal over times found"

    for i = 1, mq.TLO.Me.NumGems() do
        if elixir.Gems[i].Tag.IsHot and
            not elixir.Gems[i].IsIgnored and
            not elixir.Gems[i].Tag.IsTargetGroup and
            (not self.spawnHotSnapshot[spawnID] or self.spawnHotSnapshot[spawnID] < mq.gettime()) and
            (elixir.Config.HotFocusSpellID == elixir.Gems[i].SpellID or
            elixir.Config.HotFocusSpellID == 0)
            then
            elixir:DebugPrintf("found focus hot at gem %d will cast on %d", i, spawnID)
            isCasted, lastCastOutput = hot:CastGem(elixir, spawnID, i)
            if isCasted then
                if not elixir.Config.IsHotFocusFallback then
                    -- only append hot ai logic from focus if the fallback flag is disabled
                    elixir.Gems[i].Output = " hot ai: " .. lastCastOutput
                end
                return isCasted, lastCastOutput
            end
        end
    end
    return false, lastCastOutput
end

---Attempts to cast a hot gem
---@param elixir elixir
---@param targetSpawnID number
---@param gemIndex number
---@returns isSuccess boolean, castOutput string
function hot:CastGem(elixir, targetSpawnID, gemIndex)
    local spell = mq.TLO.Me.Gem(gemIndex)
    if not mq.TLO.Me.SpellReady(gemIndex)() then return false, spell.Name().." not ready" end
    if not spell() then return false, "no spell found" end
    if spell.Mana() > mq.TLO.Me.CurrentMana() then return false, "not enough mana (" .. mq.TLO.Me.CurrentMana() .. "/" .. spell.Mana() .. ")" end

    if mq.TLO.Spawn(targetSpawnID).Distance() > spell.Range() then return false, "target too far away" end

    self.hotCooldown = mq.gettime() + 1000
    elixir.LastActionOutput = string.format("hot ai casting %s on %s", spell.Name(), mq.TLO.Spawn(targetSpawnID).Name())
    elixir.isActionCompleted = true
    mq.cmd(string.format("/casting \"%s\" -targetid|%d -maxtries|2", spell.Name(), targetSpawnID))
    self.spawnHotSnapshot[targetSpawnID] = mq.gettime() + 32000
    --mq.delay(5000, WaitOnCasting)
    return true, elixir.LastActionOutput
end

return hot