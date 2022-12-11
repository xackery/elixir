---@type Mq
local mq = require('mq')

---@class stun
---@field public Output string # AI Debug String
---@field private stunCooldown number # cooldown between nuking
stun = {
    Output = '',
    stunCooldown = 0,
}

---Attempts to cast a stun spell
---@param elixir elixir
function stun:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsStunAI then return "stun ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return "on zone cooldown" end
    if self.stunCooldown and self.stunCooldown > mq.gettime() then return "on stun cooldown" end
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
    if not spawn.LineOfSight() then return "target "..spawn.Name().." is not line of sight" end

    local isCasted = false
    local lastCastOutput = "no stun ability found"

    for i = 1, mq.TLO.Me.NumGems() do
        if elixir.Gems[i].Tag.StunDuration > 0 and
            elixir.Gems[i].Tag.IsPBAE and
            not elixir.Gems[i].IsIgnored then
            elixir:DebugPrintf("found stun at gem %d will cast on %d", i, spawn.ID())
            isCasted, lastCastOutput = stun:CastGem(elixir, spawn.ID(), i)
            elixir.Gems[i].Output = elixir.Gems[i].Output .. " stun ai: " .. lastCastOutput            
            if isCasted then
                self.stunCooldown = mq.gettime() + elixir.Gems[i].Tag.StunDuration-1000
                return lastCastOutput
            end
        end
    end
    return lastCastOutput
end

---Attempts to cast a stun gem
---@param elixir elixir
---@param targetSpawnID number
---@param gemIndex number
---@returns isSuccess boolean, castOutput string
function stun:CastGem(elixir, targetSpawnID, gemIndex)
    if not mq.TLO.Me.SpellReady(gemIndex) then return false, "spell not ready" end
    local spell = mq.TLO.Me.Gem(gemIndex)
    if not spell() then return false, "no spell found" end
    if spell.Mana() > mq.TLO.Me.CurrentMana() then return false, "not enough mana (" .. mq.TLO.Me.CurrentMana() .. "/" .. spell.Mana() .. ")" end
    if mq.TLO.Spawn(targetSpawnID).Distance() > spell.Range() then return false, "target too far away" end

    elixir.LastActionOutput = string.format("stun ai casting %s on %s", spell.Name(), mq.TLO.Spawn(targetSpawnID).Name())
    elixir.isActionCompleted = true
    mq.cmd(string.format("/casting \"%s\" -targetid|%d -maxtries|2", spell.Name(), targetSpawnID))
    --mq.delay(5000, WaitOnCasting)
    return true, elixir.LastActionOutput
end

return stun