---@type Element
local meditateElement = {}
meditateElement.Index = 4
meditateElement.Icon = '\xee\x95\x8b'
meditateElement.Title = meditateElement.Icon .. ' Meditate AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function meditateRender()
    local element = meditateElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(meditateElement.Title, elixir.Config.IsHealAI)
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

meditateElement.Render = meditateRender
return meditateElement