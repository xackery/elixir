---@type Mq
local mq = require('mq')

---Returns true if the target is a valid bodtype, based on spelltags
---@param spellTag SpellTag
function IsTargetValidBodyType(spellTag)
    if not mq.TLO.Target() then return true end
    local bodyType = mq.TLO.Target.Body.ID()
    if bodyType ~= 21 and spellTag.IsAnimalOnly == true then return false end
    if bodyType ~= 3 and spellTag.IsUndeadOnly == true then return false end
    if bodyType ~= 28 and spellTag.IsSummonedOnly == true then return false end
    if bodyType ~= 25 and spellTag.IsPlantOnly == true then return false end
    return true
end