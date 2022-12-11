---Is in combat will return if the detected state seems like combat
---@returns IsCombat boolean # Returns true when group or self is in combat
function IsInCombat()
    if mq.TLO.Me.CombatState() == "COMBAT" then return true end
    
end