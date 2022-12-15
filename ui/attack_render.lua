---@type Element
local attackElement = {}
attackElement.Index = 15
attackElement.Icon = '\xef\x81\x9b'
attackElement.Title = attackElement.Icon .. ' Attack AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function attackRender()
    local element = attackElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(attackElement.Title, elixir.Config.IsAttackAI)
    if isCheckboxChanged then
        elixir.Config.IsAttackAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Attack AI. This will turn on attack when assisting")

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Subtle Attacking", elixir.Config.IsAttackSubtle)
    if isCheckboxChanged then
        elixir.Config.IsAttackSubtle = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, if you have aggro and a tank is alive in group or raid and nearby, your attack is turned off until you lose hate.")

    ImGui.EndGroup()
    return isChanged
end

attackElement.Render = attackRender
return attackElement