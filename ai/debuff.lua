---@type Mq
local mq = require('mq')

---@class debuff
---@field public Output string # AI Debug String
---@field private debuffCooldown number # cooldown between debuffing
debuff = {
    Output = '',
    debuffCooldown = 0,
}

---Attempts to cast a debuff spell
---@param elixir elixir
function debuff:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsDebuffAI then return "debuff ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return string.format("on zone cooldown for %d seconds", math.ceil((elixir.ZoneCooldown-mq.gettime())/1000)) end
    if self.debuffCooldown and self.debuffCooldown > mq.gettime() then string.format("on debuff cooldown for %d seconds", math.ceil((self.debuffCooldown-mq.gettime())/1000)) end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Me.Casting.ID() then return string.format("already casting %s", mq.TLO.Me.Casting.Name()) end
    if mq.TLO.Window("Casting").Open() then return "casting window open" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end
    local spawn = mq.TLO.Target
    if not spawn() then return "no target" end
    if spawn.Type() ~= "NPC" then return "target is not NPC" end
    if spawn.PctHPs() > elixir.Config.DebuffPctNormal then return spawn.Name() .." is not hurt enough to debuff at "..spawn.PctHPs().."%" end
    if not spawn.LineOfSight() then return "target "..spawn.Name().." is not line of sight" end

    local isCasted = false
    local lastCastOutput = "no debuffing ability found"

    if elixir.Config.IsDebuffSubtleCasting and mq.TLO.Me.Grouped() and mq.TLO.Me.PctAggro() > 80 then
        return string.format("subtle casting enabled and currently high hate %d%%", mq.TLO.Me.PctAggro())
    end

    for i = 1, mq.TLO.Me.NumGems() do
        if elixir.Gems[i].Tag.IsDebuff and
            not elixir.Gems[i].IsIgnored then
            isCasted, lastCastOutput = debuff:CastGem(elixir, spawn.ID(), i)
            elixir.Gems[i].Output = "debuff ai: " .. lastCastOutput
            if isCasted then return lastCastOutput end
        end
    end
    return lastCastOutput
end

---Attempts to cast a debuff gem
---@param elixir elixir
---@param targetSpawnID number
---@param gemIndex number
---@returns isSuccess boolean, castOutput string
function debuff:CastGem(elixir, targetSpawnID, gemIndex)

    local spellTag = elixir.Gems[gemIndex].Tag

    local spell = mq.TLO.Me.Gem(gemIndex)
    if not mq.TLO.Me.SpellReady(gemIndex)() then return false, spell.Name().." not ready" end
    if not spell() then return false, "no spell found" end    
    if spell.Mana() > mq.TLO.Me.CurrentMana() then return false, "not enough mana (" .. mq.TLO.Me.CurrentMana() .. "/" .. spell.Mana() .. ")" end    
    if not spell.StacksTarget() then return false, "debuff won't stack on target" end
    if mq.TLO.Target.Buff(spell.Name()).ID() then return false, "target already has "..spell.Name().." on them" end
    if mq.TLO.Spawn(targetSpawnID).Distance() > spell.Range() then return false, "target too far away" end

    if spellTag.IsFear and not mq.TLO.Target.Snared.ID() then
        if not elixir.Config.IsDebuffFearKiting then return false, "no fear kiting allowed" end
        if not elixir.Config.IsDebuffNoSnareFearKiting then return false, "no fear kiting using "..spell.Name().." without snare allowed" end
    end

    if spellTag.IsSlow and mq.TLO.Target.Slowed.ID() then
        if mq.TLO.Target.Slowed.SlowPct() >= spell.SlowPct() then return false, string.format("target already slowed %d%%", mq.TLO.Target.Slowed.SlowPct()) end
        --TODO: immune to slow check
    end

    if spellTag.IsSnare and mq.TLO.Target.Snared.ID() then
        if not mq.TLO.Target.Snared.WillStack(spell.Name()) then return false, string.format("target already snared") end
        --TODO: immune to snare check
    end

    self.debuffCooldown = mq.gettime() + 1000
    elixir.LastActionOutput = string.format("debuff ai casting %s on %s", spell.Name(), mq.TLO.Spawn(targetSpawnID).Name())
    elixir.isActionCompleted = true
    mq.cmd(string.format("/casting \"%s\" -targetid|%d -maxtries|2", spell.Name(), targetSpawnID))
    --mq.delay(5000, WaitOnCasting)
    return true, elixir.LastActionOutput
end

return debuff