local _, cfg = ... --import config
local _, ns = ... --get addon namespace
local _, playerClass = UnitClass("player")

--global settings
local MediaPath = 'Interface\\AddOns\\oUF_Bob\\media\\' --Set the media path
cfg.statusbar_texture = MediaPath..'statusbar' --Set the StatusBar
cfg.font = 'Fonts\\ARIALN.ttf' --base font
cfg.style = 'THINOUTLINE' 	--'OUTLINE', 'THINOUTLINE', 'MONOCHROME', or nil
cfg.font_size = 10

cfg.castbar_color = { 255/255, 255/255, 0/255 } --Color the castbar
cfg.bColor = { 0, 0, 0, .5 } --This adjusts the backround color/alpha

cfg.Auras = {
	onlyShowPlayer = true, --show only auras player has applied
	disableCooldown = false, --disable the cooldown pie
	showStealableAuras = true, --show if a buff is stealable
	gap = true, --this will put a 1 icon gap between buffs and debuffs
	size = 20, --aura size
	spacing = 1, --spaces between auras
	number = 12, --maximum number of buffs to display
}
cfg.AlternatePower = {
	position = { "TOP", UIParent, 200, 0 },
	width = 125,
	height = 20 ,
	color = { 75, 0, 0 },
}
--unit settings
cfg.player = {
	position = { 'CENTER', -200, -180 },
	width = 125,
	height = 60,
	castbar_pos = { 'CENTER', UIParent, 0, -145 },
	cast_width = 200,
	cast_height = 15,
	portrait = true,
}
cfg.pet = {
	position = { 'CENTER', -200, -250 },
	width = 100,
	height = 50,
	portrait = true,
}
cfg.target = {
	position = { 'CENTER', 200, -180 },
	width = 125,
	height = 60,
	castbar_pos = { 'CENTER', UIParent, 0, -130 },
	cast_width = 200,
	cast_height = 15,
	portrait = true,
}
cfg.tot = {  --Target of Target
	position = { 'CENTER', 385, -180 },
	width = 100,
	height = 50,
}
cfg.focus = {
	position = { 'CENTER', -300, 0 },
	width = 125,
	height = 60,
	portrait = true,
}
cfg.boss = { --Arena will use the same settings
	position = { 'RIGHT', -300, 200 },
	width = 125,
	height = 60,
	portrait = false,
}
--------------------------------------------
--------------------------------------------
cfg.group = { --Raid and Party share these settings
	enable = false, --enable/disable the group frames
	showSolo = true,
	position = {'BOTTOMLEFT', ChatFrame1EditBox, "TOPLEFT", 0, 1}, --position for tanks/dps
	healposition = {'CENTER', UIParent, 0, -275}, --position for healers
	width = 50,
	height = 45,
	offsety = 0,
	offsetx = 0,
	columns = 8,
	unitpercolumn = 5,
	sortmethod = 'INDEX', --'INDEX', 'NAME', 'NAMELIST'
	growth = 'RIGHT', --'LEFT' or 'RIGHT'
	groupby = 'GROUP',--nil, 'GROUP', 'CLASS', 'ROLE', 'ASSIGNEDROLE'
    RaidDeBuff = true,
}

cfg.indicators = { --sorted by class not spec
	enable = true,
	aura1 =	"Renew", --Top left
	aura2 =	"Power Word: Shield", --Top Right
	aura3 =	"Renew", --Bottom Left
	aura4 =	"Power Word: Shield", --Bottom Right
}

--[[
	deathknight = {--death knight
		aura1 =	"Renew", --Top left
		aura2 =	"Power Word: Shield", --Top Right
		aura3 =	"Renew", --Bottom Left
		aura4 =	"Power Word: Shield", --Bottom Right
	druid = {--druid
		aura1 =	"Renew", --Top left
		aura2 =	"Power Word: Shield", --Top Right
		aura3 =	"Renew", --Bottom Left
		aura4 =	"Power Word: Shield", --Bottom Right
	hunter = {--hunter
		aura1 =	"Renew", --Top left
		aura2 =	"Power Word: Shield", --Top Right
		aura3 =	"Renew", --Bottom Left
		aura4 =	"Power Word: Shield", --Bottom Right
	mage = {--mage
		aura1 =	"Renew", --Top left
		aura2 =	"Power Word: Shield", --Top Right
		aura3 =	"Renew", --Bottom Left
		aura4 =	"Power Word: Shield", --Bottom Right
	monk = {--monk
		aura1 =	"Renew", --Top left
		aura2 =	"Power Word: Shield", --Top Right
		aura3 =	"Renew", --Bottom Left
		aura4 =	"Power Word: Shield", --Bottom Right
	paladin = {--paladin
		aura1 =	"Renew", --Top left
		aura2 =	"Power Word: Shield", --Top Right
		aura3 =	"Renew", --Bottom Left
		aura4 =	"Power Word: Shield", --Bottom Right
	priest = {--Holy Priest
		aura1 =	"Renew", --Top left
		aura2 =	"Power Word: Shield", --Top Right
		aura3 =	"Renew", --Bottom Left
		aura4 =	"Power Word: Shield", --Bottom Right
	rogue = {--Holy Priest
		aura1 =	"Renew", --Top left
		aura2 =	"Power Word: Shield", --Top Right
		aura3 =	"Renew", --Bottom Left
		aura4 =	"Power Word: Shield", --Bottom Right
	shaman = {--Holy Priest
		aura1 =	"Renew", --Top left
		aura2 =	"Power Word: Shield", --Top Right
		aura3 =	"Renew", --Bottom Left
		aura4 =	"Power Word: Shield", --Bottom Right
	warlock = {--Holy Priest
		aura1 =	"Renew", --Top left
		aura2 =	"Power Word: Shield", --Top Right
		aura3 =	"Renew", --Bottom Left
		aura4 =	"Power Word: Shield", --Bottom Right
	warrior = {--Holy Priest
		aura1 =	"Renew", --Top left
		aura2 =	"Power Word: Shield", --Top Right
		aura3 =	"Renew", --Bottom Left
		aura4 =	"Power Word: Shield", --Bottom Right
]]