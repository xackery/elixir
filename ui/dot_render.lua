---@type Element
local dotElement = {}
dotElement.Index = 10
dotElement.Icon = '\xef\x84\xae'
dotElement.Title = dotElement.Icon .. ' Dot AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function dotRender()
    local element = dotElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(dotElement.Title, elixir.Config.IsDotAI)
    if isCheckboxChanged then
        elixir.Config.IsDotAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Dot AI. This handles all dot logic")

    ImGui.BeginDisabled(not elixir.Config.IsDotAI)

    
    ImGui.PushItemWidth(100)
    local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Start At", elixir.Config.DotPctNormal, 1, 99, "%d%% HP")
    if isSliderChanged then
        isChanged = true
        elixir.Config.elixir.Config.DotPctNormal = isNewSliderValue
    end
    ImGui.SameLine()
    HelpMarker("Wait until target has at least the threshold in hitpoints before nuking")

    ImGui.PushItemWidth(100)
    local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Until I Have", elixir.Config.DotPctMinMana, 1, 99, "%d%% Mana")
    if isSliderChanged then
        isChanged = true
        elixir.Config.elixir.Config.DotPctMinMana = isNewSliderValue
    end
    ImGui.SameLine()
    HelpMarker("Stop nuking when you hit the limit")

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Subtle Casting", elixir.Config.IsDotSubtleCasting)
    if isCheckboxChanged then
        elixir.Config.IsDotSubtleCasting = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, if aggro is greater than 80% on target, do not try to dot at risk of getting attacked.")

    ImGui.EndDisabled()
    ImGui.EndGroup()
    return isChanged
end

dotElement.Render = dotRender
return dotElement