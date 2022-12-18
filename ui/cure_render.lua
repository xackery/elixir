---@type Element
local cureElement = {}
cureElement.Index = 7
cureElement.Icon = '\xee\x95\x88'
cureElement.FocusIcon = '\xee\x8f\xb3'
cureElement.Title = cureElement.Icon .. ' Cure AI'

---@returns isChanged boolean # if a config change is detected, returns true
local function elixirRender()
    local element = cureElement
    if elixir.SettingsTabIndex ~= element.Index then
        return false
    end
    local isChanged
    ImGui.BeginGroup()

    local isNewCheckboxValue, isCheckboxChanged = ImGui.Checkbox(cureElement.Title, elixir.Config.IsCureAI)
    if isCheckboxChanged then
        elixir.Config.IsCureAI = isNewCheckboxValue
        isChanged = true
    end
    ImGui.SameLine()
    HelpMarker("Enable Cure AI. This enables all cure over time logic globally")
    
    ImGui.BeginDisabled(not elixir.Config.IsCureAI)

    ImGui.PushItemWidth(100)
    if not elixir.CureAI.IsCureNormalSoundValid then
        ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.28, 0.28, 1)
    end
    
    local isNewTextValue, isTextChanged = ImGui.InputText("Normal Alert", elixir.Config.CureNormalSound)
    if not elixir.CureAI.IsCureNormalSoundValid then
        ImGui.PopStyleColor(1)
    end
    if isTextChanged then
        isChanged = true
        elixir.Config.CureNormalSound = isNewTextValue
        local f = io.open(string.format("%s/elixir/%s.wav", elixir.ConfigPath, elixir.Config.CureNormalSound))
        print(string.format("%s/elixir/%s.wav", elixir.ConfigPath, elixir.Config.CureNormalSound))
        if f ~= nil then
            elixir.CureAI.IsCureNormalSoundValid = true
            io.close(f)
        else
            elixir.CureAI.IsCureNormalSoundValid = false
        end
    end
    ImGui.SameLine()
    HelpMarker(string.format("Attempt to use provided alert when a cure is casted. Place a wav in %s\\elixir\\ and type just the base filename in the field", elixir.ConfigPath))


    --local isNewSliderValue, isSliderChanged = ImGui.SliderInt("Refresh Rate", elixir.Config.CureCheckRateSeconds, 1, 36, "%d Seconds")
    --if isSliderChanged then
    --    isChanged = true
    --    elixir.Config.CureCheckRateSeconds = isNewSliderValue
    --end
    --ImGui.SameLine()
    --HelpMarker("How often to check for cures on party members.")
    ImGui.EndDisabled() -- cure

    ImGui.EndGroup()
    return isChanged
end

cureElement.Render = elixirRender
return cureElement