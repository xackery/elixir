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

    ImGui.Text("Ignoring Gems disables certain gems from ever being used by Elixir.\nThis can be useful when Elixir is using them in undesirable ways, or you want to the reserve casting them in your own situations.")

    if elixir.MaxGemCount then
        for i = 1, elixir.MaxGemCount do
            local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(string.format("Gem %d: %s", i, elixir.Gems[i].SpellName), elixir.Gems[i].IsIgnored)
            if isCheckboxChanged then
                elixir.Config["IsGem"..i.."Ignored"] = isNewCheckboxValue
                elixir.Gems[i].IsIgnored = isNewCheckboxValue
                isChanged = true
            end
        end
    end
   
    ImGui.SameLine()
    HelpMarker("When this EQ window is focused, should Elixir continue running?\nHelpful if you like to tab and take over this character.\nThis means AI will only run when this EQ window is in background.")

    ImGui.EndGroup()
    return isChanged
end

ignoreGemsElement.Render = elixirRender
return ignoreGemsElement