---@type Element
local mezElement = {}
mezElement.Index = 6
mezElement.Icon = '\xef\x83\xbc'
mezElement.Title = mezElement.Icon .. ' Mez AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function mezRender()
    local element = mezElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(mezElement.Title, elixir.Config.IsMezAI)
    if isCheckboxChanged then
        elixir.Config.IsMezAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Mez AI. This handles all mez logic")

    ImGui.BeginDisabled(not elixir.Config.IsMezAI)

    -- TODO: mezpctnormal

    ImGui.EndDisabled()
    ImGui.EndGroup()
    return isChanged
end

mezElement.Render = mezRender
return mezElement