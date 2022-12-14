---@type Element
local hotElement = {}
hotElement.Index = 5
hotElement.Icon = '\xee\x80\xa1'
hotElement.FocusIcon = '\xee\x8f\xb3'
hotElement.Title = hotElement.Icon .. ' Hot AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function elixirRender()
    local element = hotElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(hotElement.Title, elixir.Config.IsHotAI)
    if isCheckboxChanged then
        elixir.Config.IsHotAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Hot AI. This enables all heal over time logic globally")
    
    ImGui.BeginDisabled(not elixir.Config.IsHotAI)

    ImGui.PushItemWidth(100)
    local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Normal Threshold", elixir.Config.HotPctNormal, 1, 99, "%d%% HP")
    if isSliderChanged then
        isChanged = true
        elixir.Config.HotPctNormal = isNewSliderValue
    end
    ImGui.SameLine()
    HelpMarker("Use normal heals on allies when they meet this threshold")

    if not elixir.HotAI.IsHotNormalSoundValid then
        ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.28, 0.28, 1)
    end    
    local isNewTextValue, isTextChanged = ImGui.InputText("Normal Alert", elixir.Config.HotNormalSound)
    if not elixir.HotAI.IsHotNormalSoundValid then
        ImGui.PopStyleColor(1)
    end
    if isTextChanged then
        isChanged = true
        elixir.Config.HotNormalSound = isNewTextValue
        local f = io.open(string.format("%s/elixir/%s.wav", elixir.ConfigPath, elixir.Config.HotNormalSound))
        print(string.format("%s/elixir/%s.wav", elixir.ConfigPath, elixir.Config.HotNormalSound))
        if f ~= nil then
            elixir.HotAI.IsHotNormalSoundValid = true
            io.close(f)
        else
            elixir.HotAI.IsHotNormalSoundValid = false
        end
    end
    ImGui.SameLine()
    HelpMarker(string.format("Attempt to use provided alert when a heal is casted. Place a wav in %s\\elixir\\ and type just the base filename in the field", elixir.ConfigPath))



    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Hot Pets", elixir.Config.IsHotPets)
    if isCheckboxChanged then
        elixir.Config.IsHotPets = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Hot pets of known allies, this will include raid and xtarget pets if included")

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Hot Raid", elixir.Config.IsHotRaid)
    if isCheckboxChanged then
        elixir.Config.IsHotRaid = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Hot raid members of known allies")

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Hot XTarget", elixir.Config.IsHotXTarget)
    if isCheckboxChanged then
        elixir.Config.IsHotXTarget = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Hot xtargets when set to players")

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Subtle Casting", elixir.Config.IsHotSubtleCasting)
    if isCheckboxChanged then
        elixir.Config.IsHotSubtleCasting = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, if aggro is greater than 80% on any XTarget, do not try to hot at risk of getting attacked.\nNote that Emergency heal over time, if enabled, will ignore Subtle Casting since the situation is considered dire.")

        --ImGui.BeginDisabled(elixir.Config.IsHotAI and not elixir.Config.IsHotEmergencyAllowed)

    --ImGui.EndDisabled() -- hot emergency

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(element.FocusIcon .. " Focus Heal over Time", elixir.Config.IsHotFocus)
    if isCheckboxChanged then
        elixir.Config.IsHotFocus = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, this AI will focus a single spawn that you wish to prioritize over normal heal over time logic.\nThis is used for cases such as a primary tank needing exclusive hots while other allies get ignored.")
    
    --ImGui.BeginDisabled(elixir.Config.IsHotAI and not elixir.Config.IsHotFocus)

    --- TODO: Focus heal over time Name
    --- TODO: Focus heal over time Normal Pct
    --- TODO: Focus heal over time Spell ID

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Focus Fallback heal over time", elixir.Config.IsHotFocusFallback)
    if isCheckboxChanged then
        elixir.Config.IsHotFocusFallback = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, if focus target does not meet requirement to need a hot, fallback to trying to hot other allies.")

    --ImGui.EndDisabled() -- hot focus
    ImGui.EndDisabled() -- hot

    ImGui.EndGroup()
    return isChanged
end

hotElement.Render = elixirRender
return hotElement