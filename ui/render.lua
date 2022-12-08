---@type Mq
local mq = require('mq')

--- @type ImGui
require 'ImGui'

local settingsElement = require('ui/settings_render')

local elixirElement = require('ui/elixir_render')
local ignoreGemsElement = require('ui/ignore_gems_render')
local healElement = require('ui/heal_render')
local charmElement = require('ui/charm_render')
local meditateElement = require('ui/meditate_render')
local targetElement = require('ui/target_render')
local buffElement = require('ui/buff_render')
local nukeElement = require('ui/nuke_render')
local dotElement = require('ui/dot_render')
local debuffElement = require('ui/debuff_render')
local debugElement = require('ui/debug_render')

---@class Element
---@field Index number # index on selection for element in settings page
---@field Icon string # string of element
---@field Title string # section title to show on settings page
---@field Render function # renderer function for element
---@field IsTitleSeparatorAfter boolean # add a seperator after section title
local elements = {}
elements[elixirElement.Index] = elixirElement
elements[ignoreGemsElement.Index] = ignoreGemsElement
elements[healElement.Index] = healElement
elements[charmElement.Index] = charmElement
elements[meditateElement.Index] = meditateElement
elements[targetElement.Index] = targetElement
elements[buffElement.Index] = buffElement
elements[nukeElement.Index] = nukeElement
elements[dotElement.Index] = dotElement
elements[debuffElement.Index] = debuffElement
elements[debugElement.Index] = debugElement

function SettingsRender()
    if not elixir.Config.IsElixirUIOpen then
        return
    end
    local isOpen, shouldDraw = ImGui.Begin('\xef\x83\xba Elixir '.. elixir.Version .. " Settings", elixir.Config.IsElixirUIOpen)
    ImGui.SetWindowSize(430, 277, ImGuiCond.FirstUseEver)
    if not isOpen then
        elixir.Config.IsElixirUIOpen = false
        ImGui.End()
        return
    end

    local isChanged = false
    ImGui.PushStyleVar(ImGuiStyleVar.FrameBorderSize, 1)
    ImGui.BeginGroup()
    local window_flags = bit32.bor(ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoDocking,
        ImGuiWindowFlags.NoSavedSettings, ImGuiWindowFlags.NoFocusOnAppearing, ImGuiWindowFlags.NoNav)
    ImGui.BeginChild("ai list", 150, -ImGui.GetFrameHeightWithSpacing()-4, true, window_flags)
    --  MD_LOCAL_PHARMACY = '\xee\x95\x90',

    for selectionIndex, element in pairs(elements) do
        _, isClicked = ImGui.Selectable(element.Title, elixir.SettingsTabIndex == selectionIndex)
        if isClicked then elixir.SettingsTabIndex = element.Index end
        if element.IsTitleSeparatorAfter then
            ImGui.Separator()
        end
    end
    ImGui.EndChild()
    ImGui.EndGroup()
    ImGui.PopStyleVar()

    ImGui.SameLine()
    for _, element in pairs(elements) do
        if element.Render() then
            isChanged = true
        end
    end
    ImGui.End()
    if isChanged then
        --TODO: update config
    end
end


local ICON_WIDTH = 40
local ICON_HEIGHT = 40

local className = mq.TLO.Me.Class.Name()
local animBox = mq.FindTextureAnimation(className .. "Icon")


local function enabledIconStyle()
    ImGui.PushStyleColor(ImGuiCol.Text, 0.28, 0.8, 0.28, 1)
end

local function disabledIconStyle()    
    ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.28, 0.28, 1)
end

local function textIconStyle()    
    ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.8, 0.8, 1)
end

function OverlayRender(isOpen)
    local window_flags = bit32.bor(ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoDocking,
        ImGuiWindowFlags.NoSavedSettings, ImGuiWindowFlags.NoFocusOnAppearing, ImGuiWindowFlags.NoNav)

    ImGui.SetNextWindowBgAlpha(0.7)
    
    local isDraw
    isOpen, isDraw = ImGui.Begin("Elixir overlay", true, window_flags)
    ImGui.SetWindowSize(60, 230)
    if isDraw then
        --ImGui.DrawTextureAnimation(mq.TLO.Window("InventoryWindow").Child("IW_Subwindows").Child("IW_InvPage").Child("IW_CharacterView").Child("ClassAnim").
        --ImGui.Text("Elixir " .. elixir.Version)
        ImGui.DrawTextureAnimation(animBox, ICON_WIDTH, ICON_HEIGHT)
        ImGui.SameLine(32)
        textIconStyle()
        ImGui.Text(settingsElement.Icon) -- settings
        ImGui.PopStyleColor(1)
        enabledIconStyle()
        ImGui.Text(elixirElement.Icon) -- elixir
        ImGui.PopStyleColor(1)
        ImGui.SameLine(24)
        disabledIconStyle()
        ImGui.Text('\xef\x81\xb0') -- disable on focus
        ImGui.PopStyleColor(1)
        enabledIconStyle()
        ImGui.Text(healElement.Icon) -- heal
        ImGui.PopStyleColor(1)
        ImGui.SameLine(26)
        textIconStyle()
        ImGui.Text('50%')
        ImGui.PopStyleColor(1)
        disabledIconStyle()
        ImGui.Text('\xef\x81\xa9') -- charm
        ImGui.PopStyleColor(1)
        enabledIconStyle()
        ImGui.Text('\xee\x95\x8b') -- meditate
        ImGui.PopStyleColor(1)
        enabledIconStyle()
        ImGui.Text('\xef\x85\x80') -- target
        ImGui.PopStyleColor(1)
        enabledIconStyle()
        ImGui.Text('\xef\x84\xb2') -- buff
        ImGui.PopStyleColor(1)
        enabledIconStyle()
        ImGui.Text('\xef\x83\xa7') -- nuke
        ImGui.PopStyleColor(1)
        enabledIconStyle()
        ImGui.Text('\xef\x84\xae') -- dot
        ImGui.PopStyleColor(1)
        enabledIconStyle()
        ImGui.Text('\xef\x83\xbc') -- debuff
        ImGui.PopStyleColor(1)
        --local imageIcon = mq.FindTextureAnimation("A_RecessedBox")        
        --ImGui.DrawTextureAnimation(imageIcon, ICON_WIDTH, ICON_HEIGHT)

        --animItems:SetTextureCell(0)
        --ImGui.DrawTextureAnimation(animItems, 16, 16)
        
        --ImGui.DrawTextureAnimation(mq.FindTextureAnimation("MaleRace.tga"), 256, 256)
        --mq.imgui.DrawTextureAnimation(mq.FindTextureAnimation("MaleRace.tga"), 256, 256)
        if ImGui.BeginPopupContextWindow() then
            if ImGui.MenuItem("Elixir Settings") then
                elixir.SettingsTabIndex = 0
                if not elixir.Config.IsElixirUIOpen then
                    elixir.Config.IsElixirUIOpen = true
                end
            end
            if ImGui.MenuItem("Heal AI Settings") then
                elixir.SettingsTabIndex = 1
                if not elixir.Config.IsElixirUIOpen then
                    elixir.Config.IsElixirUIOpen = true
                end
            end
            ImGui.Separator()
            if ImGui.MenuItem("Exit Elixir") then
                elixir.IsTerminated = true
            end
            ImGui.EndPopup()
        end
    end
    ImGui.End()

    return isOpen
end

