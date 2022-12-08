---@type Element
local targetElement = {}
targetElement.Index = 5
targetElement.Icon = '\xef\x85\x80'
targetElement.Title = targetElement.Icon .. ' Target AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function targetRender()
    local element = targetElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(targetElement.Title, elixir.Config.IsHealAI)
    if isCheckboxChanged then
        elixir.Config.IsHealAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Heal AI. This handles all heal logic")

    if not elixir.Config.IsHealAI then
        ImGui.BeginDisabled()
    end
    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("\xef\x81\xb0 Disable Elixir AIs When Window Has Focus", elixir.Config.IsElixirDisabledOnFocus)
    if isCheckboxChanged then
        elixir.Config.IsElixirDisabledOnFocus = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When this EQ window is focused, should Elixir continue running?\nHelpful if you like to tab and take over this character.\nThis means AI will only run when this EQ window is in background.")

    if not elixir.Config.IsHealAI then
        ImGui.EndDisabled()
    end
    ImGui.EndGroup()
    return isChanged
end

targetElement.Render = targetRender
return targetElement