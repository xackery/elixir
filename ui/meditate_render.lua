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

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(meditateElement.Title, elixir.Config.IsMeditateAI)
    if isCheckboxChanged then
        elixir.Config.IsMeditateAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Meditate AI. This will make the player sit when possible")

    if not elixir.Config.IsMeditateAI then
        ImGui.BeginDisabled()
    end

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Meditate During Combat", elixir.Config.IsMeditateDuringCombat)
    if isCheckboxChanged then
        elixir.Config.IsMeditateDuringCombat = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, when you are in combat, still try to meditate")

    if not elixir.Config.IsMeditateDuringCombat then
        ImGui.BeginDisabled()
    end

    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("Subtle Meditating", elixir.Config.IsMeditateSubtle)
    if isCheckboxChanged then
        elixir.Config.IsMeditateSubtle = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When enabled, if aggro is greater than 80% on any XTarget, do not try to sit to meditate")

    if not elixir.Config.IsMeditateDuringCombat then
        ImGui.EndDisabled()
    end
    
    if not elixir.Config.IsMeditateAI then
        ImGui.EndDisabled()
    end
    ImGui.EndGroup()
    return isChanged
end

meditateElement.Render = meditateRender
return meditateElement