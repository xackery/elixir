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
        for _, category in ipairs(elixir.SpellPicker.Spells.categories) do
            for _, subcategory in ipairs(elixir.SpellPicker.Spells[category].Subcategories) do
                if subcategory.SpellID == spellID then
                    spellIcons[spellID] = subcategory.SpellIcon
                    return spellIcons[spellID]
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
---@returns isChanged boolean, spellType SpellPickerSpellType, spellId number
local function drawSpellPicker(context)
    if not elixir then return end
    if not elixir.SpellPicker then return end
    if not ImGui.BeginPopupContextItem(string.format('##spellMenu-%s', context)) then return end
    
    local isChanged = false
    local spellID = 0
    local spellType = 'spell' ---@type SpellPickerSpellType
    if #elixir.SpellPicker.Spells and ImGui.BeginMenu(string.format('Spells##spellMenu-%s', context)) then
        for _, category in ipairs(elixir.SpellPicker.Spells.categories) do
            -- Spell Subcategories submenu
            if ImGui.BeginMenu(string.format("%s##spellMenu-%s-%s", category, category, context)) then
                for _, subcategory in ipairs(elixir.SpellPicker.Spells[category].Subcategories) do
                    -- Subcategory Spell menu
                    local menuHeight = -1
                    if #elixir.SpellPicker.Spells[category].Subcategories[subcategory] > 25 then
                        menuHeight = ImGui.GetTextLineHeight()*25
                    end
                    ImGui.SetNextWindowSize(250, menuHeight)
                    if #elixir.SpellPicker.Spells[category].Subcategories[subcategory] > 0 and
                    ImGui.BeginMenu(string.format("%s##%s-%s", subcategory, subcategory, context)) then
                        for _, spell in ipairs(elixir.SpellPicker.Spells[category].Subcategories[subcategory]) do
                            -- spell[1]=level, spell[2]=name
                            setSpellTextColor(spell.TargetType)
                            if ImGui.MenuItem(string.format("%d - %s##spellMenu-%s-%s", spell.SpellLevel, spell.CleanName, spell.CleanName, context)) then
                                isChanged = true
                                spellID = spell.SpellID
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

    if #elixir.SpellPicker.AltAbilities and ImGui.BeginMenu(string.format('Alt Abilities##altMenu-%s', context)) then
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

    if #elixir.SpellPicker.Disciplines and ImGui.BeginMenu(string.format('Combat Abilities##discMenu-%s', context)) then
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
    return isChanged, spellType, spellID
end

---@param context string # Context is a UUID for the button
---@param spellID number
function DrawSpellButton(context, spellID)
    local iconSize = {30,30} -- default icon size
    local x, y = ImGui.GetCursorPos()
    if spellID == 0 then
        ImGui.DrawTextureAnimation(animRedWndPieces, iconSize[1], iconSize[2])
        ImGui.SetCursorPosX(x+2)
        ImGui.SetCursorPosY(y+2)
        iconSize = {26,26}
    else
        ImGui.BeginGroup()
        ImGui.Button(string.format('##spell-%s', context))
        animSpellIcons:SetTextureCell(spellIcon(spellID))
        ImGui.DrawTextureAnimation(animSpellIcons, iconSize[1], iconSize[2])
        ImGui.EndGroup()
    end
    local isChanged, category, newSpellID = drawSpellPicker(context)
    if isChanged then
        elixir:DebugPrintf("spell picker got %s %d", category, newSpellID)
    end
end