---@type Mq
local mq = require('mq')

---@class target
---@field public Output string # AI Debug String
---@field public IsTargetAttackable boolean # Is the current target deemed attackable?
---@field private targetCooldown number # cooldown timer to use target
target = {
    Output = '',
    targetCooldown = 0
}

---Attempts to cast a target spell
---@param elixir elixir
function target:Check(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end

    if not elixir.Config.IsTargetAI then
        self.IsTargetAttackable = true
        return "target ai not running"
    end
    self.IsTargetAttackable = false
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return string.format("on zone cooldown for %d seconds", math.ceil((elixir.ZoneCooldown-mq.gettime())/1000)) end
    if self.targetCooldown and self.targetCooldown > mq.gettime() then return string.format("on target cooldown for %d seconds", math.ceil((self.targetCooldown-mq.gettime())/1000)) end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "moving" end
    if mq.TLO.Me.Casting.ID() then return string.format("already casting %s", mq.TLO.Me.Casting.Name()) end
    if mq.TLO.Window("Casting").Open() then return "casting window open" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end
    if not mq.TLO.Me.GroupSize() then return "not in a group to assist" end
    if not mq.TLO.Group.MainAssist or not mq.TLO.Group.MainAssist.ID() then return "no main assist in group" end
    local spawnID = mq.TLO.Me.GroupAssistTarget.ID()
    if not spawnID then return "no assist target available" end
    local spawn = mq.TLO.Spawn(spawnID)
    if not spawn() then return "no assist target found" end
    if spawn.Distance() > elixir.Config.TargetMinRange then return spawn.Name() .. " too far to assist" end
    if not spawn.LineOfSight() then return spawn.Name() .. " is not line of sight" end
    if spawn.Type() ~= "NPC" then return spawn.Name() .. " is not NPC" end

    
    if mq.TLO.Target() and mq.TLO.Target.ID() == spawnID then
        self.IsTargetAttackable = true
        if mq.TLO.Pet() and
        mq.TLO.Pet.ID() > 0 and
        (not mq.TLO.Pet.Target() or mq.TLO.Pet.Target.ID() ~= spawnID) and
        elixir.Config.IsTargetPetAssist and
        mq.TLO.Pet.ID() ~= spawnID then
            mq.cmd("/pet attack")
            self.targetCooldown = mq.gettime() + 1000
            return "setting pet to attack "..spawn.Name()
        end
        
        return "already assisting ".. spawn.Name()
    end
    self.targetCooldown = mq.gettime() + 6000
    mq.cmd(string.format("/target id %d", spawnID))
    --elixir.IsActionCompleted = true
    --elixir.LastActionOutput = string.format("assisting %s on %s", mq.TLO.Group.MainAssist.Name(), spawn.Name())
    return elixir.LastActionOutput
end

return target