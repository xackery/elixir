---@type Element
local moveElement = {}
moveElement.Index = 12
moveElement.Icon = '\xef\x81\xa9'
moveElement.Title = moveElement.Icon .. ' Move AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function moveRender()
    local element = moveElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(moveElement.Title, elixir.Config.IsMoveAI)
    if isCheckboxChanged then
        elixir.Config.IsMoveAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Move AI. This will turn on move when assisting")

    ImGui.EndGroup()
    return isChanged
end

moveElement.Render = moveRender
return moveElement