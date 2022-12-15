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

    ImGui.PushItemWidth(100)
    local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Start At", elixir.Config.DebuffPctNormal, 1, 99, "%d%% HP")
    if isSliderChanged then
        isChanged = true
        elixir.Config.elixir.Config.DebuffPctNormal = isNewSliderValue
    end
    ImGui.SameLine()
    HelpMarker("Wait until target has at least the threshold in hitpoints before debuffing")

    ImGui.PushItemWidth(100)
    local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Until I Have", elixir.Config.DebuffPctMinMana, 1, 99, "%d%% Mana")
    if isSliderChanged then
        isChanged = true
        elixir.Config.elixir.Config.DebuffPctMinMana = isNewSliderValue
    end
    ImGui.SameLine()
    HelpMarker("Stop debuffing when you hit the limit")

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Subtle Casting", elixir.Config.IsDebuffSubtleCasting)
    if isCheckboxChanged then
        elixir.Config.IsDebuffSubtleCasting = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, if aggro is greater than 80% on target, do not try to debuff at risk of getting attacked.")

    ImGui.PushItemWidth(100)
    local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Retry", elixir.Config.DebuffRetryCount, 0, 10, "%d Times")
    if isSliderChanged then
        isChanged = true
        elixir.Config.DebuffRetryCount = isNewSliderValue
    end
    ImGui.SameLine()
    HelpMarker("If your spell is resisted, try this many times to recast each debuff.")

    ImGui.EndDisabled()
    ImGui.EndGroup()
    return isChanged
end

debuffElement.Render = debuffRender
return debuffElement