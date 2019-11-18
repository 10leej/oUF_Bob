local _, cfg = ... --import config
local addon, ns = ... --get addon namespace

--[[
-- store and disable the method
local orig = oUF.DisableBlizzard
oUF.DisableBlizzard = nop
 
-- spawn your frames
oUF:Spawn('player')
 
-- re-enable the method
oUF.DisableBlizzard = orig
]]