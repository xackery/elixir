---@type Mq
local mq = require('mq')

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
config = {
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

return config