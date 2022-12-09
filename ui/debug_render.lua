---@type Element
local debugElement = {}
debugElement.Index = 10
debugElement.Icon = '\xee\xa1\xa8'
debugElement.Title = debugElement.Icon .. ' Debugger'

---@returns isChanged boolean # if a config change is detected, returns true
local function debugRender()
    local element = debugElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()
    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(element.Icon .." Enable Debug Mode", elixir.Config.IsDebugEnabled)
    if isCheckboxChanged then
        elixir.Config.IsDebugEnabled = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When this EQ window is focused, should Elixir continue running?\nHelpful if you like to tab and take over this character.\nThis means AI will only run when this EQ window is in background.")


    if not elixir.Config.IsDebugEnabled or not elixir.HealAI.Output then
        ImGui.EndGroup()
        return false
    end

    ImGui.Text("Last Action: " .. elixir.LastActionOutput)
    ImGui.Separator()
    ImGui.Text("Heal AI: " .. elixir.HealAI.Output)
    ImGui.Text("Charm AI: " .. elixir.CharmAI.Output)
    ImGui.Text("Target AI: " .. elixir.TargetAI.Output)
    ImGui.Text("Debuff AI: " .. elixir.DebuffAI.Output)
    ImGui.Text("Dot AI: " .. elixir.DotAI.Output)
    ImGui.Text("Nuke AI: " .. elixir.NukeAI.Output)
    ImGui.Text("Buff AI: " .. elixir.BuffAI.Output)
    ImGui.Text("Meditate AI: " .. elixir.MeditateAI.Output)
    ImGui.Separator()
    if elixir.MaxGemCount then
        for i = 1, elixir.MaxGemCount do
            ImGui.Text("Gem "..(i)..": " .. elixir.Gems[i].Output)
        end
    end
    ImGui.EndGroup()
    return isChanged
end

debugElement.Render = debugRender
return debugElement