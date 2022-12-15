---@type Mq
local mq = require('mq')

require('logic')

---@class heal
---@field public Output string # AI Debug String
---@field public IsHealNormalSoundValid boolean # Is the heal normal sound a valid one?
---@field public IsHealEmergencySoundValid boolean # Is the heal emergency sound a valid one?
---@field public IsHealfocusNormalSoundValid boolean # Is the heal normal sound a valid one?
---@field public IsHealFocusEmergencySoundValid boolean # Is the heal emergency sound a valid one?
---@field public FocusName string # used to cache what is current focus, based on FocusID, refreshed in elixir:Reset
---@field private healCooldown number # cooldown timer to use heal
---@field private spawnSnapshot number[] # snapshot of spawn HPs for predictive healing
heal = {
    spawnSnapshot = {},
    Output = '',
    healCooldown = 0,
    HealFocusName = 'None',
}

---Attempts to cast a heal
---@param elixir elixir
---@returns output string
function heal:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsHealAI then return "heal ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return string.format("on zone cooldown for %d seconds", math.ceil((elixir.ZoneCooldown-mq.gettime())/1000)) end
    if self.healCooldown and self.healCooldown > mq.gettime() then string.format("on heal cooldown for %d seconds", math.ceil((self.healCooldown-mq.gettime())/1000)) end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Window("Casting").Open() then return "casting window open" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end

    local isFocusCasted, focusOutput = heal:FocusCast(elixir)
    if isFocusCasted then return focusOutput end
    if elixir.Config.IsHealFocus and not elixir.Config.IsHealFocusFallback then return focusOutput end

    local spawnCount, spawnID = MostHurtAlly(elixir.Config.HealPctNormal)
    local spawn = mq.TLO.Spawn(spawnID)
    if not spawn then return "spawn "..spawnID.." not found" end
    if spawn.PctHPs() > elixir.Config.HealPctNormal then return "no one is hurt enough yet, most hurt is "..spawn.Name().." at "..spawn.PctHPs().."%" end
    
    local isCasted = false
    local lastCastOutput = "no healing ability found"
    local isEmergency = false
    if elixir.Config.IsHealEmergencyAllowed then
        if spawn.PctHPs() <= elixir.Config.HealPctEmergency then
            isEmergency = true
        end
        if elixir.Config.IsHealEmergencyPredictive and
         self.spawnSnapshot[spawnID] and
         self.spawnSnapshot[spawnID] >= spawn.PctHPs()+40 then
            isEmergency = true
        end
    end

    if isEmergency then
        isCasted, lastCastOutput = self:EmergencyCast(elixir, spawnID)
        if isCasted then return focusOutput end
    end

    self:snapshotAlliesPctHPs()
    
    if mq.TLO.Me.Casting.ID() then
        local isHeal = false
        for i = 1, mq.TLO.Me.NumGems() do
            if elixir.Gems[i].SpellID == mq.TLO.Me.Casting.ID() and
            elixir.Gems[i].Tag.IsHeal then
                isHeal = true
            end
        end
        if isHeal then return string.format("already casting heal %s", mq.TLO.Me.Casting.Name()) end
    end
    
    if elixir.Config.IsHealSubtleCasting and mq.TLO.Me.Grouped() and IsMeHighAggro() and not isEmergency then
        return "subtle casting enabled and currently high hate"
    end

    -- try a group heal first if more than 2 players need heals
    if spawnCount > 2 then
        for i = 1, mq.TLO.Me.NumGems() do
            if elixir.Gems[i].Tag.IsHeal and
                elixir.Gems[i].Tag.IsTargetGroup and
                (not elixir.Gems[i].Tag.IsNuke or elixir.TargetAI.IsTargetAttackable) and -- lifetap check
                not elixir.Gems[i].IsIgnored then
                
                elixir:DebugPrintf("found group heal at gem %d will cast on %d (%d total allies need heal)", i, spawnID, spawnCount)
                isCasted, lastCastOutput = heal:CastGem(elixir, spawnID, i)
                elixir.Gems[i].Output = " heal ai: " .. lastCastOutput
                if self.IsHealNormalSoundValid then
                    mq.cmdf("/beep %s\\elixir\\%s", mq.configDir, elixir.Config.HealNormalSound)
                end
                return lastCastOutput
            end
        end
    end

    
    for i = 1, mq.TLO.Me.NumGems() do
        if elixir.Gems[i].Tag.IsHeal and
            (not elixir.Gems[i].Tag.IsNuke or elixir.TargetAI.IsTargetAttackable) and -- lifetap check
            not elixir.Gems[i].IsIgnored then
            
            elixir:DebugPrintf("found heal at gem %d will cast on %d", i, spawnID)
            isCasted, lastCastOutput = heal:CastGem(elixir, spawnID, i)
            elixir.Gems[i].Output = " heal ai: " .. lastCastOutput
            if isCasted then
                if self.IsHealNormalSoundValid then
                    mq.cmdf("/beep %s/elixir/%s", mq.configDir, elixir.Config.HealNormalSound)
                end
                return lastCastOutput
            end
        end
    end
    return lastCastOutput
end

---Attempts to cast a focus heal gem
---@param elixir elixir
---@returns isSuccess boolean, castOutput string # isSuccess is true if a spell cast succeeded, and output gives context of it
function heal:FocusCast(elixir)
    if not elixir.Config.IsHealFocus then return false, "heal focus not enabled" end
    if not elixir.Config.HealFocusName then return false, "no heal focus set" end
    local spawn = mq.TLO.Spawn("="..elixir.Config.HealFocusName)
    if not spawn() then return false, "focus target "..elixir.Config.HealFocusName.." not found" end
    if spawn.PctHPs() > elixir.Config.HealFocusPctNormal then return false, "focus target "..spawn.Name().." is not hurt enough at "..spawn.PctHPs().."%" end

    local spawnID = spawn.ID()
    local isCasted = false
    local lastCastOutput = "no healing ability found"
    local isEmergency = false

    if elixir.Config.IsHealFocusEmergencyAllowed then
        if spawn.PctHPs() <= elixir.Config.HealFocusPctEmergency then
            isEmergency = true
        end
        if elixir.Config.IsHealFocusEmergencyPredictive and
         self.spawnSnapshot[spawnID] and
         self.spawnSnapshot[spawnID] >= spawn.PctHPs()+40 then
            isEmergency = true
        end
    end

    if isEmergency then
        isCasted, lastCastOutput = self:EmergencyCast(elixir, spawnID)
        if isCasted then
            self:snapshotAlliesPctHPs()
            return true, lastCastOutput
        end

    end

    if elixir.Config.IsHealSubtleCasting and mq.TLO.Me.Grouped() and IsMeHighAggro() and not isEmergency then
        return false, "subtle casting enabled and currently high hate"
    end

    for i = 1, mq.TLO.Me.NumGems() do
        if elixir.Gems[i].Tag.IsHeal and
            (not elixir.Gems[i].Tag.IsNuke or elixir.TargetAI.IsTargetAttackable) and -- lifetap check
            not elixir.Gems[i].IsIgnored and
            (elixir.Config.HealFocusSpellID == elixir.Gems[i].SpellID or
            elixir.Config.HealFocusSpellID == 0)
            then
            elixir:DebugPrintf("found focus heal at gem %d will cast on %d", i, spawnID)
            isCasted, lastCastOutput = heal:CastGem(elixir, spawnID, i)
            if isCasted then
                if not elixir.Config.IsHealFocusFallback then
                    -- only append heal ai logic from focus if the fallback flag is disabled
                    elixir.Gems[i].Output = " heal ai: " .. lastCastOutput
                end
                self:snapshotAlliesPctHPs()
                if self.IsHealNormalSoundValid then
                    mq.cmdf("/beep %s/elixir/%s", mq.configDir, elixir.Config.HealNormalSound)
                end
                return isCasted, lastCastOutput
            end
        end
    end
    return false, lastCastOutput
end

---Attempts to cast a focus heal gem
---@param elixir elixir
---@param spawnID number
---@returns isSuccess boolean, castOutput string # isSuccess is true if a spell cast succeeded, and output gives context of it
function heal:EmergencyCast(elixir, spawnID)
    local spawn = mq.TLO.Spawn(spawnID)
    if not spawn then return false, "spawn "..spawnID.." not found" end
    print("emergency situation detected")
    
    local aaName = "Divine Arbitration"
    if mq.TLO.Me.AltAbilityReady(aaName)() and
    mq.TLO.Me.AltAbility(aaName).Spell.Range() <= spawn.Distance() then
        if mq.TLO.Me.Casting.ID() then
            mq.cmd("/stopcast")
            mq.delay(500)
        end
        mq.cmd(string.format("/casting \"%s\"", aaName))
        elixir.LastActionOutput = string.format("heal ai emergency casting %s on %s", aaName, spawn.Name())
        return true, elixir.LastActionOutput
    end

    local aaName = "Celestial Regeneration"
    if mq.TLO.Me.AltAbilityReady(aaName)() and
    mq.TLO.Me.AltAbility(aaName).Spell.Range() <= spawn.Distance() then
        if mq.TLO.Me.Casting.ID() then
            mq.cmd("/stopcast")
            mq.delay(500)
        end
        mq.cmd(string.format("/casting \"%s\"", aaName))
        elixir.LastActionOutput = string.format("heal ai emergency casting %s on %s", aaName, spawn.Name())
        return true, elixir.LastActionOutput
    end

    local isCasted = false
    local lastCastOutput = "no emergency heal found"
    for i = 1, mq.TLO.Me.NumGems() do
        if elixir.Gems[i].Tag.IsHeal and
            (not elixir.Gems[i].Tag.IsNuke or elixir.TargetAI.IsTargetAttackable) and -- lifetap check
            not elixir.Gems[i].IsIgnored and
            mq.TLO.Me.SpellReady(i)() then
            
            local spell = mq.TLO.Me.Gem(i)
            if spell() and spell.Mana() > mq.TLO.Me.CurrentMana() and
                spell.CastTime.Seconds() <= 3 then
                
                elixir:DebugPrintf("found emergency heal at gem %d will cast on %d", i, spawnID)
                isCasted, lastCastOutput = heal:CastGem(elixir, spawnID, i)
                if isCasted then
                    if not elixir.Config.IsHealFocusFallback then
                        -- only append heal ai logic from focus if the fallback flag is disabled
                        elixir.Gems[i].Output = " heal ai: " .. lastCastOutput
                    end
                    if self.IsHealEmergencySoundValid then
                        mq.cmdf("/beep %s/elixir/%s", mq.configDir, elixir.Config.HealEmergencySound)
                    end
                    return isCasted, lastCastOutput
                end
            end
        end
    end
    return false, lastCastOutput
end

---Attempts to cast a heal gem
---@param elixir elixir
---@param targetSpawnID number
---@param gemIndex number
---@returns isSuccess boolean, castOutput string
function heal:CastGem(elixir, targetSpawnID, gemIndex)
    local spell = mq.TLO.Me.Gem(gemIndex)
    if not mq.TLO.Me.SpellReady(gemIndex)() then return false, spell.Name().." not ready" end
    if not spell() then return false, "no spell found" end
    if spell.Mana() > mq.TLO.Me.CurrentMana() then return false, "not enough mana (" .. mq.TLO.Me.CurrentMana() .. "/" .. spell.Mana() .. ")" end

    if mq.TLO.Spawn(targetSpawnID).Distance() > spell.Range() then return false, "target too far away" end

    self.healCooldown = mq.gettime() + 1000
    elixir.LastActionOutput = string.format("heal ai casting %s on %s", spell.Name(), mq.TLO.Spawn(targetSpawnID).Name())
    elixir.isActionCompleted = true

    -- Heals are special and will cancel non-heals (checked earlier)
    if mq.TLO.Me.Casting.ID() then
        mq.cmd("/stopcast")
        mq.delay(500)
    end

    if not mq.TLO.Target() or mq.TLO.Target.ID() ~= targetSpawnID then
        mq.cmdf('/target id %d', targetSpawnID)
    end
    mq.cmdf("/cast %d", gemIndex)
    --mq.cmd(string.format("/casting \"%s\" -targetid|%d -maxtries|2", spell.Name(), targetSpawnID))    
    --mq.delay(5000, WaitOnCasting)
    return true, elixir.LastActionOutput
end

---take a snapshot of all allies HP for reference in emergency situations
function heal:snapshotAlliesPctHPs()

    self.spawnSnapshot[mq.TLO.Me.ID()] = mq.TLO.Me.PctHPs()

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
                pSpawn.Pet() and
                pSpawn.Distance() < 200 then
                    self.spawnSnapshot[pSpawn.Pet.ID()] = pSpawn.Pet.PctHPs()
                end

                self.spawnSnapshot[pSpawn.ID()] = pSpawn.PctHPs()
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
                pSpawn.Pet.ID() > 0 and
                pSpawn.Pet.Distance() < 200 then
                    self.spawnSnapshot[pSpawn.Pet.ID()] = pSpawn.Pet.PctHPs()
                end
                self.spawnSnapshot[pSpawn.ID()] = pSpawn.PctHPs()
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
                self.spawnSnapshot[xt.ID()] = xt.PctHPs()
            end
        end
    end
end

return heal