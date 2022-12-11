---@type Element
local stunElement = {}
stunElement.Index = 3
stunElement.Icon = '\xef\x84\xad'
stunElement.Title = stunElement.Icon .. ' Stun AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function stunRender()
    local element = stunElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(stunElement.Title, elixir.Config.IsStunAI)
    if isCheckboxChanged then
        elixir.Config.IsStunAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Stun AI. This is primarily useful for enchanters who are going to be AE chain mezzing.")

    ImGui.BeginDisabled(not elixir.Config.IsStunAI)

    ImGui.EndDisabled()
    ImGui.EndGroup()
    return isChanged
end

stunElement.Render = stunRender
return stunElement