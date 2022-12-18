---@type Mq
local mq = require('mq')

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
