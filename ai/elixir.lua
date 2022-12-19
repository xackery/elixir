---@type Mq
local mq = require('mq')
require('ai/gem')

local Version = "v0.5.10"


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
---@field public SpellPicker SpellPicker # Spell picker for UI context menu
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
    SpellPicker = require('ai/spell_picker'),
    ZoneCooldown = 0,
    IsActionCompleted = false,
    lastZoneID = 0,
    SettingsTabIndex = 16,
    LastOverlayWindowHeight = 0,
    IsTankInParty = false,
}

elixir.Config = require('ai/config')

---@class Button
---@field IsIgnored bool # Ignore this gem for AI
---@field Output string # Tooltip message on state of this gem
Button = {}

---- Cooldown due to movement
---@type number
MovementGlobalCooldown = nil

function elixir:Initialize()
    self.Version = Version
    elixir:DebugPrintf("starting elixir %s", self.Version)
    --loadConfig()
    --sanitizeConfig()

    --if not mq.TLO.Plugin('mq2dannet').IsLoaded() then
    --    elixir:DebugPrintf("plugin \ayMQ2DanNet\ax is required. Loading it now.")
    --    mq.cmd('/plugin mq2dannet noauto')
    --end

    --if not mq.TLO.Plugin('mq2dannet').IsLoaded() then
    --    elixir:DebugPrintf("failed to load MQDannet, failing")
    --    mq.exit()
    --end
    
    self.ConfigPath = mq.configDir
    for i = 1, mq.TLO.Me.NumGems() do
        self.Gems[i] = Gem.new()
    end

    self.SpellPicker:Refresh()

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

    if mq.TLO.Me.Casting.ID() and
    elixir.LastSpellTargetID > 0 and
    mq.TLO.Me.Casting.ID() == self.LastSpellID then
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
    print("\at[Elixir] "..s:format(...).."\ax")
end

return elixir
