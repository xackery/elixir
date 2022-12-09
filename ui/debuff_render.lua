---@type Element
local debuffElement = {}
debuffElement.Index = 9
debuffElement.Icon = '\xef\x83\xbc'
debuffElement.Title = debuffElement.Icon .. ' Debuff AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function debuffRender()
    local element = debuffElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(debuffElement.Title, elixir.Config.IsDebuffAI)
    if isCheckboxChanged then
        elixir.Config.IsDebuffAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Debuff AI. This handles all debuff logic")

    ImGui.BeginDisabled(not elixir.Config.IsDebuffAI)

    -- TODO: debuffpctnormal

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Subtle Casting", elixir.Config.IsDebuffSubtleCasting)
    if isCheckboxChanged then
        elixir.Config.IsDebuffSubtleCasting = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, if aggro is greater than 80% on target, do not try to debuff at risk of getting attacked.")

    ImGui.EndDisabled()
    ImGui.EndGroup()
    return isChanged
end

debuffElement.Render = debuffRender
return debuffElement