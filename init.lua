---@type Mq
local mq = require('mq')

require('ai/elixir')
require ('ui')

elixir:Initialize("v0.5.10")

---@param line string # line that triggered event
---@param spellName string # Spell Name being memorized
local function OnNewSpellMemmed(line, spellName)
    elixir:DebugPrintf("new spell %s memorized, updating spell list", spellName)
    local spellNum = mq.TLO.Me.Book(spellName)
    if type(spellNum) ~= 'number' then return end
    local spell = mq.TLO.Me.Book(spellNum)
    if not spell() then return end
    elixir.SpellPicker:AddSpell(spell)
    elixir.SpellPicker:SortMap(elixir.SpellPicker.Spells)
end

mq.event('NewSpellMemmed', '#*#You have finished scribing #1#.', OnNewSpellMemmed)

mq.imgui.init('elixir', OverlayRender)
mq.imgui.init('elixir', SettingsRender)

while not elixir.IsTerminated do
    elixir:Update()
    mq.delay(500)
end