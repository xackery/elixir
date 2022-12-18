---@type Mq
local mq = require('mq')

---@class charm
---@field public Output string # AI Debug String
---@field public IsCurrentTargetValid boolean # Is Charm currently valid, used in UI
---@field public LastTargetID number # last target ID, used in UI
---@field public ID number # current charm spawn ID
---@field public Name string # current charm spawn name
---@field private charmCooldown number # cooldown between charming
charm = {
    Output = '',
    charmCooldown = 0,
    Name = '',
    ID = 0,
    LastTargetName = '',
    LastTargetID = 0,
}

---Attempts to cast a charm spell
---@param elixir elixir
function charm:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsCharmAI then return "charm ai not running" end

    -- Check for UI related button display
    if self.IsCurrentTargetValid and
    (not mq.TLO.Target() or mq.TLO.Target.Type() ~= "NPC") then
        self.IsCharmCurrentValid = false
        self.LastTargetID = 0
        self.LastTargetName = ""
    end

    if not self.IsCurrentTargetValid and
    mq.TLO.Target() and
    mq.TLO.Target.Type() == "NPC" then
        self.IsCurrentTargetValid = true
        self.LastTargetID = mq.TLO.Target.ID()
        self.LastTargetName = mq.TLO.Target.Name()
    end

    if mq.TLO.Target.ID() ~= self.LastTargetID and
    mq.TLO.Target.Type() == "NPC" then
        self.LastTargetID = mq.TLO.Target.ID()
        self.LastTargetName = mq.TLO.Target.Name()
    end

    if not self.ID then return "no charm target set" end

    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return string.format("on zone cooldown for %d seconds", math.ceil((elixir.ZoneCooldown-mq.gettime())/1000)) end

    if self.charmCooldown and self.charmCooldown > mq.gettime() then string.format("on charm cooldown for %d seconds", math.ceil((self.charmCooldown-mq.gettime())/1000)) end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Me.Casting.ID() then return string.format("already casting %s", mq.TLO.Me.Casting.Name()) end
    if mq.TLO.Window("Casting").Open() then return "casting window open" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end
    local spawn = mq.TLO.Spawn(self.SpawnID)
    if not spawn() then
        self.ID = 0
        self.Name = "None"
        return "no charm target"
    end
    if mq.TLO.Pet() and
    mq.TLO.Pet.ID() then
        if mq.TLO.Pet.ID() ~= self.SpawnID then return "currently have another pet" end
        return spawn.Name() .. " charmed"
    end

    if spawn.Type() ~= "NPC" then
        self.SpawnID = 0
        self.Name = "None"
        return "charm is not NPC"
    end

    if not spawn.LineOfSight() then return "target "..spawn.Name().." is not line of sight" end

    local isCasted = false
    local lastCastOutput = "no charming ability found"

    for i = 1, mq.TLO.Me.NumGems() do
        if elixir.Gems[i].Tag.IsCharm and
            not elixir.Gems[i].IsIgnored then
            elixir:DebugPrintf("found charm at gem %d will cast on %d", i, spawn.ID())
            isCasted, lastCastOutput = charm:CastGem(elixir, spawn.ID(), i)
            elixir.Gems[i].Output = " charm ai: " .. lastCastOutput
            if isCasted then return lastCastOutput end
        end
    end
    return lastCastOutput
end

---Attempts to cast a charm gem
---@param elixir elixir
---@param spawnID number
---@param gemIndex number
---@returns isSuccess boolean, castOutput string
function charm:CastGem(elixir, spawnID, gemIndex)

    local spellTag = elixir.Gems[gemIndex].Tag

    local spell = mq.TLO.Me.Gem(gemIndex)
    if not mq.TLO.Me.SpellReady(gemIndex)() then return false, spell.Name().." not ready" end
    if not spell() then return false, "no spell found" end
    if spell.Mana() > mq.TLO.Me.CurrentMana() then return false, "not enough mana (" .. mq.TLO.Me.CurrentMana() .. "/" .. spell.Mana() .. ")" end    
    if mq.TLO.Target.Buff(spell.Name()).ID() then return false, "target already has "..spell.Name().." on them" end
    if mq.TLO.Spawn(spawnID).Distance() > spell.Range() then return false, "target too far away" end

    self.charmCooldown = mq.gettime() + 1000
    elixir.LastActionOutput = string.format("charm ai casting %s on %s", spell.Name(), mq.TLO.Spawn(spawnID).Name())
    elixir.isActionCompleted = true
    if not mq.TLO.Target() or mq.TLO.Target.ID() ~= spawnID then
        mq.cmdf('/target id %d', spawnID)
    end
    mq.cmdf("/cast %d", gemIndex)
    elixir.LastSpellTargetID = spawnID
    elixir.LastSpellID = spell.ID()
    --mq.delay(5000, WaitOnCasting)
    return true, elixir.LastActionOutput
end

return charm