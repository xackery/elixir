---@type Mq
local mq = require('mq')

--- meditate represents the Meditate AI, a system to figure out if I should meditate or not
---@class meditate
---@field public Output string # AI Debug String
---@field public meditateCooldown number # cooldown timer to use meditate
meditate = {}

----@returns meditate string
function meditate:Initialize()
    return {
        Output = '',
        meditateCooldown = 0,
    }
end

---Attempts to cast a meditate
---@param elixir elixir
----@returns output string
function meditate:Check(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and  mq.TLO.EverQuest.Foreground() then return "AI frozen, disabled on focus" end
    if elixir.ZoneCooldown > mq.gettime() then return "on zone cooldown" end
    --if meditate.meditateCooldown > mq.gettime() then return "on meditate cooldown" end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Me.Casting() then return "already casting" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end
    return "no meditating spell available"
end
