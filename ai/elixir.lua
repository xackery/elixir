---@type Mq
local mq = require('mq')

local Version = "v1.0.0"

---@class elixir
---@field public IsTerminated boolean # Is Elixir about to exit?
---@field public SettingsTabIndex number # Last selected tab in settings UI
---@field public Config Config # Configuration for elixir
---@field public LastActionOutput string # Last Action executed output
---@field public Gems Gem[] # Gem data
---@field public Buttons Button[] # Button data
---@field public HealAI heal # Heal AI reference
---@field public CharmAI charm # Charm AI reference
---@field public MaxGemCount number # Maximum Number of Gems available, this is updated each pulse
---@field public ZoneCooldown number # timer when zone events occur
---@field public IsActionCompleted boolean # Has an action completed during this update
---@field private lastZoneID number # Last Zone ID snapshotted on update
elixir = {
    LastActionOutput = '',
    Config = {},
    Gems = {},
    Buttons = {},
    BuffAI = require('ai/buff'),
    CharmAI = require('ai/charm'),
    DebuffAI = require('ai/debuff'),
    DotAI = require('ai/dot'),
    NukeAI = require('ai/nuke'),
    HealAI = require('ai/heal'),
    TargetAI = require('ai/target'),
    MeditateAI = require('ai/meditate'),
    ZoneCooldown = 0,
    IsActionCompleted = false,
    lastZoneID = 0,
    SettingsTabIndex = 10
}

---@class Config
---@field public IsElixirAI boolean # is elixir running
---@field public IsElixirDisabledOnFocus boolean # should elixir not run if focused
---@field public IsHealAI boolean # Is Heal AI enabled
---@field public IsHealAIPets boolean # Is Pets Healing enabled
---@field public IsHealAIRaid boolean # Is Raid Healing enabled
---@field public IsCharmAI boolean # Is Charm AI enabled
---@field public IsElixirUIOpen boolean # Is the Elixir UI open
---@field public IsDebugEnabled boolean # Is debugging info enabled
---@field public IsDebugVerboseEnabled boolean # Is echoing out verbose debugging enabled
Config = {}

function InitializeConfig()
    return {
        IsElixirAI = true,
        IsElixirDisabledOnFocus = false,
        IsHealAI = true,
        IsHealAIPets = false,
        IsHealAIRaid = false,
        IsElixirUIOpen = true,
        IsDebugEnabled = true,
        IsDebugVerboseEnabled = true,
    }
end

---@class Gem
---@field SpellID number # Which spell ID is memorized to this gem, used for checking on change
---@field IsIgnored boolean # Ignore this gem for AI
---@field Output string # Tooltip message on state of this gem
---@field Tag SpellTag # Spell Tag data
Gem = {}

function InitializeGem(gemIndex)
    ---@type Gem
    local gem = {}
    gem.IsIgnored = false
    local spell = mq.TLO.Me.Gem(gemIndex)
    print(spell)
    gem.Tag = GenerateSpellTag(spell.ID())
    gem.Output = ""
    if not spell() or spell.ID() == 0 then
        gem.Output = "no spell memorized"
    end
    return gem
end

---@class Button
---@field IsIgnored bool # Ignore this gem for AI
---@field Output string # Tooltip message on state of this gem
Button = {}

---- Cooldown due to movement
---@type number
MovementGlobalCooldown = nil

function elixir:Initialize()
    self.Version = Version
    self.Config = InitializeConfig()
    for i = 1, mq.TLO.Me.NumGems() do
        self.Gems[i] = InitializeGem(i)
    end
    self.HealAI:Initialize()
    self.MaxGemCount = mq.TLO.Me.NumGems()
end

--- Reset will reset all strings for each update
function elixir:Reset()
    self.isActionCompleted = false
    self.LastActionOutput = ''
    if self.MaxGemCount ~= mq.TLO.Me.NumGems() then
        self.MaxGemCount = mq.TLO.Me.NumGems()
    end
    for i = 1, mq.TLO.Me.NumGems() do
        self.Gems[i] = InitializeGem(i)
    end
    self.CharmAI.Output = ''
    self.HealAI.Output = ''
end

function WaitOnCasting() return mq.TLO.Me.SpellReady(1)() end

---Updates Elixir Logic
function elixir:Update()
    self:Reset()
    if self.lastZoneID ~= mq.TLO.Zone.ID() then
        if self.lastZoneID ~= 0 then
            self.ZoneCooldown = mq.gettime() + 5000
        end
        self.lastZoneID = mq.TLO.Zone.ID()
    end

    if mq.TLO.Me.Class.ShortName() ~= "BRD" and mq.TLO.Me.Moving() then
        MovementGlobalCooldown =  mq.gettime() + 2000
    end

    self.HealAI.Output = self.HealAI:Cast(elixir)
    charm:Cast(elixir)
    target:Check(elixir)
    nuke:Cast(elixir)
    meditate:Check(elixir)
    buff:Cast(elixir)
end

---DebugPrintF prints if debug verbose and debug mode are both enabled
---@param s string
---@param ... any
function elixir:DebugPrintf(s, ...)
    if not self then return end
    if not self.Config.IsDebugEnabled then return end
    if not self.Config.IsDebugVerboseEnabled then return end
    print(s:format(...))
end

return elixir
