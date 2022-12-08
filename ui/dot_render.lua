---@type Element
local dotElement = {}
dotElement.Index = 8
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

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(dotElement.Title, elixir.Config.IsHealAI)
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

dotElement.Render = dotRender
return dotElement