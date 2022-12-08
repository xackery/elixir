require('ui/render')

function PushRed4Imgui()
    ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.5, 0.5, 0.5)
    ImGui.PushStyleColor(ImGuiCol.Tab, 0, 0, 1, 0.5)
    ImGui.PushStyleColor(ImGuiCol.TabHovered, 0.15, 0.15, 1, 0.5)
    ImGui.PushStyleColor(ImGuiCol.TabHovered, 0.05, 0.05, 1, 0.5)
end

function PushGreen4Imgui()
    ImGui.PushStyleColor(ImGuiCol.Text, 0.5, 1.0, 0.5, 0.5)
    ImGui.PushStyleColor(ImGuiCol.Tab, 0, 0, 1, 0.5)
    ImGui.PushStyleColor(ImGuiCol.TabHovered, 0.15, 0.15, 1, 0.5)
    ImGui.PushStyleColor(ImGuiCol.TabHovered, 0.05, 0.05, 1, 0.5)
end

---@param desc string # Text to display on helpmarker tooltip 
function HelpMarker(desc)
    ImGui.TextDisabled('\xef\x8a\x9c')
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35.0)
        ImGui.Text(desc)
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end