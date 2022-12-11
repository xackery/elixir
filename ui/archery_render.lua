---@type Element
local archeryElement = {}
archeryElement.Index = 13
archeryElement.Icon = '\xee\x8c\x95'
archeryElement.Title = archeryElement.Icon .. ' Archery AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function archeryRender()
    local element = archeryElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(archeryElement.Title, elixir.Config.IsArcheryAI)
    if isCheckboxChanged then
        elixir.Config.IsArcheryAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Archery AI. This will turn on autofire when assisting")

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Subtle Casting", elixir.Config.IsArcherySubtle)
    if isCheckboxChanged then
        elixir.Config.IsArcherySubtle = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, autofire is turned off when aggro is too high.")

    ImGui.EndGroup()
    return isChanged
end

archeryElement.Render = archeryRender
return archeryElement