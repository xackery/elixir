---@type Mq
local mq = require('mq')

---Attempts to find if we have high aggro on any mob, used primarily for meditate or subtle casting checks
---@returns isAggro boolean # true when primary aggro is high
function IsMeHighAggro()
    if not mq.TLO.Me.XTarget() then return false end

    for i = 0, mq.TLO.Me.XTarget() do
        local xt = mq.TLO.Me.XTarget(i)
        if xt() and
        xt.TargetType() == "Auto Hater" and
        xt.Type() ~= "CORPSE" and
        xt.Type() == "NPC" and
        xt.Distance() < 100 and
        xt.PctAggro() > 80 then
            return true
        end
    end

    return false
end