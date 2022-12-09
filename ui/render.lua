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
elements[targetElement.Index] = targetElement
elements[debuffElement.Index] = debuffElement
elements[dotElement.Index] = dotElement
elements[nukeElement.Index] = nukeElement
elements[buffElement.Index] = buffElement
elements[meditateElement.Index] = meditateElement
elements[debugElement.Index] = debugElement

function SettingsRender()
    if not elixir.Config.IsElixirUIOpen then return end
    if not elixir.IsInGame then return end
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
        local _, isClicked = ImGui.Selectable(element.Title, elixir.SettingsTabIndex == selectionIndex)
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
local classIcon = mq.FindTextureAnimation(className .. "Icon")
local classIconDisabled = mq.FindTextureAnimation(className .. "DisabledIcon")

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
    if not elixir.Config.IsElixirOverlayUI then return end
    if not elixir.IsInGame then return end

    local window_flags = bit32.bor(ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoDocking,
        ImGuiWindowFlags.NoSavedSettings, ImGuiWindowFlags.NoFocusOnAppearing, ImGuiWindowFlags.NoNav)

    ImGui.SetNextWindowBgAlpha(0.7)
    
    local isDraw
    isOpen, isDraw = ImGui.Begin("Elixir overlay", true, window_flags)
    
    if isDraw then
        ImGui.SetCursorPos(1,4)
        
        if elixir.Config.IsElixirAI then
            if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then
                ImGui.DrawTextureAnimation(classIconDisabled, ICON_WIDTH, ICON_HEIGHT)
            else
                ImGui.DrawTextureAnimation(classIcon, ICON_WIDTH, ICON_HEIGHT)
            end
        else
            ImGui.DrawTextureAnimation(classIconDisabled, ICON_WIDTH, ICON_HEIGHT)
        end

        ImGui.SetCursorPos(1,6)
        if ImGui.InvisibleButton("settings", ICON_WIDTH, ICON_HEIGHT-6) then
            elixir.SettingsTabIndex = 0
            if not elixir.Config.IsElixirUIOpen then
                elixir.Config.IsElixirUIOpen = true
            end
        end

        
        ImGui.SetCursorPos(14, 25)
        if elixir.Config.IsElixirAI then
            if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then
                disabledIconStyle()
                ImGui.Text(elixirElement.ForegroundIcon) -- elixir
                ImGui.PopStyleColor(1)
            else
                textIconStyle()
                ImGui.Text(elixirElement.Icon) -- elixir
                ImGui.PopStyleColor(1)
            end
        else
            disabledIconStyle()
            ImGui.Text(elixirElement.Icon) -- elixir
            ImGui.PopStyleColor(1)
        end
       
        local windowHeight = 46

        if elixir.Config.IsHealAI then
            windowHeight = windowHeight + 20
            ImGui.NewLine()
            ImGui.SameLine(4)
            enabledIconStyle()
            ImGui.Text(healElement.Icon) -- heal
            ImGui.PopStyleColor(1)
            if elixir.Config.IsHealFocus then
                ImGui.SameLine(22)
                enabledIconStyle()
                ImGui.Text(healElement.FocusIcon) -- focus heal
                ImGui.PopStyleColor(1)
            end
        end

        if elixir.Config.IsCharmAI then
            windowHeight = windowHeight + 20
            ImGui.NewLine()
            ImGui.SameLine(4)
            enabledIconStyle()
            ImGui.Text(charmElement.Icon) -- heal
            ImGui.PopStyleColor(1)
        end

        if elixir.Config.IsTargetAI then
            windowHeight = windowHeight + 20
            ImGui.NewLine()
            ImGui.SameLine(4)
            enabledIconStyle()
            ImGui.Text(targetElement.Icon) -- heal
            ImGui.PopStyleColor(1)
        end

        if elixir.Config.IsDebuffAI then
            windowHeight = windowHeight + 20
            ImGui.NewLine()
            ImGui.SameLine(4)
            enabledIconStyle()
            ImGui.Text(debuffElement.Icon) -- heal
            ImGui.PopStyleColor(1)
        end

        if elixir.Config.IsDotAI then
            windowHeight = windowHeight + 20
            ImGui.NewLine()
            ImGui.SameLine(4)
            enabledIconStyle()
            ImGui.Text(dotElement.Icon) -- heal
            ImGui.PopStyleColor(1)
        end

        if elixir.Config.IsNukeAI then
            windowHeight = windowHeight + 20
            ImGui.NewLine()
            ImGui.SameLine(4)
            enabledIconStyle()
            ImGui.Text(nukeElement.Icon) -- heal
            ImGui.PopStyleColor(1)
        end

        if elixir.Config.IsBuffAI then
            windowHeight = windowHeight + 20
            ImGui.NewLine()
            ImGui.SameLine(4)
            enabledIconStyle()
            ImGui.Text(buffElement.Icon) -- heal
            ImGui.PopStyleColor(1)
        end

        if elixir.Config.IsMeditateAI then
            windowHeight = windowHeight + 20
            ImGui.NewLine()
            ImGui.SameLine(4)
            enabledIconStyle()
            ImGui.Text(meditateElement.Icon) -- meditate
            ImGui.PopStyleColor(1)
            if elixir.Config.IsMeditateDuringCombat then
                ImGui.SameLine(22)
                enabledIconStyle()
                ImGui.Text(meditateElement.CombatIcon) -- combat
                ImGui.PopStyleColor(1)
            end
        end

        if windowHeight ~= elixir.LastOverlayWindowHeight then
            ImGui.SetWindowSize(42, windowHeight)
            elixir.LastOverlayWindowHeight = windowHeight
            print("height changed to " .. windowHeight)
        end
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

