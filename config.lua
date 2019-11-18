local _, cfg = ... --import config

--global settings
local MediaPath = 'Interface\\AddOns\\oUF_Bob\\media\\' --Set the media path
cfg.statusbar_texture = MediaPath..'statusbar' --Set the StatusBar
cfg.font = 'Fonts\\ARIALN.ttf' --base font
cfg.style = 'THINOUTLINE' 	--'OUTLINE', 'THINOUTLINE', 'MONOCHROME', or nil
cfg.font_size = 12

cfg.castbar_color = { 255/255, 255/255, 0/255 } --Color the castbars
cfg.bColor = { 0, 0, 0, .5 } --This adjusts the backround color/alpha

cfg.Auras = {
	onlyShowPlayer = false, --show only auras player has applied
	disableCooldown = false, --disable the cooldown pie
	showStealableAuras = true, --show if a buff is stealable
	gap = true, --this will put a 1 icon gap between buffs and debuffs
	size = 20, --aura size
	spacing = 1, --spaces between auras
	number = 12, --maximum number of buffs to display
}
--unit settings
cfg.player = {
	position = { 'CENTER', -200, -200 },
	width = 150,
	height = 60,
	castbar_pos = { 'BOTTOM', 0, -3 }, -- alternatively you can use:{ 'CENTER', UIParent, 0, 0 }
	cast_width = 150,
	cast_height = 15,
	portrait = true,
	auras = true,
}
cfg.pet = {
	position = { 'CENTER', -200, -270 },
	width = 100,
	height = 60,
	portrait = true,
}
cfg.target = {
	position = { 'CENTER', 200, -200 },
	width = 150,
	height = 60,
	castbar_pos = { 'BOTTOM', 0, -3 }, -- alternatively you can use:{ 'CENTER', UIParent, 0, 0 }
	cast_width = 150,
	cast_height = 15,
	portrait = true,
	auras = true,
}
cfg.tot = {  --Target of Target
	position = { 'CENTER', 393, -200 },
	width = 100,
	height = 60,
}
--------------------------------------------
--------------------------------------------
--Need to investigate these sometime, I do believe it is functional though
cfg.group = { --Raid and Party share these settings
	enable = true, --enable/disable the group frames
	position = {'TOPLEFT', UIParent, 15, -50}, --position
	width = 60,
	height = 45,
	maxColumns = 8, --Columns are groups of units
	unitsPerColumn = 5,
	groupBy = 'ASSIGNEDROLE',
	groupingOrder = 'MAINTANK, MAINASSIST, TANK, HEALER, DAMAGER, NONE',
	point = 'LEFT',
	columnAnchor = 'TOP',
	LFRRole = true,
}