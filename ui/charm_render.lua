---@type Element
local charmElement = {}
charmElement.Index = 3
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

    ImGui.Text("Current Charm Target: ".. elixir.CharmAI.Name)
    --ImGui.BeginDisabled(not elixir.Config.IsCharmAI)
    --ImGui.BeginDisabled(elixir.CharmAI.IsCurrentTargetValid)
    if ImGui.Button("Set Charm Target") then
       elixir.CharmAI.ID = mq.TLO.Target.ID()
       elixir.CharmAI.Name = mq.TLO.Target.Name()
    end
    --ImGui.EndDisabled() -- elixir.CharmAI.IsCurrentTargetValid
    --ImGui.BeginDisabled(elixir.CharmAI.ID == 0)
    if ImGui.Button("Clear Charm") then
       elixir.CharmAI.ID = 0
       elixir.CharmAI.Name = "None"
    end
    --ImGui.EndDisabled() -- elixir.CharmAI.ID == 0
    --ImGui.EndDisabled() -- elixir.Config.IsCharmAI

    ImGui.EndGroup()
    return isChanged
end

charmElement.Render = charmRender
return charmElement