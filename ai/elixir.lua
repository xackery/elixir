---@type Mq
local mq = require('mq')

local Version = "v0.5.1"

---@class elixir
---@field public IsTerminated boolean # Is Elixir about to exit?
---@field public IsEQInForeground boolean # Is EQ currently focused
---@field public IsInGame boolean # If we aren't in game this returns false
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
---@field public LastOverlayWindowHeight number # last size of overlay window
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
    HealAI = require('ai/heal'),
    MeditateAI = require('ai/meditate'),
    NukeAI = require('ai/nuke'),
    TargetAI = require('ai/target'),
    ZoneCooldown = 0,
    IsActionCompleted = false,
    lastZoneID = 0,
    SettingsTabIndex = 10,
    LastOverlayWindowHeight = 0
}

---@class Config
---@field public IsElixirAI boolean # is elixir running
---@field public IsElixirOverlayUI boolean # is elixir overlay enabled
---@field public IsElixirDisabledOnFocus boolean # should elixir not run if focused
---@field public IsHealAI boolean # Is Heal AI enabled
---@field public IsHealSubtleCasting boolean # Is Heal AI supposed to cast when high aggro
---@field public IsHealPets boolean # Is Pets Healing enabled
---@field public IsHealRaid boolean # Is Raid Healing enabled
---@field public IsHealXTarget boolean # Is XTarget Healing enabled
---@field public HealPctNormal number # If set, Heal AI will try healing a target when at pct with normal heal
---@field public IsHealEmergencyAllowed boolean  # If set, Heal AI will try use emergeny heals
---@field public HealPctEmergency number # If set, Heal AI will try healing a target when at pct with emergency heal
---@field public IsHealFocus boolean  # If set, Heal AI try to heal a focus target
---@field public HealFocusName string # If set, Heal AI will focus on provided spawn name
---@field public HealFocusSpellID number # If set, Heal AI will focus on provided spell ID on focus ID
---@field public HealFocusPctNormal number # If set, Heal AI will focus on healing a target with pct normal heal
---@field public IsHealFocusEmergencyAllowed boolean  # If set, Heal AI will try use emergeny heals
---@field public HealFocusPctEmergency number # If set, Heal AI will focus on healing a target with pct emergency heal
---@field public IsHealEmergencyPredictive boolean  # If set, Heal AI on emergencies will predict a bad situation
---@field public IsHealFocusEmergencyPredictive boolean  # If set, Heal AI on focus emergencies will predict a bad situation
---@field public IsHealFocusFallback boolean # If true, Heal AI will fall back to normal healing if focus does not need healing
---@field public IsGem1Ignored boolean # if true, ignore gem
---@field public IsGem2Ignored boolean # if true, ignore gem
---@field public IsGem3Ignored boolean # if true, ignore gem
---@field public IsGem4Ignored boolean # if true, ignore gem
---@field public IsGem5Ignored boolean # if true, ignore gem
---@field public IsGem6Ignored boolean # if true, ignore gem
---@field public IsGem7Ignored boolean # if true, ignore gem
---@field public IsGem8Ignored boolean # if true, ignore gem
---@field public IsGem9Ignored boolean # if true, ignore gem
---@field public IsGem10Ignored boolean # if true, ignore gem
---@field public IsGem11Ignored boolean # if true, ignore gem
---@field public IsGem12Ignored boolean # if true, ignore gem
---@field public IsGem13Ignored boolean # if true, ignore gem
---@field public IsCharmAI boolean # Is Charm AI enabled
---@field public IsTargetAI boolean # Is Target AI enabled
---@field public IsBuffAI boolean # Is Buff AI enabled
---@field public IsDotAI boolean # Is Dot AI enabled
---@field public IsNukeAI boolean # Is Nuke AI enabled
---@field public IsDebuffAI boolean # Is Debuff AI enabled
---@field public IsMeditateAI boolean # Is Meditate AI enabled
---@field public IsMeditateDuringCombat boolean # Is Meditate allowed if in combat
---@field public IsMeditateSubtle boolean # Is Meditate AI supposed to sit when high aggro
---@field public IsElixirUIOpen boolean # Is the Elixir UI open
---@field public IsDebugEnabled boolean # Is debugging info enabled
---@field public IsDebugVerboseEnabled boolean # Is echoing out verbose debugging enabled
Config = {}

function InitializeConfig()
    return {
        IsElixirAI = true,
        IsEQInForeground = true,
        IsInGame = false,
        IsElixirOverlayUI = true,
        IsElixirDisabledOnFocus = false,
        IsHealAI = true,
        HealPctNormal = 50,
        HealPctEmergency = 30,
        IsHealSubtleCasting = false,
        IsHealFocus = false,
        HealFocusPctNormal = 50,
        HealFocusPctEmergency = 30,
        IsHealFocusEmergencyAllowed = false,
        IsHealEmergencyAllowed = false,
        IsHealEmergencyPredictive = false,
        IsHealFocusEmergencyPredictive = false,
        IsHealFocusFallback = false,
        IsHealRaid = false,
        IsHealPets = true,
        IsHealXTarget = true,
        IsElixirUIOpen = true,
        IsDebugEnabled = true,
        IsMeditateAI = true,
        IsCharmAI = true,
        IsTargetAI = true,
        IsBuffAI = true,
        IsDotAI = true,
        IsNukeAI = true,
        IsDebuffAI = true,
        IsMeditateDuringCombat = true,
        IsDebugVerboseEnabled = true,
        IsGem1Ignored = false,
        IsGem2Ignored = false,
        IsGem3Ignored = false,
        IsGem4Ignored = false,
        IsGem5Ignored = false,
        IsGem6Ignored = false,
        IsGem7Ignored = false,
        IsGem8Ignored = false,
        IsGem9Ignored = false,
        IsGem10Ignored = false,
        IsGem11Ignored = false,
        IsGem12Ignored = false,
        IsGem13Ignored = false,
    }
end

---@class Gem
---@field SpellID number # Which spell ID is memorized to this gem, used for checking on change
---@field SpellName string # Used for displaying on settings
---@field IsIgnored boolean # Ignore this gem for AI
---@field Output string # Tooltip message on state of this gem
---@field Tag SpellTag # Spell Tag data
Gem = {}

function InitializeGem(gemIndex)
    ---@type Gem
    local gem = {}
    gem.IsIgnored = elixir.Config["IsGem"..gemIndex.."Ignored"]
    local spell = mq.TLO.Me.Gem(gemIndex)
    gem.Tag = GenerateSpellTag(spell.ID())
    if spell.Name() then
        gem.SpellName = spell.Name()
    else
        gem.SpellName = "None"
    end
    if not gem.Output then gem.Output = "" end
    if not spell() or spell.ID() == 0 then
        gem.Output = "no spell memorized"
    end
    return gem
end

---@class Button
---@field IsIgnored bool # Ignore this gem for AI
---@field Output string # Tooltip message on state of this gem
Button = {}

local function loadConfig()
    local path = string.format("elixir_%s_%s.lua", mq.TLO.EverQuest.Server(), mq.TLO.Me.Name())
    
    if os.rename(path, path) and true then
        elixir.Config = InitializeConfig()
        mq.pickle(path, elixir.Config)
        print("created new config data")
        return
    end

    local configData, err = loadfile(mq.configDir..'/'..path)
    if err then
        print("failed to load settings "..path..": "..err)
        elixir.Config = InitializeConfig()
        mq.pickle(path, elixir.Config)
        return
    end
    if configData then elixir.Config = configData() end
    print(string.format("loaded existing config data: %d", elixir.Config.HealPctNormal))
end

local function sanitizeConfig()
    local isNotSanitized = false
    if elixir.Config.HealPctNormal > 99 then
        print(string.format("HealPctNormal from config was too high at %d, reducing to 99", elixir.Config.HealPctNormal))
        elixir.Config.HealPctNormal = 99
        isNotSanitized = true
    end
    if elixir.Config.HealPctNormal < 5 then
        elixir.Config.HealPctNormal = 5
        isNotSanitized = true
    end
    if elixir.Config.HealPctEmergency > 99 then
        elixir.Config.HealPctEmergency = 99
        isNotSanitized = true
    end
    if elixir.Config.HealPctEmergency < 5 then
        elixir.Config.HealPctEmergency = 5
        isNotSanitized = true
    end

    if elixir.Config.HealFocusPctNormal > 99 then
        print(string.format("HealFocusPctNormal from config was too high at %d, reducing to 99", elixir.Config.HealFocusPctNormal))
        elixir.Config.HealFocusPctNormal = 99
        isNotSanitized = true
    end
    if elixir.Config.HealFocusPctNormal < 5 then
        elixir.Config.HealFocusPctNormal = 5
        isNotSanitized = true
    end

    if not elixir.Config.HealFocusPctEmergency or type(elixir.Config.HealFocusPctEmergency) ~= "number" then
        print("HealFocusPctEmergency from config was invalid, resetting")
        elixir.Config.HealFocusPctEmergency = 30
        isNotSanitized = true
    end

    if elixir.Config.HealFocusPctEmergency > 99 then
        print(string.format("HealFocusPctEmergency from config was too high at %d, reducing to 99", elixir.Config.HealFocusPctEmergency))
        elixir.Config.HealFocusPctEmergency = 99
        isNotSanitized = true
    end
    if elixir.Config.HealFocusPctEmergency < 5 then
        elixir.Config.HealFocusPctEmergency = 5
        isNotSanitized = true
    end
    if isNotSanitized then
        local path = string.format("elixir_%s_%s.lua", mq.TLO.EverQuest.Server(), mq.TLO.Me.Name())
        mq.pickle(path, elixir.Config)
    end
end

---- Cooldown due to movement
---@type number
MovementGlobalCooldown = nil

function elixir:Initialize()
    self.Version = Version
    loadConfig()
    sanitizeConfig()

    for i = 1, mq.TLO.Me.NumGems() do
        self.Gems[i] = InitializeGem(i)
    end
    self.HealAI:Initialize()
    self.MaxGemCount = mq.TLO.Me.NumGems()
    self.LastActionOutput = ''
    self.BuffAI.Output = ''
    self.CharmAI.Output = ''
    self.DebuffAI.Output = ''
    self.DotAI.Output = ''
    self.HealAI.Output = ''
    self.MeditateAI.Output = ''
    self.NukeAI.Output = ''
    self.TargetAI.Output = ''
end

--- Reset will reset all strings for each update
function elixir:Reset()
    self.isActionCompleted = false
    self.IsEQInForeground = mq.TLO.EverQuest.Foreground()
    if self.MaxGemCount ~= mq.TLO.Me.NumGems() then
        self.MaxGemCount = mq.TLO.Me.NumGems()
    end
    for i = 1, mq.TLO.Me.NumGems() do
        self.Gems[i] = InitializeGem(i)
    end
    self.IsInGame = (mq.TLO.EverQuest.GameState() == "INGAME")
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
    if not self.IsInGame then return end
    if mq.TLO.Me.Class.ShortName() ~= "BRD" and mq.TLO.Me.Moving() then
        MovementGlobalCooldown =  mq.gettime() + 2000
    end

    self.HealAI.Output = self.HealAI:Cast(elixir)
    charm:Cast(elixir)
    target:Check(elixir)
    nuke:Cast(elixir)
    buff:Cast(elixir)
    self.MeditateAI.Output = meditate:Check(elixir)
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
