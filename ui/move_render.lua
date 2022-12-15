---@type Element
local moveElement = {}
moveElement.Index = 13
moveElement.Icon = '\xee\x94\xb6'
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