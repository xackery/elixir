---@type Element
local nukeElement = {}
nukeElement.Index = 11
nukeElement.Icon = '\xef\x83\xa7'
nukeElement.Title = nukeElement.Icon .. ' Nuke AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function nukeRender()
    local element = nukeElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(nukeElement.Title, elixir.Config.IsNukeAI)
    if isCheckboxChanged then
        elixir.Config.IsNukeAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Nuke AI. This handles all nuke logic")

    ImGui.BeginDisabled(not elixir.Config.IsNukeAI)

    ImGui.PushItemWidth(100)
    local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Start At", elixir.Config.NukePctNormal, 1, 99, "%d%% HP")
    if isSliderChanged then
        isChanged = true
        elixir.Config.elixir.Config.NukePctNormal = isNewSliderValue
    end
    ImGui.SameLine()
    HelpMarker("Wait until target has at least the threshold in hitpoints before nuking")

    ImGui.PushItemWidth(100)
    local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Until I Have", elixir.Config.NukePctMinMana, 1, 99, "%d%% Mana")
    if isSliderChanged then
        isChanged = true
        elixir.Config.elixir.Config.NukePctMinMana = isNewSliderValue
    end
    ImGui.SameLine()
    HelpMarker("Stop nuking when you hit the limit")

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Subtle Casting", elixir.Config.IsNukeSubtleCasting)
    if isCheckboxChanged then
        elixir.Config.IsNukeSubtleCasting = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, if aggro is greater than 80% on target, do not try to nuke at risk of getting attacked.")

    ImGui.EndDisabled()
    ImGui.EndGroup()
    return isChanged
end

nukeElement.Render = nukeRender
return nukeElement