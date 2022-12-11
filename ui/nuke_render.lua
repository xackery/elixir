---@type Element
local nukeElement = {}
nukeElement.Index = 10
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

    -- TODO: nukepctnormal

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