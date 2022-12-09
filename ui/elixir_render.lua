---@type Element
local elixirElement = {}
elixirElement.Index = 0
elixirElement.Icon = '\xef\x83\xba'
elixirElement.Title = elixirElement.Icon .. ' Elixir AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function elixirRender()
    local element = elixirElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(elixirElement.Title, elixir.Config.IsElixirAI)
    if isCheckboxChanged then
        elixir.Config.IsElixirAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Elixir AI. This is a master switch that disables all settings when flipped")

    if not elixir.Config.IsElixirAI then
        ImGui.BeginDisabled()
    end
    
    isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("\xef\x81\xb0 Disable Elixir AIs When Window Has Focus", elixir.Config.IsElixirDisabledOnFocus)
    if isCheckboxChanged then
        elixir.Config.IsElixirDisabledOnFocus = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When this EQ window is focused, should Elixir continue running?\nHelpful if you like to tab and take over this character.\nThis means AI will only run when this EQ window is in background.")

    if not elixir.Config.IsElixirAI then
        ImGui.EndDisabled()
    end
    ImGui.EndGroup()
    return isChanged
end

elixirElement.Render = elixirRender
return elixirElement