---@type Element
local healElement = {}
healElement.Index = 2
healElement.Icon = '\xee\x8f\xb3'
healElement.FocusIcon = '\xee\x95\xaa'
healElement.Title = healElement.Icon .. ' Heal AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function elixirRender()
    local element = healElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(healElement.Title, elixir.Config.IsHealAI)
    if isCheckboxChanged then
        elixir.Config.IsHealAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Heal AI. This enables all healing logic globally")
    
    ImGui.BeginDisabled(not elixir.Config.IsHealAI)
    
    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(element.FocusIcon .. " Focus Healing", elixir.Config.IsHealFocus)
    if isCheckboxChanged then
        elixir.Config.IsHealFocus = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, healing will focus a single spawn that you wish to prioritize over normal healing logic.\nThis is used for cases such as a primary tank needing priority heals while AEs are going off.")
    
    --ImGui.BeginDisabled(elixir.Config.IsHealAI and not elixir.Config.IsHealFocus)

    --- TODO: Focus Healing Name
    --local isNewComboValue, isComboChanged = ImGui.Combo("Focus Target", elixir.Config.HealFocusID, elixir.Allies, #elixir.Allies)
    ImGui.PushItemWidth(100)
    if ImGui.BeginCombo("Focus Target", elixir.HealAI.HealFocusName) then
        for spawnID, name in pairs(elixir.Allies) do
            local isSelected = elixir.Config.HealFocusID == spawnID
            if ImGui.Selectable(name, isSelected) then -- fixme: selectable
                elixir.Config.HealFocusID = spawnID
                elixir.HealAI.HealFocusName = name
            end

            -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
            if isSelected then
                ImGui.SetItemDefaultFocus()
            end
        end

        ImGui.EndCombo()
    end
    ImGui.SameLine()
    HelpMarker("Target to heal focus.")
    
    ImGui.PushItemWidth(100)
    local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Focus Normal Threshold", elixir.Config.HealFocusPctNormal, 1, 99, "%d%% HP")
    if isSliderChanged then
        isChanged = true
        elixir.Config.HealFocusPctNormal = isNewSliderValue
    end
    ImGui.SameLine()
    HelpMarker("When focus target hits this threshold, heal them")

    if not elixir.HealAI.IsHealFocusNormalSoundValid then
        ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.28, 0.28, 1)
    end    
    local isNewTextValue, isTextChanged = ImGui.InputText("Focus Normal Alert", elixir.Config.HealFocusNormalSound)
    if not elixir.HealAI.IsHealFocusNormalSoundValid then
        ImGui.PopStyleColor(1)
    end
    if isTextChanged then
        isChanged = true
        elixir.Config.HealFocusNormalSound = isNewTextValue
        local f = io.open(string.format("%s/elixir/%s.wav", elixir.ConfigPath, elixir.Config.HealFocusNormalSound))
        print(string.format("%s/elixir/%s.wav", elixir.ConfigPath, elixir.Config.HealFocusNormalSound))
        if f ~= nil then
            elixir.HealAI.IsHealFocusNormalSoundValid = true
            io.close(f)
        else
            elixir.HealAI.IsHealFocusNormalSoundValid = false
        end
    end
    ImGui.SameLine()
    HelpMarker(string.format("Attempt to use provided alert when a heal is casted. Place a wav in %s\\elixir\\ and type just the base filename in the field", elixir.ConfigPath))


    --- TODO: Focus Healing Spell ID

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Focus Emergency Healing", elixir.Config.IsHealFocusEmergencyAllowed)
    if isCheckboxChanged then
        elixir.Config.IsHealFocusEmergencyAllowed = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, try to use emergency heals to try to save a bad situation.\nNote that this will priotize AAs such Divine Arbitration, Celestial Regeneration, and quick casting spells that are not mana efficient to try to save the at risk focused ally.")

    --ImGui.BeginDisabled(elixir.Config.IsHealAI and elixir.Config.IsHealFocus and not elixir.Config.IsHealFocusEmergencyAllowed)
    
    --- TODO: Focus Healing Emergency Pct

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Focus Predict Emergencies", elixir.Config.IsHealFocusEmergencyPredictive)
    if isCheckboxChanged then
        elixir.Config.IsHealFocusEmergencyPredictive = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, Emergency Healing will also be used in cases an ally takes 40% of max health in a short amount of time, predicting a potential emergency situation, but may cause prematurely healing too.")

    --ImGui.EndDisabled() -- focus emergency heal

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Focus Fallback Healing", elixir.Config.IsHealFocusFallback)
    if isCheckboxChanged then
        elixir.Config.IsHealFocusFallback = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, if focus target does not meet requirement to need a heal, fallback to trying to heal other allies.")

    --ImGui.EndDisabled() -- heal focus

    ImGui.Separator()

    ImGui.PushItemWidth(100)
    local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Normal Threshold", elixir.Config.HealPctNormal, 1, 99, "%d%% HP")
    if isSliderChanged then
        isChanged = true
        elixir.Config.HealPctNormal = isNewSliderValue
    end
    ImGui.SameLine()
    HelpMarker("Use normal heals on allies when they meet this threshold")

    if not elixir.HealAI.IsHealNormalSoundValid then
        ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.28, 0.28, 1)
    end    
    local isNewTextValue, isTextChanged = ImGui.InputText("Normal Alert", elixir.Config.HealNormalSound)
    if not elixir.HealAI.IsHealNormalSoundValid then
        ImGui.PopStyleColor(1)
    end
    if isTextChanged then
        isChanged = true
        elixir.Config.HealNormalSound = isNewTextValue
        local f = io.open(string.format("%s/elixir/%s.wav", elixir.ConfigPath, elixir.Config.HealNormalSound))
        print(string.format("%s/elixir/%s.wav", elixir.ConfigPath, elixir.Config.HealNormalSound))
        if f ~= nil then
            elixir.HealAI.IsHealNormalSoundValid = true
            io.close(f)
        else
            elixir.HealAI.IsHealNormalSoundValid = false
        end
    end
    ImGui.SameLine()
    HelpMarker(string.format("Attempt to use provided alert when a heal is casted. Place a wav in %s\\elixir\\ and type just the base filename in the field", elixir.ConfigPath))

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Heal Pets", elixir.Config.IsHealPets)
    if isCheckboxChanged then
        elixir.Config.IsHealPets = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Heal pets of known allies, this will include raid and xtarget pets if included")

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Heal Raid", elixir.Config.IsHealRaid)
    if isCheckboxChanged then
        elixir.Config.IsHealRaid = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Heal raid members of known allies")

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Heal XTarget", elixir.Config.IsHealXTarget)
    if isCheckboxChanged then
        elixir.Config.IsHealXTarget = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Heal xtargets when set to players")

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Subtle Casting", elixir.Config.IsHealSubtleCasting)
    if isCheckboxChanged then
        elixir.Config.IsHealSubtleCasting = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, if aggro is greater than 80% on any XTarget, do not try to heal at risk of getting attacked.\nNote that Emergency Healing, if enabled, will ignore Subtle Casting since the situation is considered dire.")


    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Emergency Healing", elixir.Config.IsHealEmergencyAllowed)
    if isCheckboxChanged then
        elixir.Config.IsHealEmergencyAllowed = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, try to use emergency heals to try to save a bad situation.\nNote that this will prioritize AAs such Divine Arbitration, Celestial Regeneration, and quick casting spells that are not mana efficient to try to save the at risk ally.")    
    
    ImGui.PushItemWidth(100)
    local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Emergency Threshold", elixir.Config.HealPctEmergency, 1, 99, "%d%% HP")
    if isSliderChanged then
        isChanged = true
        elixir.Config.HealPctEmergency = isNewSliderValue
    end
    ImGui.SameLine()
    HelpMarker("Use emergency heals on allies when they meet this threshold")

    if not elixir.HealAI.IsHealEmergencySoundValid then
        ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.28, 0.28, 1)
    end    
    local isNewTextValue, isTextChanged = ImGui.InputText("Emergency Alert", elixir.Config.HealEmergencySound)
    if not elixir.HealAI.IsHealEmergencySoundValid then
        ImGui.PopStyleColor(1)
    end
    if isTextChanged then
        isChanged = true
        elixir.Config.HealEmergencySound = isNewTextValue
        local f = io.open(string.format("%s/elixir/%s.wav", elixir.ConfigPath, elixir.Config.HealEmergencySound))
        print(string.format("%s/elixir/%s.wav", elixir.ConfigPath, elixir.Config.HealEmergencySound))
        if f ~= nil then
            elixir.HealAI.IsHealEmergencySoundValid = true
            io.close(f)
        else
            elixir.HealAI.IsHealEmergencySoundValid = false
        end
    end
    ImGui.SameLine()
    HelpMarker(string.format("Attempt to use provided alert when a heal is casted. Place a wav in %s\\elixir\\ and type just the base filename in the field", elixir.ConfigPath))
    
    
    --ImGui.BeginDisabled(elixir.Config.IsHealAI and not elixir.Config.IsHealEmergencyAllowed)

    --- TODO: Healing Emergency Pct

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Predict Emergencies", elixir.Config.IsHealEmergencyPredictive)
    if isCheckboxChanged then
        elixir.Config.IsHealEmergencyPredictive = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, Emergency Healing will also be used in cases an ally takes 40% of max health in a short amount of time, predicting a potential emergency situation, but may cause prematurely healing too.")
    
    --ImGui.EndDisabled() -- heal emergency

    ImGui.EndDisabled() -- heal

    ImGui.EndGroup()
    return isChanged
end

healElement.Render = elixirRender
return healElement