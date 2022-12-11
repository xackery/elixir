---@type Mq
local mq = require('mq')

require('logic')

---@class attack
---@field public Output string # AI Debug String
---@field private attackCooldown number # cooldown timer to use attack
attack = {
    Output = '',
    attackCooldown = 0,
}

---Attempts to cast a attack
---@param elixir elixir
---@returns output string
function attack:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsAttackAI then return "attack ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return "on zone cooldown" end
    if self.attackCooldown and self.attackCooldown > mq.gettime() then return "on attack cooldown" end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Me.Casting.ID() then return string.format("already casting %s", mq.TLO.Me.Casting.Name()) end
    if mq.TLO.Window("Casting").Open() then return "casting window open" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end
    if mq.TLO.Me.AutoFire() then return "autofire already enabled" end

    local spawn = mq.TLO.Target
    if not spawn() then return "no target to attack" end
    if mq.TLO.Group and
    elixir.Config.IsTargetAI and
    mq.TLO.Group.MainAssist.ID() and
    mq.TLO.Group.MainAssist.ID() ~= mq.TLO.Me.ID() then
        return "no main assist set"
    end

    if elixir.Config.IsAttackSubtle and
    mq.TLO.Target.ID() and
    mq.TLO.Target.AggroHolder.ID() == mq.TLO.Me.ID() and
    elixir.IsTankInParty and
    spawn.PctHPs() > 15 and
    mq.TLO.Me.Combat() then
        mq.cmd("/attack")
        return "subtle attack enabled and currently high hate"
    end
    if mq.TLO.Me.Combat() then return "autoattack already enabled" end

    if spawn.Distance() > 20 then return "target too far to attack" end
    mq.cmd("/attack")
    return "turned on attack"
end

return attack