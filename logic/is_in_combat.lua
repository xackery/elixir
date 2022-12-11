---@type Mq
local mq = require('mq')

---Is in combat will return if the detected state seems like combat
---@returns IsCombat boolean # Returns true when group or self is in combat
function IsInCombat()
    if mq.TLO.Me.CombatState() == "COMBAT" then return true end
    if not mq.TLO.Me.XTarget() then return false end

    for i = 0, mq.TLO.Me.XTarget() do
        local xt = mq.TLO.Me.XTarget(i)
        if xt() and
        xt.TargetType() == "Auto Hater" and
        xt.Type() ~= "CORPSE" and
        xt.Type() == "NPC" and
        xt.Distance() < 100 and
        xt.PctAggro() > 0 then
            return true
        end
    end
end