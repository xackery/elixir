---@type Mq
local mq = require('mq')

require('logic')

---@class archery
---@field public Output string # AI Debug String
---@field private archeryCooldown number # cooldown timer to use archery
archery = {
    Output = '',
    archeryCooldown = 0,
}

---Attempts to cast a archery
---@param elixir elixir
---@returns output string
function archery:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsArcheryAI then return "archery ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return string.format("on zone cooldown for %d seconds", math.ceil((elixir.ZoneCooldown-mq.gettime())/1000)) end
    if self.archeryCooldown and self.archeryCooldown > mq.gettime() then return string.format("on archery cooldown for %d seconds", math.ceil((self.archeryCooldown-mq.gettime())/1000)) end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Me.Casting.ID() then return string.format("already casting %s", mq.TLO.Me.Casting.Name()) end
    if mq.TLO.Window("Casting").Open() then return "casting window open" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end

    local spawn = mq.TLO.Target
    if not spawn() then return "no target to archery attack" end
    if mq.TLO.Group and
    elixir.Config.IsTargetAI and
    mq.TLO.Group.MainAssist.ID() and
    mq.TLO.Group.MainAssist.ID() ~= mq.TLO.Me.ID() then
        return "no main assist set"
    end

    if elixir.Config.IsArcherySubtle and IsMeHighAggro() and spawn.PctHPs() > 15 then
        return "subtle archery enabled and currently high hate"
    end

    if mq.TLO.Me.AutoFire() then return "autofire already enabled" end
    if mq.TLO.Me.Combat() then return "autoattack already enabled" end
    mq.cmd("/autofire")
    return "turned on autofire for archery"
end

return archery