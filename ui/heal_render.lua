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

    --- TODO: Healing Normal Pct

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

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(element.FocusIcon .. " Focus Healing", elixir.Config.IsHealFocus)
    if isCheckboxChanged then
        elixir.Config.IsHealFocus = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, healing will focus a single spawn that you wish to prioritize over normal healing logic.\nThis is used for cases such as a primary tank needing priority heals while AEs are going off.")
    
    --ImGui.BeginDisabled(elixir.Config.IsHealAI and not elixir.Config.IsHealFocus)

    --- TODO: Focus Healing Name
    --- TODO: Focus Healing Normal Pct
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
    ImGui.EndDisabled() -- heal

    ImGui.EndGroup()
    return isChanged
end

healElement.Render = elixirRender
return healElement