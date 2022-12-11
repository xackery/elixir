---@type Mq
local mq = require('mq')

--- meditate represents the Meditate AI, a system to figure out if I should meditate or not
---@class meditate
---@field public Output string # AI Debug String
---@field private meditateCooldown number # cooldown timer to use meditate
---@field private lastSitHPSnapshot number # whenever we try to sit, we snapshot the last HP to see if we got hurt
---@field private isLastStateSitting boolean # this is a check to verify we stood up recently
meditate = {
    Output = '',
    meditateCooldown = 0,
}

---Attempts to cast a meditate
---@param elixir elixir
----@returns output string
function meditate:Check(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsMeditateAI then return "meditate ai not running" end
    if mq.TLO.Me.Sitting() then
        self.lastSitHPSnapshot = mq.TLO.Me.PctHPs()
        self.isLastStateSitting = true
        return "currently meditating " .. mq.TLO.Me.PctHPs() .."% hp " .. mq.TLO.Me.PctMana() .."% mana"
    end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return string.format("on zone cooldown for %d seconds", math.ceil((elixir.ZoneCooldown-mq.gettime())/1000)) end
    if meditate.meditateCooldown and meditate.meditateCooldown > mq.gettime() then return string.format("on meditate cooldown for %d seconds", math.ceil((meditate.meditateCooldown-mq.gettime())/1000)) end
    if mq.TLO.Me.PctMana() >= 99 and mq.TLO.Me.PctHPs() > 99 then return "full mana and health, no need to meditate" end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then
        self.meditateCooldown = mq.gettime() + 6000
        return "stunned recently, waiting 6s to meditate"
    end
    if AreObstructionWindowsVisible() then return "window obstructs sitting" end
    if mq.TLO.Me.Moving() then
        self.meditateCooldown = mq.gettime() + 6000
        return "moved recently, waiting 6s to meditate"
    end
    if mq.TLO.Me.Mount.ID() then return "already on a mount" end
    if mq.TLO.Me.Casting() then return "currently casting" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end
    if mq.TLO.Me.Sitting() then return "already sitting" end
    if mq.TLO.Me.CombatState() == "COMBAT" then
        if not elixir.Config.IsMeditateDuringCombat then
            return "in combat, can't meditate as per settings"
        end
    end
    if mq.TLO.Me.AutoFire() then return "autofire enabled, cannot meditate" end
    if mq.TLO.Me.Combat() then return "autoattack enabled, cannot meditate" end
    if elixir.Config.IsMeditateSubtle and IsMeHighAggro() then return "subtle meditate enabled and currently high hate" end
    if self.isLastStateSitting then
        -- ok, so we stood up last update, and potentially got hurt, let's see how much
        if mq.TLO.Me.PctHPs() < self.lastSitHPSnapshot then
            self.meditateCooldown = mq.gettime() + 12000
            self.lastSitHPSnapshot = mq.TLO.Me.PctHPs()
            return "got hit in combat, waiting 12s to sit"
        end
    end

    mq.cmd("/sit")
    elixir.LastActionOutput = "meditate ai sitting"
    self.lastSitHPSnapshot = mq.TLO.Me.PctHPs()
    return "trying to sit to meditate"
end

return meditate