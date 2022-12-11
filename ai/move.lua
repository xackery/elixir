---@type Mq
local mq = require('mq')

require('logic')

---@class move
---@field public Output string # AI Debug String
---@field private moveCooldown number # cooldown timer to use move
move = {
    Output = '',
    moveCooldown = 0,
}

---Attempts to cast a move
---@param elixir elixir
---@returns output string
function move:Cast(elixir)
    if not elixir.Config.IsElixirAI then return "elixir ai not running" end
    if not elixir.Config.IsMoveAI then return "move ai not running" end
    if elixir.Config.IsElixirDisabledOnFocus and elixir.IsEQInForeground then return "window focused, ai frozen" end
    if elixir.ZoneCooldown > mq.gettime() then return "on zone cooldown" end
    if self.moveCooldown and self.moveCooldown > mq.gettime() then return "on move cooldown" end
    if elixir.IsActionCompleted then return "previous action completed" end
    if mq.TLO.Me.Stunned() then return "stunned" end
    if AreObstructionWindowsVisible() then return "window obstructs casting" end
    if mq.TLO.Me.Moving() then return "already moving" end
    if mq.TLO.Me.Casting.ID() then return string.format("already casting %s", mq.TLO.Me.Casting.Name()) end
    if mq.TLO.Window("Casting").Open() then return "casting window open" end
    if mq.TLO.Me.Animation() == 16 then return "feign death" end

    -- tank > camp, can only choose one
    if elixir.Config.IsMoveToTank and elixir.Config.IsMoveToCamp then
        elixir.Config.IsMoveToCamp = false
    end
    --- melee > archery > strategy can only choose one
    if elixir.Config.IsMoveToArcheryInCombat and elixir.Config.IsMoveToMeleeInCombat then
        elixir.Config.IsMoveToArcheryInCombat = false
    end
    if elixir.Config.IsMoveToArcheryInCombat and elixir.Config.IsMoveToStrategyPointInCombat then
        elixir.Config.IsMoveToStrategyPointInCombat = false
    end
    if elixir.Config.IsMoveToMeleeInCombat and elixir.Config.IsMoveToStrategyPointInCombat then
        elixir.Config.IsMoveToStrategyPointInCombat = false
    end

    local lastOutput = ""
    local isChecked = false

    if elixir.Config.IsMoveToTank then
        isChecked, lastOutput = self:MoveToTank()
        if isChecked then return lastOutput end
    end

    if elixir.Config.IsMoveToCamp then
        isChecked, lastOutput = self:MoveToCamp()
        if isChecked then return lastOutput end
    end

    if elixir.Config.IsMoveToMeleeInCombat then
        isChecked, lastOutput = self:MoveToMelee()
        if isChecked then return lastOutput end
    end

    if elixir.Config.IsMoveToArcheryInCombat then
        isChecked, lastOutput = self:MoveToArchery()
        if isChecked then return lastOutput end
    end

    if elixir.Config.IsMoveToStrategyPointInCombat then
        isChecked, lastOutput = self:MoveToStrategyPoint()
        if isChecked then return lastOutput end
    end

    return lastOutput
end

---@returns isChecked boolean, output string 
function move:MoveToTank()
    local spawn = mq.TLO.Group.MainTank
    if not spawn() then return false, "no main tank to move to" end
    if spawn.Distance() < elixir.Config.MoveToTankMaxDistance then return false, "tank is not too far away" end
    return move:MoveTo(spawn.ID())
end

---@returns isChecked boolean, output string 
function move:MoveToCamp()
    if IsInCombat() and not elixir.Config.IsMoveToCampDuringCombat then return false, "in combat, not moving back to camp" end

    return false, "no"
end

---@returns isChecked boolean, output string 
function move:MoveToMelee()
    if not IsInCombat() then return false, "not in combat" end    
    if not elixir.TargetAI.IsTargetAttackable then return false, "target is not attackable" end
    return false, "no"
end

---@returns isChecked boolean, output string 
function move:MoveToArchery()
    if not IsInCombat() then return false, "not in combat" end
    if not elixir.TargetAI.IsTargetAttackable then return false, "target is not attackable" end
    return false, "no"
end

---@returns isChecked boolean, output string 
function move:MoveToStrategyPoint()
    if not IsInCombat() then return false, "not in combat" end
    if not elixir.TargetAI.IsTargetAttackable then return false, "target is not attackable" end
    return false, "no"
end

---MoveTo is used to try to move to a spawn location
---@param spawnID number
---@returns isMoving boolean, output string
function move:MoveTo(spawnID)
    local spawn = mq.TLO.Spawn(spawnID)
    if not spawn() then return false, "invalid spawn" end
    -- TODO: check if nav is already active in some capacity
    if elixir.Config.MoveType == "nav" then
        mq.cmd("/nav spawn id "..spawn.ID())
        return true, "moving to "..spawn.Name()
    end
    if elixir.Config.MoveType == "advpath" then
        mq.cmd("/afollow id "..spawn.ID())
        return true, "following "..spawn.Name()
    end
    if elixir.Config.MoveType == "moveutils" then
        mq.cmd("/moveto id "..spawn.ID())
        return true, "moveto "..spawn.Name()
    end
    if elixir.Config.MoveType == "dynamic" then
        --TODO: smarter dynamics
        mq.cmd("/nav spawn id "..spawn.ID())
        return true, "moving to "..spawn.Name()
    end
end

---MoveTo is used to try to move to a spawn location
---@param x number
---@param y number
---@param z number
---@returns isMoving boolean, output string
function move:MoveToLoc(x, y, z)
    -- TODO: check if nav is already active in some capacity
    if elixir.Config.MoveType == "nav" then
        mq.cmd(string.format("/nav locxyz %d %d %d", x, y, z))
        return true, string.format("moving to %d %d %d", x, y, z)
    end
    if elixir.Config.MoveType == "advpath" then
        return false, "cannot move to loc with advpath"
    end
    if elixir.Config.MoveType == "moveutils" then
        mq.cmd(string.format("/moveto loc %d %d %d", y, x, z))
        return true, string.format("moving to %d %d %d", x, y, z)
    end
    if elixir.Config.MoveType == "dynamic" then
        mq.cmd(string.format("/moveto loc %d %d %d", y, x, z))
        return true, string.format("moving to %d %d %d", x, y, z)
    end
end

return move