---@type Mq
local mq = require('mq')

---@class nuke
---@field public Output string # AI Debug String
---@field private nukeCooldown number # cooldown between nuking
nuke = {
    Output = '',
    nukeCooldown = 0,
}

---Attempts to cast a nuke spell
---@param elixir elixir
function nuke:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsNukeAI then return "nuke ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return string.format("on zone cooldown for %d seconds", math.ceil((elixir.ZoneCooldown-mq.gettime())/1000)) end
    if self.nukeCooldown and self.nukeCooldown > mq.gettime() then return string.format("on nuke cooldown for %d seconds", math.ceil((self.nukeCooldown-mq.gettime())/1000)) end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Me.Casting.ID() then return string.format("already casting %s", mq.TLO.Me.Casting.Name()) end
    if mq.TLO.Window("Casting").Open() then return "casting window open" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end
    if mq.TLO.Me.PctMana() < elixir.Config.NukePctMinMana then return string.format("mana too low at %d%%, needs to be greater than %d%%", mq.TLO.Me.PctMana(), elixir.Config.NukePctMinMana) end
    local spawn = mq.TLO.Target
    if not spawn() then return "no target" end
    if spawn.Type() ~= "NPC" then return "target is not NPC" end
    if spawn.PctHPs() > elixir.Config.NukePctNormal then return spawn.Name() .." is not hurt enough to nuke at "..spawn.PctHPs().."%" end    
    if not spawn.LineOfSight() then return "target "..spawn.Name().." is not line of sight" end

    local isCasted = false
    local lastCastOutput = "no nuking ability found"

    if elixir.Config.IsNukeSubtleCasting and mq.TLO.Me.Grouped() and mq.TLO.Me.PctAggro() > 80 then
        return string.format("subtle casting enabled and currently high hate %d%%", mq.TLO.Me.PctAggro())
    end

    for i = 1, mq.TLO.Me.NumGems() do
        if elixir.Gems[i].Tag.IsNuke and
            not elixir.Gems[i].IsIgnored then
            isCasted, lastCastOutput = nuke:CastGem(elixir, spawn.ID(), i)
            elixir.Gems[i].Output = " nuke ai: " .. lastCastOutput
            if isCasted then return lastCastOutput end
        end
    end
    return lastCastOutput
end

---Attempts to cast a nuke gem
---@param elixir elixir
---@param targetSpawnID number
---@param gemIndex number
---@returns isSuccess boolean, castOutput string
function nuke:CastGem(elixir, targetSpawnID, gemIndex)
    local spell = mq.TLO.Me.Gem(gemIndex)
    if not mq.TLO.Me.SpellReady(gemIndex)() then return false, spell.Name().." not ready" end
    if not spell() then return false, "no spell found" end
    if spell.Mana() > mq.TLO.Me.CurrentMana() then return false, "not enough mana (" .. mq.TLO.Me.CurrentMana() .. "/" .. spell.Mana() .. ")" end
    if mq.TLO.Spawn(targetSpawnID).Distance() > spell.Range() then return false, "target too far away" end

    self.nukeCooldown = mq.gettime() + 1000
    elixir.LastActionOutput = string.format("casting %s on %s", spell.Name(), mq.TLO.Spawn(targetSpawnID).Name())
    elixir.isActionCompleted = true
    mq.cmd(string.format("/casting \"%s\" -targetid|%d -maxtries|2", spell.Name(), targetSpawnID))
    --mq.delay(5000, WaitOnCasting)
    return true, elixir.LastActionOutput
end

return nuke