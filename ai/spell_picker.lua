---@type Mq
local mq = require('mq')

local aaTypes = {'General','Archtype','Class','Special','Focus','Merc'}

---@class SpellSubcategory
---@field Entries { [number]: SpellEntry[] }

---@class SpellEntry
---@field CleanName string # spell clean name (no rk etc)
---@field SpellName string # spell name
---@field SpellLevel number # spell level
---@field SpellID number # spell ID
---@field SpellIcon number # spell icon
---@field TargetType string # spell target type

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
---@field Spells table<string, table<string, SpellEntry[]>> # spell categories
---@field AltAbilities { [string]: AAEntry[] } # AA types
---@field Disciplines table<string, table<string, SpellEntry[]>> # AA types
local spellPicker = {}

---@param spell spell|number
---@returns isAdded boolean
function spellPicker:AddSpell(spell)
    local sp = self
    if not spell() then return false end
    local cat = spell.Category()
    local subcat = spell.Subcategory()
    if not sp.Spells[cat] then
        sp.Spells[cat] = {}
    end
    if not sp.Spells[cat][subcat] then
        sp.Spells[cat][subcat] = {}
    end
    local spellEntry = {} ---@type SpellEntry
    spellEntry.SpellLevel = spell.Level()
    local name = spell.Name():gsub(' Rk%..*', '')
    spellEntry.CleanName = name
    spellEntry.SpellName = spell.Name()
    spellEntry.SpellID = spell.ID()
    spellEntry.SpellIcon = spell.SpellIcon()
    spellEntry.TargetType = spell.TargetType()
    
    sp.Spells[cat][subcat][spell.ID()] = spellEntry
    return true
end

---@param sp SpellPicker
---@returns spellCount number
local function RefreshSpells(sp)
    local spellCount = 0
    local emptyCount = 0
    sp.Spells = {}
    for slot = 1, 1120 do
        if emptyCount < 10 then
            local spell = mq.TLO.Me.Book(slot)
            if not spell() then
                emptyCount = emptyCount + 1
            end
            if sp:AddSpell(spell) then spellCount = spellCount + 1 end
        end
    end
    --sp:SortMap(sp.Spells)
    return spellCount
end

---@param sp SpellPicker
---@param aa altability
---@returns isAdded boolean
local function addAAToMap(sp, aa)
    if not aa.Spell() then return false end
    local type = aaTypes[aa.Type()]
    local aaEntry = {} ---@type AAEntry
    aaEntry.Name = aa.Name()
    aaEntry.SpellName = aa.Spell.Name()
    if aaEntry.SpellName == nil then aaEntry.SpellName = aa.Name() end
    aaEntry.SpellID = aa.Spell.ID()
    aaEntry.TargetType = aa.Spell.TargetType()
    aaEntry.SpellIcon = aa.Spell.SpellIcon()
    if not sp.AltAbilities[type] then
        sp.AltAbilities[type] = {} ---@type AAEntry[]
    end
    table.insert(sp.AltAbilities[type], aaEntry)
    return true
end

---@param sp SpellPicker
---@param discID number
---@returns isAdded boolean
local function AddDisciplineToMap(sp, discID)
    local discipline = mq.TLO.Me.CombatAbility(discID)
    if not discipline() then return false end
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
    return true
end

---@param sp SpellPicker
local function RefreshAAs(sp)
    -- TODO: AA's take forever to load, so skipping for now
    if true then return 0 end
    local aaCount = 0
    sp.AltAbilities = {}
    for aaID = 1, 30000 do
        if addAAToMap(sp, mq.TLO.Me.AltAbility(aaID)) then aaCount = aaCount + 1 end
    end
    for _, type in ipairs(aaTypes) do
        if sp.AltAbilities[type] then
            table.sort(sp.AltAbilities[type], function(a, b) return a.Name < b.Name end)
        end
    end
    return aaCount
end

---@param sp SpellPicker
local function RefreshDisciplines(sp)
    local discCount = 0
    local discID = 1
    repeat
        if AddDisciplineToMap(sp, discID) then discCount = discCount + 1 end
        discID = discID + 1
    until mq.TLO.Me.CombatAbility(discID)() == nil
    sp:SortMap(sp.Spells)
    return discCount
end

--- Refreshes data in spell picker
function spellPicker:Refresh()
    elixir:DebugPrintf("loading spellpicker")
    local spellCount = RefreshSpells(spellPicker)
    local aaCount = RefreshAAs(spellPicker)
    local disciplineCount = RefreshDisciplines(spellPicker)
    elixir:DebugPrintf("spellpicker loaded %d spells, %d AAs, and %d disciplines", spellCount, aaCount, disciplineCount)
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
    table.sort(map)
    for category, subcategories in pairs(map) do
        if category ~= 'categories' then
            table.sort(map[category])
            for subcategory, subcatSpell in pairs(subcategories) do
                if subcategory ~= 'subcategories' then
                    table.sort(subcatSpell, SpellSorter)
                end
            end
        end
    end
end

return spellPicker