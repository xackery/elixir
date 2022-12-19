---@type Mq
local mq = require('mq')

local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')
local animItems = mq.FindTextureAnimation('A_DragItem')
-- Blue and yellow icon border textures
local animBlueWndPieces = mq.FindTextureAnimation('BlueIconBackground')
animBlueWndPieces:SetTextureCell(1)
local animYellowWndPieces = mq.FindTextureAnimation('YellowIconBackground')
animYellowWndPieces:SetTextureCell(1)
local animRedWndPieces = mq.FindTextureAnimation('RedIconBackground')
animRedWndPieces:SetTextureCell(1)

local spells, altAbilities, discs = {categories={}},{types={}},{categories={}}
local aatypes = {'General','Archtype','Class','Special','Focus','Merc'}

--- Used as a cache for spell icons
---@type { [number]: number }
local spellIcons = {}

---@param spellID number # spell ID to get
---@returns spellIcon number # spell icon
local function spellIcon(spellID)
    if not spellIcons[spellID] then
        for category in pairs(elixir.SpellPicker.Spells) do
            for subcategory in pairs(elixir.SpellPicker.Spells[category]) do
                for _, entry in pairs(elixir.SpellPicker.Spells[category][subcategory]) do
                    if entry.SpellID == spellID then
                        spellIcons[spellID] = entry.SpellIcon
                        return spellIcons[spellID]
                    end
                end
            end
        end
        -- TODO: default fallback spell icon
        spellIcons[spellID] = 0
    end
    return spellIcons[spellID]
end

-- Color spell names in spell picker similar to the spell bar context menus
---@param targetType string
local function setSpellTextColor(targetType)
    if targetType == 'Single' or targetType == 'Line of Sight' or targetType == 'Undead' then
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)
    elseif targetType == 'Self' then
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 0, 1)
    elseif targetType == 'Group v2' or targetType == 'Group v1' or targetType == 'AE PC v2' then
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 1, 1)
    elseif targetType == 'Beam' then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 1, 1)
    elseif targetType == 'Targeted AE' then
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.5, 0, 1)
    elseif targetType == 'PB AE' then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 0.5, 1, 1)
    elseif targetType == 'Pet' then
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)
    elseif targetType == 'Pet2' then
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)
    elseif targetType == 'Free Target' then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
    else
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 1, 1)
    end
end

---@alias SpellPickerSpellType 'spell' | 'aa' | 'discipline'

---@param context string
---@param spellID number
---@param title string
---@returns isChanged boolean, spellType SpellPickerSpellType, newSpellID number, newSpellName string
function DrawSpellPicker(context, spellID, title)
    if not spellID then spellID = 0 end
    local iconSize = {30, 30} -- default icon size
    local x, y = ImGui.GetCursorPos()
    ImGui.BeginGroup()
    if spellID == 0 then
        ImGui.DrawTextureAnimation(animRedWndPieces, iconSize[1], iconSize[2])
    else
        animSpellIcons:SetTextureCell(spellIcon(spellID))
        ImGui.DrawTextureAnimation(animSpellIcons, iconSize[1], iconSize[2])
    end
    ImGui.SameLine()
    ImGui.SetCursorPosY(ImGui.GetCursorPosY()+6)
    ImGui.Text(title)
    ImGui.SetCursorPos(x, y)
    if ImGui.InvisibleButton(string.format('##spell-%s', context), 30, 30) then
        print("invis clicked")
    end
    ImGui.SetCursorPos(x, y+30)
    ImGui.EndGroup()

    if not elixir then return false, 'aa', 0, 'None' end
    if not elixir.SpellPicker then return false, 'aa', 0, 'None' end
    if not ImGui.BeginPopupContextItem(string.format('##spellMenu-%s', context)) then return false, 'aa', 0, 'None' end
    
    local isChanged = false
    local spellID = 0
    local spellName = 'None'
    local spellType = 'spell' ---@type SpellPickerSpellType
    if elixir.SpellPicker.Spells and ImGui.BeginMenu(string.format('Spells##spellMenu-%s', context)) then
        for category, categoryValue in pairs(elixir.SpellPicker.Spells) do
            if ImGui.BeginMenu(string.format("%s##spellMenu-%s-%s", category, category, context)) then
                for subcategory, subcategoryValue in pairs(categoryValue) do
                    local menuHeight = -1
                    if #subcategoryValue> 25 then
                        menuHeight = ImGui.GetTextLineHeight()*25
                    end
                    ImGui.SetNextWindowSize(250, menuHeight)
                    if ImGui.BeginMenu(string.format("%s##%s-%s", subcategory, subcategory, context)) then
                        for _, spell in pairs(subcategoryValue) do
                            -- spell[1]=level, spell[2]=name
                            setSpellTextColor(spell.TargetType)
                            if ImGui.MenuItem(string.format("%d - %s##spellMenu-%s-%s", spell.SpellLevel, spell.CleanName, spell.CleanName, context)) then
                                isChanged = true
                                spellID = spell.SpellID
                                spellName = spell.CleanName
                                spellType = 'spell'
                            end
                            ImGui.PopStyleColor()
                        end
                        ImGui.EndMenu()
                    end
                end
                ImGui.EndMenu()
            end
        end
        ImGui.EndMenu()
    end

    if elixir.SpellPicker.AltAbilities and ImGui.BeginMenu(string.format('Alt Abilities##altMenu-%s', context)) then
        for _, type in ipairs(aatypes) do
            if elixir.SpellPicker.AltAbilities[type] then
                local menuHeight = -1
                if #elixir.SpellPicker.AltAbilities[type] > 25 then
                    menuHeight = ImGui.GetTextLineHeight()*25
                end
                ImGui.SetNextWindowSize(250, menuHeight)
                if ImGui.BeginMenu(string.format("%s##altMenu-%s-%s", type, type, context)) then
                    for _, altAbility in ipairs(elixir.SpellPicker.AltAbilities[type]) do
                        setSpellTextColor(altAbility.TargetType)
                        if ImGui.MenuItem(string.format("%s##altMenu-%s-%s", altAbility.Name, altAbility.Name, context)) then
                            isChanged = true
                            spellID = altAbility.SpellID
                            spellName = altAbility.SpellName
                            spellType = 'aa'
                        end
                        ImGui.PopStyleColor()
                    end
                    ImGui.EndMenu()
                end
            end
        end
        ImGui.EndMenu()
    end

    if elixir.SpellPicker.Disciplines and #elixir.SpellPicker.Disciplines and ImGui.BeginMenu(string.format('Combat Abilities##discMenu-%s', context)) then
        for _, category in ipairs(elixir.SpellPicker.Disciplines.categories) do
            -- Spell Subcategories submenu
            if ImGui.BeginMenu(string.format("%s##discMenu-%s-%s", category, category, context)) then
                for _,subcategory in ipairs(elixir.SpellPicker.Disciplines[category].Subcategories) do
                    -- Subcategory Spell menu
                    local menuHeight = -1
                    if #elixir.SpellPicker.Disciplines[category].Subcategories[subcategory] > 25 then
                        menuHeight = ImGui.GetTextLineHeight()*25
                    end
                    ImGui.SetNextWindowSize(250, menuHeight)
                    if #elixir.SpellPicker.Disciplines[category].Subcategories[subcategory] > 0 and
                    ImGui.BeginMenu(string.format("%s##discMenu-%s-%s", subcategory, subcategory, context)) then
                        for _, spell in ipairs(elixir.SpellPicker.Disciplines[category].Subcategories[subcategory]) do
                            -- spell[1]=level, spell[2]=name
                            setSpellTextColor(spell.TargetType)
                            if ImGui.MenuItem(string.format("%d - %s##discMenu-%s-%s", spell.SpellLevel, spell.CleanName, spell.CleanName, context)) then
                                isChanged = true
                                spellID = spell.SpellID
                                spellName = spell.CleanName
                                spellType = 'discipline'
                            end
                            ImGui.PopStyleColor()
                        end
                        ImGui.EndMenu()
                    end
                end
                ImGui.EndMenu()
            end
        end
        ImGui.EndMenu()
    end
    ImGui.EndPopup()
    return isChanged, spellType, spellID, spellName
end
