---@type Mq
local mq = require('mq')

---@class mez
---@field public Output string # AI Debug String
---@field private mezCooldown number # cooldown between nuking
mez = {
    Output = '',
    mezCooldown = 0,
}

---Attempts to cast a mez spell
---@param elixir elixir
function mez:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsMezAI then return "mez ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return string.format("on zone cooldown for %d seconds", math.ceil((elixir.ZoneCooldown-mq.gettime())/1000)) end
    if self.mezCooldown and self.mezCooldown > mq.gettime() then return string.format("on mez cooldown for %d seconds", math.ceil((self.mezCooldown-mq.gettime())/1000)) end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Me.Casting.ID() then return string.format("already casting %s", mq.TLO.Me.Casting.Name()) end
    if mq.TLO.Window("Casting").Open() then return "casting window open" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end
    return "mez is not supported yet"
    --local lastCastOutput = "no mez spells found"
    --local isCasted = false
    --for i = 1, mq.TLO.Me.NumGems() do
        --if elixir.Gems[i].Tag.IsMez and
            --not elixir.Gems[i].IsIgnored then
            --elixir:DebugPrintf("found mez at gem %d will cast on %d", i, spawn.ID())
            --isCasted, lastCastOutput = mez:CastGem(elixir, spawn.ID(), i)
            --elixir.Gems[i].Output = elixir.Gems[i].Output .. " mez ai: " .. lastCastOutput
            --if isCasted then return lastCastOutput end
        --end
    --end
    --return lastCastOutput
end

---Attempts to cast a mez gem
---@param elixir elixir
---@param spawnID number
---@param gemIndex number
---@returns isSuccess boolean, castOutput string
function mez:CastGem(elixir, spawnID, gemIndex)
    local spell = mq.TLO.Me.Gem(gemIndex)
    if not mq.TLO.Me.SpellReady(gemIndex)() then return false, spell.Name().." not ready" end
    if not spell() then return false, "no spell found" end
    if spell.Mana() > mq.TLO.Me.CurrentMana() then return false, "not enough mana (" .. mq.TLO.Me.CurrentMana() .. "/" .. spell.Mana() .. ")" end
    if mq.TLO.Spawn(spawnID).Distance() > spell.Range() then return false, "target too far away" end

    self.mezCooldown = mq.gettime() + 1000
    elixir.LastActionOutput = string.format("mez ai casting %s on %s", spell.Name(), mq.TLO.Spawn(spawnID).Name())
    elixir.isActionCompleted = true
    if not mq.TLO.Target() or mq.TLO.Target.ID() ~= spawnID then
        mq.cmdf('/target id %d', spawnID)
    end
    mq.cmdf("/cast %d", gemIndex)
    --mq.delay(5000, WaitOnCasting)
    return true, elixir.LastActionOutput
end

return mez