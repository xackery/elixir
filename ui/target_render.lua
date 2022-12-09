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
    HelpMarker("Enable Target AI. Works only when in a group and group has a main assist")

    ImGui.BeginDisabled(not elixir.Config.IsTargetAI)

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Pet Assist", elixir.Config.IsTargetPetAssist)
    if isCheckboxChanged then
        elixir.Config.IsTargetPetAssist = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Use /pet attack on assist target if player owns a pet.")

    --TODO TargetMinRange

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Auto Attack", elixir.Config.IsTargetAutoAttack)
    if isCheckboxChanged then
        elixir.IsTargetAutoAttack = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("If target is less than 20, turn on auto attack")

    ImGui.EndDisabled()
    ImGui.EndGroup()
    return isChanged
end

targetElement.Render = targetRender
return targetElement