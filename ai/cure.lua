---@type Mq
local mq = require('mq')

require('logic')

---@class cure
---@field public Output string # AI Debug String
---@field public IsCureNormalSoundValid boolean # is cure normal a valid sound
---@field private cureCooldown number # cooldown timer to use cure
cure = {
    Output = '',
    cureCooldown = 0,
    IsCureNormalSoundValid = false,
}

---Attempts to cast a cure
---@param elixir elixir
---@returns output string
function cure:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsCureAI then return "cure ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return string.format("on zone cooldown for %d seconds", math.ceil((elixir.ZoneCooldown-mq.gettime())/1000)) end
    if self.cureCooldown and self.cureCooldown > mq.gettime() then return string.format("on cure cooldown for %d seconds", math.ceil((self.cureCooldown-mq.gettime())/1000)) end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Me.Casting.ID() then return string.format("already casting %s", mq.TLO.Me.Casting.Name()) end
    if mq.TLO.Window("Casting").Open() then return "casting window open" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end

    local isCasted = false
    local lastCastOutput = "no cures found"

    isCasted, lastCastOutput = self:Cure(elixir, mq.TLO.Me.ID())
    if isCasted then return lastCastOutput end

    if mq.TLO.Group.GroupSize() then
        for i = 0, mq.TLO.Group.Members() do
            local pG = mq.TLO.Group.Member(i)
            if pG() and
            pG.Present() and
            pG.Type() ~= "CORPSE" and
            pG.Distance() < 200 and
            not pG.Offline() then
                isCasted, lastCastOutput = self:Cure(elixir, pG.ID())
                if isCasted then return lastCastOutput end
            end
        end
    end

    if elixir.Config.IsCureRaid and
    mq.TLO.Raid.Members() then
        for i = 0, mq.TLO.Raid.Members() do
            local pR = mq.TLO.Raid.Member(i)
            if pR() and            
            pR.Type() ~= "CORPSE" and
            pR.Distance() < 200 then
                isCasted, lastCastOutput = self:Cure(elixir, pR.ID())
                if isCasted then return lastCastOutput end
            end
        end
    end

    if elixir.Config.IsCureXTarget and
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
                isCasted, lastCastOutput = self:Cure(elixir, xt.ID())
                if isCasted then return lastCastOutput end
            end
        end
    end
    return lastCastOutput
end

--- Attempts to cure target
---@param elixir elixir
---@param spawnID number
---@returns isSuccess boolean, castOutput string
function cure:Cure(elixir, spawnID)
    local spawn = mq.TLO.Spawn(spawnID)
    if spawn.Buff(0)() and spawn.Buff(0).Staleness() > 60000 then return false, spawn.Name() .. " too stale" end

    local buff = spawn.FindBuff("spa DISEASE")
    local isDiseased = buff ~= nil and buff.ID() and not buff.Beneficial()
    buff = spawn.FindBuff("spa POISON")
    local isPoisoned = IsPCPoisoned(spawnID)
    buff = spawn.FindBuff("spa CURSE")
    local isCursed = buff ~= nil and buff.ID() and not buff.Beneficial()
    if not isDiseased and
    not isPoisoned and
    not isCursed then
        return false, "no cure needed"
    end

    local isCasted = false
    local lastCastOutput = ""

    
    local aaName = "Radiant Cure"
    local altAbility = mq.TLO.Me.AltAbility(aaName)
    --local altAbility = 
    if mq.TLO.Me.AltAbilityReady(aaName)() then
        if mq.TLO.Me.Casting.ID() and mq.TLO.Me.Casting.ID() ~= altAbility.ID() then
            mq.cmd("/stopcast")
            mq.delay(500)
        end

        mq.cmdf("/alt act %d", altAbility.ID())
        if self.IsCureNormalSoundValid then
            mq.cmdf("/beep %s/elixir/%s", mq.configDir, elixir.Config.CureNormalSound)
        end
        elixir.LastActionOutput = string.format("cure ai emergency using AA %s on %s", aaName, spawn.Name())
        return true, elixir.LastActionOutput
    end

    for i = 1, mq.TLO.Me.NumGems() do
        if ((elixir.Gems[i].Tag.IsCureDisease and isDiseased) or
        (elixir.Gems[i].Tag.IsCurePoison and isPoisoned) or
        (elixir.Gems[i].Tag.IsCureCurse and isCursed)) and
        not elixir.Gems[i].IsIgnored then
            elixir:DebugPrintf("found cure at gem %d will cast on %d", i, spawnID)
            isCasted, lastCastOutput = cure:CastGem(elixir, spawnID, i)
            if isCasted then
                if self.IsCureNormalSoundValid then
                    mq.cmdf("/beep %s/elixir/%s", mq.configDir, elixir.Config.CureNormalSound)
                end
                return isCasted, lastCastOutput
            end
        end
    end
    return false, "no cure spells found"
end

---Attempts to cast a cure gem
---@param elixir elixir
---@param spawnID number
---@param gemIndex number
---@returns isSuccess boolean, castOutput string
function cure:CastGem(elixir, spawnID, gemIndex)
    local spell = mq.TLO.Me.Gem(gemIndex)
    if not mq.TLO.Me.SpellReady(gemIndex)() then return false, spell.Name().." not ready" end
    if not spell() then return false, "no spell found" end
    if spell.Mana() > mq.TLO.Me.CurrentMana() then return false, "not enough mana (" .. mq.TLO.Me.CurrentMana() .. "/" .. spell.Mana() .. ")" end

    if mq.TLO.Spawn(spawnID).Distance() > spell.Range() then return false, "target too far away" end

    self.cureCooldown = mq.gettime() + 1000
    elixir.LastActionOutput = string.format("cure ai casting %s on %s", spell.Name(), mq.TLO.Spawn(spawnID).Name())
    elixir.isActionCompleted = true
    if not mq.TLO.Target() or mq.TLO.Target.ID() ~= spawnID then
        mq.cmdf('/target id %d', spawnID)
    end
    mq.cmdf("/cast %d", gemIndex)
    elixir.LastSpellTargetID = spawnID
    elixir.LastSpellID = spell.ID()
    --mq.delay(5000, WaitOnCasting)
    return true, elixir.LastActionOutput
end

return cure