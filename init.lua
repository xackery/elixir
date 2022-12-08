---@type Mq
local mq = require('mq')

require('ai/elixir')
require ('ui')

elixir:Initialize()

mq.imgui.init('elixir', OverlayRender)
mq.imgui.init('elixir', SettingsRender)

while not elixir.IsTerminated do
    elixir:Update()
    mq.delay(1000)
end