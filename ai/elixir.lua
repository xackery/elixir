---@type Mq
local mq = require('mq')

local Version = "v0.5.6"


---@class elixir
---@field public IsTerminated boolean # Is Elixir about to exit?
---@field public IsEQInForeground boolean # Is EQ currently focused
---@field public IsInGame boolean # If we aren't in game this returns false
---@field public SettingsTabIndex number # Last selected tab in settings UI
---@field public Config Config # Configuration for elixir
---@field public LastActionOutput string # Last Action executed output
---@field public Gems Gem[] # Gem data
---@field public Buttons Button[] # Button data
---@field public Allies string[] # List of allies spawn IDs
---@field public AlliesRaidSize number # cache for last raid size
---@field public AlliesGroupSize number # cache for last group size
---@field public HealAI heal # Heal AI reference
---@field public CureAI cure # Cure AI reference
---@field public HotAI hot # Hot AI reference
---@field public MoveAI move # movement AI referenc
---@field public MezAI mez # movement AI reference
---@field public StunAI stun # stun AI reference
---@field public AttackAI attack # Attack AI reference
---@field public ArcheryAI archery # Archery AI reference
---@field public CharmAI charm # Charm AI reference
---@field public MaxGemCount number # Maximum Number of Gems available, this is updated each pulse
---@field public ZoneCooldown number # timer when zone events occur
---@field public IsActionCompleted boolean # Has an action completed during this update
---@field public LastSpellTargetID number # Last spell, what was the target id, used for cancelling when a mob dies etc
---@field public LastSpellID number # Last casted spell ID
---@field public LastOverlayWindowHeight number # last size of overlay window
---@field public IsTankInParty boolean # Is there a tank class in the group or raid, used for subtle checks
---@field public ConfigPath string # Config path, alias of mq.configDir
---@field private lastZoneID number # Last Zone ID snapshotted on update
elixir = {
    LastActionOutput = '',
    Gems = {},
    Buttons = {},
    Allies = {},
    ArcheryAI = require('ai/archery'),
    AttackAI = require('ai/attack'),
    BuffAI = require('ai/buff'),
    CharmAI = require('ai/charm'),
    DebuffAI = require('ai/debuff'),
    DotAI = require('ai/dot'),
    HealAI = require('ai/heal'),
    CureAI = require('ai/cure'),
    HotAI = require('ai/hot'),
    MeditateAI = require('ai/meditate'),
    MezAI = require('ai/mez'),
    MoveAI = require('ai/move'),
    NukeAI = require('ai/nuke'),
    StunAI = require('ai/stun'),
    TargetAI = require('ai/target'),
    ZoneCooldown = 0,
    IsActionCompleted = false,
    lastZoneID = 0,
    SettingsTabIndex = 16,
    LastOverlayWindowHeight = 0,
    IsTankInParty = false,
}
---@alias MoveType "nav"|"advpath"|"moveutils"|"dynamic"

---@class Config
---@field public IsElixirAI boolean # is elixir running
---@field public IsElixirOverlayUI boolean # is elixir overlay enabled
---@field public IsElixirDisabledOnFocus boolean # should elixir not run if focused
---@field public IsElixirSettingsUIOpen boolean # Is the Elixir UI open
---@field public IsDebugEnabled boolean # Is debugging info enabled
---@field public IsDebugVerboseEnabled boolean # Is echoing out verbose debugging enabled
---Heal AI
---@field public IsHealAI boolean # Is Heal AI enabled
---@field public IsHealSubtleCasting boolean # Is Heal AI supposed to cast when high aggro
---@field public IsHealPets boolean # Is Pets Healing enabled
---@field public IsHealRaid boolean # Is Raid Healing enabled
---@field public IsHealXTarget boolean # Is XTarget Healing enabled
---@field public HealPctNormal number # If set, Heal AI will try healing a target when at pct with normal heal
---@field public HealNormalSound string # sound to play on normal heal alert
---@field public HealEmergencySound string # sound to play on normal heal alert
---@field public HealPctEmergency number # If set, Heal AI will try healing a target when at pct with emergency heal
---@field public IsHealEmergencyAllowed boolean  # If set, Heal AI will try use emergeny heals
---@field public IsHealFocus boolean  # If set, Heal AI try to heal a focus target
---@field public HealFocusNormalSound string # sound to play on normal heal alert
---@field public HealFocusName string # If set, Heal AI will focus on provided spawn name
---@field public HealFocusSpellID number # If set, Heal AI will focus on provided spell ID on focus ID
---@field public HealFocusPctNormal number # If set, Heal AI will focus on healing a target with pct normal heal
---@field public IsHealFocusEmergencyAllowed boolean  # If set, Heal AI will try use emergeny heals
---@field public HealFocusPctEmergency number # If set, Heal AI will focus on healing a target with pct emergency heal
---@field public HealFocusEmergencySound string # sound to play on normal heal alert
---@field public IsHealEmergencyPredictive boolean  # If set, Heal AI on emergencies will predict a bad situation
---@field public IsHealFocusEmergencyPredictive boolean  # If set, Heal AI on focus emergencies will predict a bad situation
---@field public IsHealFocusFallback boolean # If true, Heal AI will fall back to normal healing if focus does not need healing
---Cure AI
---@field public IsCureAI boolean # Is Cure AI enabled
---@field public IsCureRaid boolean # Is curing raid enabled
---@field public IsCureXTarget boolean # Is curing xtarget enabled
---Hot AI
---@field public IsHotAI boolean # Is Hot AI enabled
---@field public IsHotRaid boolean # Is Raid heal over times enabled
---@field public IsHotXTarget boolean # Is XTarget heal over times enabled
---@field public HotPctNormal number # If set, Hot AI will try heal over times a target when at pct with normal hot
---@field public HotNormalSound string # sound to play on normal heal alert
---@field public HotFocusName string # If set, Hot AI will focus on provided spawn name
---@field public HotFocusSpellID number # If set, Hot AI will focus on provided spell ID on focus ID
---@field public HotFocusPctNormal number # If set, Hot AI will focus on heal over times a target with pct normal hot
---Stun AI
---@field public IsStunAI boolean # Is Stun AI enabled
---Mez AI
---@field public IsMezAI boolean # Is Mez AI enabled
---Gem Ignore
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
---Charm AI
---@field public IsCharmAI boolean # Is Charm AI enabled
---Archery AI
---@field public IsArcheryAI boolean # Is Archery AI enabled
---@field public IsArcherySubtle boolean # Will archery turn off when high hate
---Attack AI
---@field public IsAttackAI boolean # Is Attack AI enabled
---@field public IsAttackSubtle boolean # Will attack turn off when high hate
---Move AI
---@field public IsMoveAI boolean # Is Move AI enabled
---@field public MoveType MoveType # option to move
---@field public IsMoveToMeleeInCombat boolean # Is Move AI supposed to stay in melee
---@field public IsMoveToArcheryInCombat boolean # Is Move AI supposed to stay in ranged
---@field public IsMoveToStrategyPointInCombat boolean # Is Move to Strategy Point enabled
---@field public MoveToStrategyPointX number # Move to Strategy Point x
---@field public MoveToStrategyPointY number # Move to Strategy Point y
---@field public MoveToStrategyPointZ number # Move to Strategy Point z
---@field public IsMoveToTank boolean # Is Move AI supposed to stay near the tank
---@field public MoveToTankMaxDistance number # Max distance before moving to tank
---@field public IsMoveToCamp boolean # Is Move AI supposed to stay in a camp spot
---@field public MoveToCampRadius number # how far before triggering camp radius leash
---@field public IsMoveToCampDuringCombat boolean # Should moving to camp be triggered while fighting?
---@field public MoveToCampX number # Camp X
---@field public MoveToCampY number # Camp Y
---@field public MoveToCampZ number # Camp Z
---Target AI
---@field public IsTargetAI boolean # Is Target AI enabled
---@field public IsTargetPetAssist boolean # Will Target AI use pet attack
---@field public TargetAssistMaxRange number # Distance to target assist mob
---Buff AI
---@field public IsBuffAI boolean # Is Buff AI enabled
---@field public IsBuffRaid boolean # Is Buffing raid enabled
---@field public IsBuffPets boolean # Is Pets Buffing enabled
---@field public IsBuffXTarget boolean # Is XTarget Buffing enabled
---@field public IsBuffDuringCombat boolean # Is buffing allowed if in combat
---Dot AI
---@field public IsDotAI boolean # Is Dot AI enabled
---@field public DotPctNormal number # % to dot normal
---@field public IsDotSubtleCasting boolean # Is dotting a subtle casting feature
---Nuke AI
---@field public IsNukeAI boolean # Is Nuke AI enabled
---@field public NukePctNormal number # % to nuke normal
---@field public NukePctMinMana number # Minimum mana to be able to nuke
---@field public IsNukeSubtleCasting boolean # Is Nuking a subtle casting feature
---Debuff AI
---@field public IsDebuffAI boolean # Is Debuff AI enabled
---@field public DebuffPctNormal number # % to debuff normal
---@field public IsDebuffFearKiting boolean # is fear kiting allowed
---@field public IsDebuffNoSnareFearKiting boolean # is fear kiting without a snared mob allowed
---@field public IsDebuffSubtleCasting boolean # Is debuffing a subtle casting feature
---@field public DebuffPctMinMana number # Minimum mana to be able to debuff
---@field public DebuffRetryCount number # Number of retries of a spell before giving up
---Meditate AI
---@field public IsMeditateAI boolean # Is Meditate AI enabled
---@field public IsMeditateDuringCombat boolean # Is Meditate allowed if in combat
---@field public IsMeditateSubtle boolean # Is Meditate AI supposed to sit when high aggro
elixir.Config = {
    IsElixirAI = true,
    IsEQInForeground = true,
    IsInGame = false,
    IsElixirOverlayUI = true,
    IsElixirDisabledOnFocus = false,
    IsElixirSettingsUIOpen = true,
    IsHealAI = true,
    HealPctNormal = 50,
    HealPctEmergency = 30,
    IsHealSubtleCasting = false,
    IsHealFocus = false,
    HealFocusPctNormal = 50,
    HealFocusPctEmergency = 30,
    IsHealFocusEmergencyAllowed = false,
    IsHealEmergencyAllowed = true,
    IsHealEmergencyPredictive = true,
    IsHealFocusEmergencyPredictive = false,
    IsHealFocusFallback = false,
    HealNormalSound = 'heal',
    HealFocusNormalSound = 'heal',
    HealEmergencySound = 'heal',
    HealFocusEmergencySound = 'heal',
    CureNormalSound = 'cure',
    IsHealRaid = true,
    IsHealPets = true,
    IsHealXTarget = true,
    IsHotAI = true,
    HotNormalSound = 'hot',
    HotPctNormal = 70,
    IsStunAI = false,
    IsDebugEnabled = true,
    IsMeditateAI = true,
    IsArcheryAI = false,
    IsArcherySubtle = false,
    IsAttackAI = false,
    IsAttackSubtle = false,
    IsMezAI = false,
    IsMoveAI = false,
    IsMoveToMeleeInCombat = true,
    IsMoveToArcheryInCombat = false,
    IsMoveToStrategyPointInCombat = false,
    MoveToStrategyPointX = 0,
    MoveToStrategyPointY = 0,
    MoveToStrategyPointZ = 0,
    IsMoveToTank = false,
    IsMoveToCamp = false,
    MoveToCampX = 0,
    MoveToCampY = 0,
    MoveToCampZ = 0,
    IsCharmAI = false,
    IsTargetAI = false,
    IsTargetPetAssist = true,
    TargetAssistMaxRange = 40,
    IsBuffAI = false,
    BuffPctNormal = 95,
    IsBuffSubtleCasting = true,
    IsDotAI = false,
    DotPctNormal = 95,
    IsDotSubtleCasting = true,
    DotPctMinMana = 50,
    IsNukeAI = false,
    NukePctNormal = 95,
    NukePctMinMana = 50,
    IsNukeSubtleCasting = true,
    IsDebuffAI = false,
    DebuffPctNormal = 95,
    IsDebuffSubtleCasting = true,
    IsDebuffFearKiting = true,
    IsDebuffNoSnareFearKiting = false,
    DebuffPctMinMana = 20,
    DebuffRetryCount = 2,
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

---@class Gem
---@field SpellID number # Which spell ID is memorized to this gem, used for checking on change
---@field SpellName string # Used for displaying on settings
---@field IsIgnored boolean # Ignore this gem for AI
---@field Output string # Tooltip message on state of this gem
---@field LastOutput string # Last tooltip message
---@field LastOutputCounter number # counts down how long a message stays
---@field Tag SpellTag # Spell Tag data
Gem = {}
Gem.__index = Gem

function Gem.new(init)
    local self = setmetatable({
        SpellID = 0,
        SpellName = "None",
        IsIgnored = false,
        Output = "",
        LastOutput = "",
        LastOutputCounter = 0,
        Tag = {},
    }, Gem)
    
    return self
end

function Gem:Refresh(gemIndex)
    if elixir.Config["IsGem"..gemIndex.."Ignored"] == true then self.IsIgnored = true end

    local spell = mq.TLO.Me.Gem(gemIndex)
    self.Tag = GenerateSpellTag(spell.ID())
    if spell.Name() then
        self.SpellName = spell.Name()
    else
        self.SpellName = "None"
    end
    
    if self.Output ~= "idle" and self.LastOutput == self.Output then
        self.LastOutputCounter = self.LastOutputCounter + 1
        if self.LastOutputCounter > 5 then
            self.Output = "idle"
            self.LastOutput = "idle"
            self.LastOutputCounter = 0
        end
    else
        self.LastOutputCounter = 0
    end
    self.LastOutput = self.Output

    if not spell() or spell.ID() == 0 then
        self.Output = "no spell memorized"
    end
end

---@class Button
---@field IsIgnored bool # Ignore this gem for AI
---@field Output string # Tooltip message on state of this gem
Button = {}

local function loadConfig()
    local path = string.format("elixir/%s_%s.lua", mq.TLO.EverQuest.Server(), mq.TLO.Me.Name())
    
    if os.rename(path, path) and true then
        mq.pickle(path, elixir.Config)
        print("created new config data")
        return
    end

    local configData, err = loadfile(mq.configDir..'/'..path)
    if err then
        print("failed to load settings "..path..": "..err)
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
    print("starting elixir ".. self.Version)
    --loadConfig()
    --sanitizeConfig()

    
    self.ConfigPath = mq.configDir
    for i = 1, mq.TLO.Me.NumGems() do
        self.Gems[i] = Gem.new()
    end

    self.MaxGemCount = mq.TLO.Me.NumGems()
    self.LastActionOutput = ''
    if mq.TLO.Me.Class.ShortName() == "CLR" then
        print(mq.TLO.Me.Class.Name() .. " Mode Settings")
        elixir.Config.IsHealAI = true
        elixir.Config.HealNormalSound = 'heal'
        elixir.Config.IsHotAI = true
        elixir.Config.IsCureAI = true
        elixir.Config.IsDebuffAI = true
        elixir.Config.IsDebuffSubtleCasting = true
        elixir.Config.IsNukeAI = true
        elixir.Config.IsNukeSubtleCasting = true
        elixir.Config.NukePctMinMana = 80
        elixir.Config.IsMeditateAI = true
        elixir.Config.IsMeditateDuringCombat = true
        elixir.Config.IsMeditateSubtle = true
        elixir.Config.IsTargetAI = true
    end    
    if mq.TLO.Me.Class.ShortName() == "ENC" then
        print(mq.TLO.Me.Class.Name() .. " Mode Settings")
        elixir.Config.IsHealAI = false
        elixir.Config.IsHotAI = false
        elixir.Config.IsDotAI = false
        elixir.Config.IsDotSubtleCasting = false
        elixir.Config.IsDebuffAI = true
        elixir.Config.IsDebuffSubtleCasting = false
        elixir.Config.IsNukeAI = true
        elixir.Config.IsNukeSubtleCasting = false
        elixir.Config.NukePctMinMana = 20
        elixir.Config.IsMeditateAI = true
        elixir.Config.IsMeditateDuringCombat = true
        elixir.Config.IsMeditateSubtle = true
        elixir.Config.IsTargetAI = true
    end

    local f = io.open(string.format("%s/elixir/%s.wav", mq.configDir, elixir.Config.HealNormalSound))
    if f ~= nil then
        elixir.HealAI.IsHealNormalSoundValid = true
        io.close(f)
    else
        elixir.HealAI.IsHealNormalSoundValid = false
    end

    local f = io.open(string.format("%s/elixir/%s.wav", mq.configDir, elixir.Config.HealFocusNormalSound))
    if f ~= nil then
        elixir.HealAI.IsHealFocusNormalSoundValid = true
        io.close(f)
    else
        elixir.HealAI.IsHealFocusNormalSoundValid = false
    end

    local f = io.open(string.format("%s/elixir/%s.wav", mq.configDir, elixir.Config.HealFocusEmegencySound))
    if f ~= nil then
        elixir.HealAI.IsHealFocusEmergencySoundValid = true
        io.close(f)
    else
        elixir.HealAI.IsHealFocusEmergencySoundValid = false
    end

    f = io.open(string.format("%s/elixir/%s.wav", mq.configDir, elixir.Config.CureNormalSound))
    if f ~= nil then
        elixir.CureAI.IsCureNormalSoundValid = true
        io.close(f)
    else
        elixir.CureAI.IsCureNormalSoundValid = false
    end

    f = io.open(string.format("%s/elixir/%s.wav", mq.configDir, elixir.Config.HotNormalSound))
    if f ~= nil then
        elixir.HotAI.IsHotNormalSoundValid = true
        io.close(f)
    else
        elixir.HotAI.IsHotNormalSoundValid = false
    end

    f = io.open(string.format("%s/elixir/%s.wav", mq.configDir, elixir.Config.HealEmergencySound))
    if f ~= nil then
        elixir.HealAI.IsHealEmergencySoundValid = true
        io.close(f)
    else
        elixir.HealAI.IsHealEmergencySoundValid = false
    end
end

function elixir:RepopulateAllies()
    if self.AlliesGroupSize == mq.TLO.Me.GroupSize() and self.AlliesRaidSize == mq.TLO.Raid.Members() and self.AlliesXTargetSize == mq.TLO.Me.XTarget() then return end
    self.AlliesGroupSize = mq.TLO.Me.GroupSize()
    self.AlliesRaidSize = mq.TLO.Raid.Members()
    self.AlliesXTargetSize = mq.TLO.Me.XTarget()

    self.Allies = {}
    self.Allies[mq.TLO.Me.ID()] = mq.TLO.Me.Spawn.Name()

    if mq.TLO.Group.GroupSize() then
        for i = 0, mq.TLO.Group.Members() do
            local pG = mq.TLO.Group.Member(i)
            if pG() and
            pG.Present() and
            pG.Type() ~= "CORPSE" and
            pG.Distance() < 200 and
            not pG.Offline() and
            pG.Spawn() then
                self.Allies[pG.Spawn.ID()] = pG.Spawn.Name()
            end
        end
    end

    if mq.TLO.Raid.Members() then
        for i = 0, mq.TLO.Raid.Members() do
            local pR = mq.TLO.Raid.Member(i)
            if pR() and
            pR.Type() ~= "CORPSE" and
            pR.Distance() < 200 and
            pR.Spawn() then
                self.Allies[pR.Spawn.ID()] = pR.Spawn().Name()
            end
        end
    end

    if mq.TLO.Me.XTarget() then
        for i = 0, mq.TLO.Me.XTarget() do
            local xt = mq.TLO.Me.XTarget(i)
            if xt() and
            (xt.TargetType() == "Specific PC" or
            xt.TargetType() == "Raid Assist 1" or
            xt.TargetType() == "Raid Assist 2" or
            xt.TargetType() == "Raid Assist 3") and
            xt.Type() ~= "CORPSE" and
            xt.Distance() < 200 then
                self.Allies[xt.ID()] = mq.TLO.Spawn(xt.ID())().Name()
            end
        end
    end
end

--- Reset will reset all strings for each update
function elixir:Reset()
    self.isActionCompleted = false
    self.IsEQInForeground = mq.TLO.EverQuest.Foreground()
    if self.MaxGemCount ~= mq.TLO.Me.NumGems() then
        self.MaxGemCount = mq.TLO.Me.NumGems()
    end
    self.IsTankInParty = IsTankInParty()
    for i = 1, mq.TLO.Me.NumGems() do
        if not self.Gems[i] then self.Gems[i] = {} end
        self.Gems[i]:Refresh(i)
    end
    if elixir.Config.HealFocusID ~= 0 and mq.TLO.Spawn(elixir.Config.HealFocusID)() == nil then
        elixir.Config.HealFocusID = 0
        elixir.HealAI.FocusName = ""
    end

    if mq.TLO.Me.Casting.ID() == self.LastSpellID then
        local spawn = mq.TLO.Spawn(elixir.LastSpellTargetID)
        if not spawn() or spawn.Type() == 'Corpse' then
            mq.cmdf("/stopcast")
            elixir:DebugPrintf("stopping cast on %s, they died", spawn.Name())
            self.LastSpellID = 0
            self.LastSpellTargetID = 0
        end
    end
    if mq.TLO.Me.Casting.ID() == 0 and not self.LastSpellID then
        self.LastSpellID = 0
        self.LastSpellTargetID = 0
    end

    self.IsInGame = (mq.TLO.EverQuest.GameState() == "INGAME")
    self:RepopulateAllies()
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
    self.StunAI.Output = self.StunAI:Cast(elixir)
    self.CharmAI.Output = self.CharmAI:Cast(elixir)
    self.HotAI.Output = self.HotAI:Cast(elixir)
    self.MezAI.Output = self.MezAI:Cast(elixir)
    self.CureAI.Output = self.CureAI:Cast(elixir)
    self.TargetAI.Output = self.TargetAI:Check(elixir)
    self.DebuffAI.Output = self.DebuffAI:Cast(elixir)
    self.DotAI.Output = self.DotAI:Cast(elixir)
    self.NukeAI.Output = self.NukeAI:Cast(elixir)
    self.BuffAI.Output = self.BuffAI:Cast(elixir)
    self.MoveAI.Output = self.MoveAI:Cast(elixir)
    self.ArcheryAI.Output = self.ArcheryAI:Cast(elixir)
    self.AttackAI.Output = self.AttackAI:Cast(elixir)
    self.MeditateAI.Output = self.MeditateAI:Check(elixir)
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
