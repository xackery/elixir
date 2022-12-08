---@type Mq
local mq = require('mq')

---Are any obstruction windows visible
---@return boolean # returns true if any are visible
function AreObstructionWindowsVisible()
    if mq.TLO.Window("SpellBookWnd").Open() then
        return true
    end
    if mq.TLO.Window("GiveWnd").Open() then
        return true
    end

    if mq.TLO.Window("BankWnd").Open() then
        return true
    end

    if mq.TLO.Window("MerchantWnd").Open() then
        return true
    end

    if mq.TLO.Window("TradeWnd").Open() then
        return true
    end

    if mq.TLO.Window("LootWnd").Open() then
        return true
    end

	return false
end