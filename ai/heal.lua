---@type Mq
local mq = require('mq')

require('logic')

---@class heal
---@field public Output string # AI Debug String
---@field public HealCooldown number # cooldown timer to use heal
heal = {}

---@returns heal string
function heal:Initialize()
    return {
        Output = '',
        HealCooldown = 0,
    }
end

---Attempts to cast a heal
---@param elixir elixir
---@returns output string
function heal:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsHealAI then return "heal ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and  mq.TLO.EverQuest.Foreground() then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return "on zone cooldown" end
    --if heal.HealCooldown > mq.gettime() then return "on heal cooldown" end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Me.Casting() then return "already casting" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end

    local spawnID = MostHurtAlly()
    if (not spawnID) then return "no one needs healing" end

    local lastCastError = "no heal memorized"
    for i = 1, mq.TLO.Me.NumGems() do
        if elixir.Gems[i].Tag.IsHeal then
            elixir:DebugPrintf("found heal at gem %d will cast on %d", i, spawnID)
            lastCastError = heal:CastGem(elixir, spawnID, i)
            elixir.Gems[i].Output = elixir.Gems[i].Output .. " Heal AI: " .. lastCastError
            if not lastCastError then
                return ""
            end
        end
    end
    if lastCastError then return lastCastError end
    return "no healing spell available"
end

---Attempts to cast a heal gem
---@param elixir elixir
---@param targetSpawnID number
---@param gemIndex number
---@returns lastCastError string # if casting failed, this will explain why
function heal:CastGem(elixir, targetSpawnID, gemIndex)
    if not mq.TLO.Me.SpellReady(gemIndex) then return "spell not ready" end
    local spell = mq.TLO.Me.Gem(gemIndex)
    if not spell() then return "no spell found" end
    if spell.Mana() > mq.TLO.Me.CurrentMana() then return "not enough mana (" .. mq.TLO.Me.CurrentMana() .. "/" .. spell.Mana() .. ")" end

    self.HealCooldown = mq.gettime() + 1000
    elixir.LastActionOutput = string.format("heal ai casting %s on %s", spell.Name(), mq.TLO.Spawn(targetSpawnID).Name())
    elixir.HealAI.Output = elixir.LastActionOutput
    elixir.isActionCompleted = true
    mq.cmd(string.format("/casting \"%s\" -targetid|%d -maxtries|2", spell.Name(), targetSpawnID))
    --mq.delay(5000, WaitOnCasting)
    return ""
end

return heal