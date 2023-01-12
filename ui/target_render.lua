---@type Element
local targetElement = {}
targetElement.Index = 8
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

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(targetElement.Title, elixir.Config.IsTargetAI)
    if isCheckboxChanged then
        elixir.Config.IsTargetAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Target AI. Works only when in a group and group has a main assist")

    ImGui.BeginDisabled(not elixir.Config.IsTargetAI)

    ImGui.PushItemWidth(100)
    local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Maximum Range", elixir.Config.TargetAssistMaxRange, 1, 250, "%d")
    if isSliderChanged then
        isChanged = true
        elixir.Config.TargetAssistMaxRange = isNewSliderValue
    end
    ImGui.SameLine()
    HelpMarker("Maximum range to assist to target")

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Pet Assist", elixir.Config.IsTargetPetAssist)
    if isCheckboxChanged then
        elixir.Config.IsTargetPetAssist = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Use /pet attack on assist target if player owns a pet.")

    --TODO TargetAssistMaxRange

    ImGui.EndDisabled() -- IsTargetAI
    ImGui.EndGroup()
    return isChanged
end

targetElement.Render = targetRender
return targetElement