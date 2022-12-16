---@type Mq
local mq = require('mq')

---@class buff
---@field public Output string # AI Debug String
---@field private buffCooldown number # cooldown between buffing
buff = {
    Output = '',
    buffCooldown = 0
}

---Attempts to cast a buff spell
---@param elixir elixir
---@returns output string # cast attempt result
function buff:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsBuffAI then return "buff ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return string.format("on zone cooldown for %d seconds", math.ceil((elixir.ZoneCooldown-mq.gettime())/1000)) end
    if self.buffCooldown and self.buffCooldown > mq.gettime() then string.format("on buff cooldown for %d seconds", math.ceil((self.buffCooldown-mq.gettime())/1000)) end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Me.Casting.ID() then return string.format("already casting %s", mq.TLO.Me.Casting.Name()) end
    if mq.TLO.Window("Casting").Open() then return "casting window open" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end

    local isCasted = false
    local lastCastOutput = "no buffs needed to be casted"

    if elixir.Config.IsBuffSubtleCasting and mq.TLO.Me.Grouped() and mq.TLO.Me.PctAggro() > 80 then
        return string.format("subtle casting enabled and currently high hate %d%%", mq.TLO.Me.PctAggro())
    end

    local isBuffMemorized = false
    local isBuffSelfOnly = true
    for i = 1, mq.TLO.Me.NumGems() do
        if elixir.Gems[i].Tag.IsBuff and
            not elixir.Gems[i].IsIgnored then
            isBuffMemorized = true
            if not elixir.Gems[i].Tag.IsTargetSelf then isBuffSelfOnly = false end
        end
    end

    if not isBuffMemorized then return "no buffs memorized and not ignored" end
    
    -- For buffs, let's start with ourselves and iterate all valid targets
    isCasted, lastCastOutput = self:Buff(elixir, mq.TLO.Me.ID())
    if isCasted then return lastCastOutput end

    if not isBuffSelfOnly and
    mq.TLO.Group.GroupSize() then
        for i = 0, mq.TLO.Group.Members() do
            local pG = mq.TLO.Group.Member(i)
            if pG() and
            pG.Present() and
            pG.Type() ~= "CORPSE" and
            pG.Distance() < 200 and
            not pG.Offline() then
                isCasted, lastCastOutput = self:Buff(elixir, pG.ID())
                if isCasted then return lastCastOutput end
                if elixir.Config.IsBuffPets and
                pG.Pet() and
                pG.Pet.ID() > 0 and
                pG.Distance() < 200 then
                    isCasted, lastCastOutput = self:Buff(elixir, pG.ID())
                    if isCasted then return lastCastOutput end
                end
            end
        end
    end

    if not isBuffSelfOnly and
    elixir.Config.IsBuffRaid and
    mq.TLO.Raid.Members() then
        for i = 0, mq.TLO.Raid.Members() do
            local pR = mq.TLO.Raid.Member(i)
            if pR() and            
            pR.Type() ~= "CORPSE" and
            pR.Distance() < 200 then
                isCasted, lastCastOutput = self:Buff(elixir, pR.ID())
                if isCasted then return lastCastOutput end
            end
        end
    end

    if not isBuffSelfOnly and
    elixir.Config.IsBuffXTarget and
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
                isCasted, lastCastOutput = self:Buff(elixir, xt.ID())
                if isCasted then return lastCastOutput end
            end
        end
    end

    return lastCastOutput
end

--- Attempts to buff target
---@param elixir elixir
---@param spawnID number
---@returns isSuccess boolean, castOutput string
function buff:Buff(elixir, spawnID)
    local spawn = mq.TLO.Spawn(spawnID)
    if spawn.Buff(0)() and spawn.Buff(0).Staleness() > 60000 then return false, spawn.Name() .. " too stale" end

    local isCasted = false
    local lastCastOutput = ""
    for i = 1, mq.TLO.Me.NumGems() do
        if elixir.Gems[i].Tag.IsBuff and
        (not elixir.Gems[i].Tag.IsTargetSelf or spawn.ID() == mq.TLO.Me.ID()) and
        not elixir.Gems[i].IsIgnored then
            isCasted, lastCastOutput = buff:CastGem(elixir, spawnID, i)
            elixir.Gems[i].Output = " buff ai: " .. lastCastOutput
            if isCasted then
                elixir:DebugPrintf("found buff at gem %d will cast on %s (%d)", i, spawn.Name(), spawnID)
                return isCasted, lastCastOutput
            end
        end
    end
    return false, "no buff spells found"
end


---Attempts to cast a buff gem
---@param elixir elixir
---@param spawnID number
---@param gemIndex number
---@returns isSuccess boolean, castOutput string
function buff:CastGem(elixir, spawnID, gemIndex)

    local spellTag = elixir.Gems[gemIndex].Tag
    local spell = mq.TLO.Me.Gem(gemIndex)
    local spawn = mq.TLO.Spawn(spawnID)
    if not spawn() then return false, string.format("spawn %d not found", spawnID) end
    if not mq.TLO.Me.SpellReady(gemIndex)() then return false, spell.Name().." not ready" end
    if not spell() then return false, "no spell found" end
    if not spell.StacksSpawn(spawnID)() then return false, spell.Name().." will not stack" end
    local buff = spawn.Buff(spell.ID())
    if not buff() then return false, "allies already has buff" end
    if spell.Mana() > mq.TLO.Me.CurrentMana() then return false, string.format("not enough mana (%d/%d)", mq.TLO.Me.CurrentMana(), spell.Mana()) end
    if spawn.Distance() > spell.Range() then return false, "target too far away" end
    if spellTag.IsHaste then
        local buff = mq.TLO.Spawn(spawnID).FindBuff("spa haste")
        if buff() and buff.HastePct() >= spell.HastePct() then return false, string.format("already hasted with %s", buff.Name()) end
    end

    self.buffCooldown = mq.gettime() + 1000
    elixir.LastActionOutput = string.format("casting %s on %s", spell.Name(), mq.TLO.Spawn(spawnID).Name())
    elixir.isActionCompleted = true
    if not mq.TLO.Target() or mq.TLO.Target.ID() ~= spawnID then
        mq.cmdf('/target id %d', spawnID)
    end
    mq.cmdf("/cast %d", gemIndex)
    --mq.delay(5000, WaitOnCasting)
    return true, elixir.LastActionOutput
end

return buff