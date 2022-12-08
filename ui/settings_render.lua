---@type Element
local settingsElement = {}
settingsElement.Index = 0
settingsElement.Icon = '\xee\x8e\xaa'
settingsElement.Title = settingsElement.Icon .. ' Settings'
settingsElement.IsTitleSeperatorAfter = true

---@returns isChanged boolean # if a config change is detected, returns true
local function settingsRender()
    local element = settingsElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()
    --- TODO: add settings render (if needed)
    ImGui.EndGroup()
    return isChanged
end

settingsElement.Render = settingsRender
return settingsElement