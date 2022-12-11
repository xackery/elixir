---@type Element
local dotElement = {}
dotElement.Index = 9
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

    -- TODO: dotpctnormal

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