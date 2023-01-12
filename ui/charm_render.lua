---@type Element
local charmElement = {}
charmElement.Index = 4
charmElement.Icon = '\xef\x81\xa9'
charmElement.Title = charmElement.Icon .. ' Charm AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function charmRender()
    local element = charmElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    local isDisabled
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(charmElement.Title, elixir.Config.IsCharmAI)
    if isCheckboxChanged then
        elixir.Config.IsCharmAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Charm AI. This handles all charm logic")

    ImGui.BeginDisabled(not elixir.Config.IsCharmAI)
    ImGui.Text("Current Charm Target: ".. elixir.CharmAI.Name)
    if ImGui.Button("Set Charm Target To "..elixir.CharmAI.LastTargetName) then
        elixir.CharmAI.ID = elixir.CharmAI.LastTargetID
        elixir.CharmAI.Name = elixir.CharmAI.LastTargetName
    end
    ImGui.EndDisabled() -- elixir.CharmAI.IsCurrentTargetValid
    ImGui.BeginDisabled(elixir.CharmAI.ID == 0)
    if ImGui.Button("Clear Charm") then
       elixir.CharmAI.ID = 0
       elixir.CharmAI.Name = "None"
    end
    ImGui.EndDisabled() -- elixir.CharmAI.ID == 0

    ImGui.EndDisabled() -- elixir.Config.IsCharmAI

    ImGui.EndGroup()
    return isChanged
end

charmElement.Render = charmRender
return charmElement