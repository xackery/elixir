---@type Element
local buffElement = {}
buffElement.Index = 12
buffElement.Icon = '\xef\x81\xa2'
buffElement.Title = buffElement.Icon .. ' Buff AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function buffRender()
    local element = buffElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(buffElement.Title, elixir.Config.IsBuffAI)
    if isCheckboxChanged then
        elixir.Config.IsBuffAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Buff AI. This handles all buff logic")

    -- TODO: spell picker https://github.com/aquietone/maui/blob/181fa9094cfbb6ee3dd53ab00da14ed59b7c28e0/ma/start.lua#L342

    ImGui.BeginDisabled(not elixir.Config.IsBuffAI)


    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Subtle Casting", elixir.Config.IsBuffSubtleCasting)
    if isCheckboxChanged then
        elixir.Config.IsBuffSubtleCasting = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, if aggro is greater than 80% on target, do not try to buff at risk of getting attacked.")

    ImGui.EndDisabled()
    ImGui.EndGroup()
    return isChanged
end

buffElement.Render = buffRender
return buffElement