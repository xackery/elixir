---@type Mq
local mq = require('mq')

local aaTypes = {'General','Archtype','Class','Special','Focus','Merc'}

---@class SpellSubcategory
---@field CleanName string # spell clean name (no rk etc)
---@field SpellName string # spell name
---@field SpellLevel number # spell level
---@field SpellID number # spell ID
---@field SpellIcon number # spell icon
---@field TargetType string # spell target type

---@class SpellCategory
---@field Subcategories { [string]: SpellSubcategory[] } # spell subcategories

---@class AAEntry
---@field Name string # AA Name
---@field SpellName string # AA Spell Name
---@field SpellID number # AA Spell ID
---@field SpellIcon number # AA spell icon
---@field TargetType string ## AA Target Type

---@class DiscEntry
---@field Level number # Discipline level
---@field CleanName string # Disc clean name (no rk etc)
---@field Name string # Disc Name

---@class DisciplineSubcategory
---@field CleanName string # spell clean name (no rk etc)
---@field SpellName string # spell name
---@field SpellIcon number # spell icon
---@field SpellLevel number # spell level

---@class SpellPicker
---@field Spells { [string]: SpellCategory } # spell categories
---@field AltAbilities { [string]: AAEntry[] } # AA types
---@field Disciplines { [string]: SpellCategory } # AA types
local spellPicker = {}

---@param spellID number
---@returns SpellSubcategory
function spellPicker:SpellByID(spellID)
    
end

---@param spell spell|number
function spellPicker:AddSpellToMap(spell)
    local sp = self
    if not spell() then return end
    local cat = spell.Category()
    local subcat = spell.Subcategory()
    if not sp.Spells[cat] then
        local category = {} ---@type SpellCategory
        table.insert(sp.Spells[cat], category)
    end
    if not sp.Spells[cat].Subcategories[subcat] then
        local subCategory = {} ---@type SpellSubcategory
        table.insert(sp.Spells[cat].Subcategories[subcat], subCategory)
    end
    local subCategory = {} ---@type SpellSubcategory
    subCategory.SpellLevel = spell.Level()
    local name = spell.Name():gsub(' Rk%..*', '')
    subCategory.CleanName = name
    subCategory.SpellName = spell.Name()
    subCategory.SpellID = spell.ID()
    subCategory.TargetType = spell.TargetType()
    table.insert(spellPicker[cat].Subcategory[subcat], subCategory)
end

---@param sp SpellPicker
local function RefreshSpells(sp)
    sp.Spells = {}
    for slot = 1, 1120 do
        local spell = mq.TLO.Me.Book(slot)
        sp:AddSpellToMap(spell)
    end
    sp:SortMap(sp.Spells)
end

---@param sp SpellPicker
---@param aa altability
local function addAAToMap(sp, aa)
    if not aa.Spell() then return end
    local type = aaTypes[aa.Type()]
    local aaEntry = {} ---@type AAEntry
    aaEntry.Name = aa.Name()
    aaEntry.SpellName = aa.Spell.Name()
    aaEntry.SpellID = aa.Spell.ID()
    aaEntry.TargetType = aa.Spell.TargetType()
    if not sp.AltAbilities[type] then
        sp.AltAbilities[type] = {} ---@type AAEntry[]
    end
    table.insert(sp.AltAbilities[type], aaEntry)
end

---@param sp SpellPicker
---@param discID number
local function AddDisciplineToMap(sp, discID)
    local discipline = mq.TLO.Me.CombatAbility(discID)
    if not discipline() then return end
    local cat = discipline.Category()
    local subcat = discipline.Subcategory()

    if not sp.Disciplines[cat] then
        local category = {} ---@type SpellCategory
        table.insert(sp.Disciplines[cat], category)
    end
    if not sp.Disciplines[cat].Subcategories[subcat] then
        local subCategory = {} ---@type SpellSubcategory
        table.insert(sp.Disciplines[cat].Subcategories[subcat], subCategory)
    end
    local subCategory = {} ---@type SpellSubcategory
    subCategory.DisciplineLevel = discipline.Level()
    local name = discipline.Name():gsub(' Rk%..*', '')
    subCategory.CleanName = name
    subCategory.DisciplineName = discipline.Name()
    subCategory.TargetType = discipline.TargetType()
    table.insert(spellPicker[cat].Subcategory[subcat], subCategory)
end

---@param sp SpellPicker
local function RefreshAAs(sp)
    sp.AltAbilities = {}
    for aaID = 1, 10000 do
        addAAToMap(sp, mq.TLO.Me.AltAbility(aaID))
    end
    for _, type in ipairs(aaTypes) do
        if sp.AltAbilities[type] then
            table.sort(sp.AltAbilities[type], function(a,b) return a[1] < b[1] end)
        end
    end
end

---@param sp SpellPicker
local function RefreshDisciplines(sp)
    local discID = 1
    repeat
        AddDisciplineToMap(sp, discID)
        discID = discID + 1
    until mq.TLO.Me.CombatAbility(discID)() == nil
    sp:SortMap(sp.Spells)
end

--- Refreshes data in spell picker
function spellPicker:Refresh()
    print("refreshing spellPicker")
    RefreshSpells(spellPicker)
    RefreshAAs(spellPicker)
    RefreshDisciplines(spellPicker)
end

-- Sort spells by level
local SpellSorter = function(a, b)
    -- spell level is in spell[1], name in spell[2]
    if a[1] < b[1] then
        return false
    elseif b[1] < a[1] then
        return true
    else
        return false
    end
end

function spellPicker:SortMap(map)
    -- sort categories and subcategories alphabetically, spellPicker by level
    table.sort(map.categories)
    for category,subcategories in pairs(map) do
        if category ~= 'categories' then
            table.sort(map[category].subcategories)
            for subcategory, subcatSpell in pairs(subcategories) do
                if subcategory ~= 'subcategories' then
                    table.sort(subcatSpell, SpellSorter)
                end
            end
        end
    end
end

return spellPicker