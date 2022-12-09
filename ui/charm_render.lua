---@type Element
local charmElement = {}
charmElement.Index = 3
charmElement.Icon = '\xef\x81\xa9'
charmElement.Title = charmElement.Icon .. ' Charm AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function charmRender()
    local element = charmElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(charmElement.Title, elixir.Config.IsCharmAI)
    if isCheckboxChanged then
        elixir.Config.IsCharmAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Charm AI. This handles all charm logic")

    if not elixir.Config.IsCharmAI then
        ImGui.BeginDisabled()
    end

    if not elixir.Config.IsCharmAI then
        ImGui.EndDisabled()
    end
    ImGui.EndGroup()
    return isChanged
end

charmElement.Render = charmRender
return charmElement