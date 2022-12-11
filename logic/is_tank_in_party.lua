function IsTankInParty()
    if mq.TLO.Me.Class.ShortName() == "WAR" or mq.TLO.Me.Class.ShortName() == "SHD" or mq.TLO.Me.Class.ShortName() == "PAL" then return false end
    if mq.TLO.Group.GroupSize() then
        for i = 0, mq.TLO.Group.Members() do
            local pG = mq.TLO.Group.Member(i)
            if pG() and
            pG.Present() and
            pG.Type() ~= "CORPSE" and
            pG.Distance() < 200 and
            (pG.Class.ShortName() == "WAR" or pG.Class.ShortName() == "SHD" or pG.Class.ShortName() == "PAL") and
            not pG.Offline() then
                return true
            end
        end
    end

    if mq.TLO.Raid.Members() then
        for i = 0, mq.TLO.Raid.Members() do
            local pR = mq.TLO.Raid.Member(i)
            if pR() and
            pR.Type() ~= "CORPSE" and
            (pR.Class.ShortName() == "WAR" or pR.Class.ShortName() == "SHD" or pR.Class.ShortName() == "PAL") and
            pR.Distance() < 200 then
                return true
            end
        end
    end
    return false
end