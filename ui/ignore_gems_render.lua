---@type Element
local ignoreGemsElement = {}
ignoreGemsElement.Index = 1
ignoreGemsElement.Icon = '\xef\x88\x99'
ignoreGemsElement.Title = ignoreGemsElement.Icon .. ' Ignore Gems'
ignoreGemsElement.IsTitleSeperatorAfter = true

---@returns isChanged boolean # if a config change is detected, returns true
local function elixirRender()
    local element = ignoreGemsElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()
    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox("\xef\x81\xb0 Disable Elixir AIs When Window Has Focus", elixir.Config.IsElixirDisabledOnFocus)
    if isCheckboxChanged then
        elixir.Config.IsElixirDisabledOnFocus = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("When this EQ window is focused, should Elixir continue running?\nHelpful if you like to tab and take over this character.\nThis means AI will only run when this EQ window is in background.")

    ImGui.EndGroup()
    return isChanged
end

ignoreGemsElement.Render = elixirRender
return ignoreGemsElement