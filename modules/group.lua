local _, cfg = ... --import config
local _, ns = ... --get addon namespace
local _, playerClass = UnitClass("player")
local isBeautiful = IsAddOnLoaded("!Beautycase") --!Beautycase check

if not cfg.group.enable then return end

-----------------------------
-- locals
-----------------------------
local indicatorList --Hey guys looks like I finally got something working here!
--also indicators are based on NeavRaid's indicators if there more you want added to the list let me know please.

-- Class buffs { spell ID, position [, {r, g, b, a}][, anyUnit][, hideCooldown][, hideCount] }
do
    indicatorList = {
        DRUID = {
            {774, 'BOTTOMRIGHT', {1, 0.2, 1}}, -- Rejuvenation
            {33763, 'BOTTOM', {0.5, 1, 0.5}, false, false, true}, -- Lifebloom
            {48438, 'BOTTOMLEFT', {0.7, 1, 0}}, -- Wild Growth
        },
        MONK = {
            {119611, 'BOTTOMRIGHT', {0, 1, 0}}, -- Renewing Mist
            {124682, 'BOTTOMLEFT', {0.15, 0.98, 0.64}}, -- Enveloping Mist
            {115175, 'TOPRIGHT', {0.15, 0.98, 0.64}}, -- Soothing Mist
            {116849, 'TOPLEFT', {1, 1, 0}}, -- Life Cocoon
            {124081, 'BOTTOMLEFT', {0.7, 0.8, 1}}, -- Zen Sphere
        },
        PALADIN = {
            {53563, 'BOTTOMRIGHT', {0, 1, 0}}, -- Beacon of Light
            {20925, 'BOTTOMRIGHT', {1, 1, 0}}, -- Sacred Shield
        },
        PRIEST = {
            {6788, 'BOTTOMRIGHT', {0.6, 0, 0}, true}, -- Weakened Soul (hmm not working)
            {17, 'BOTTOMRIGHT', {1, 1, 0}}, -- Power Word: Shield
            {33076, 'TOPRIGHT', {1, 0.6, 0.6}, false, true}, -- Prayer of Mending
            {139, 'BOTTOMLEFT', {0, 1, 0}}, -- Renew
        },
        SHAMAN = {
            {61295, 'TOPLEFT', {0.7, 0.3, 0.7}}, -- Riptide
            {974, 'BOTTOMRIGHT', {0.7, 0.4, 0}, false, true}, -- Earth Shield
        },
        WARLOCK = {
            {20707, 'BOTTOMRIGHT', {0.7, 0, 1}, true, true}, -- Soulstone
        },
        ALL = {
            {23333, 'TOPLEFT', {1, 0, 0}}, -- Warsong flag, Horde
            {23335, 'TOPLEFT', {0, 0, 1}}, -- Warsong flag, Alliance 
        },
    }
end

local function AuraIcon(self, icon)
    if (icon.cd) then
        icon.cd:SetReverse(true)
        icon.cd:SetAllPoints(icon.icon)
        icon.cd:SetHideCountdownNumbers(true)
    end
end

local offsets
do
    local space = 2

    offsets = {
        TOPLEFT = {
            icon = {space, -space},
            count = {'TOP', icon, 'BOTTOM', 2, -2},
        },

        TOPRIGHT = {
            icon = {-space, -space},
            count = {'TOP', icon, 'BOTTOM', -2, -2},
        },

        BOTTOMLEFT = {
            icon = {space, space},
            count = {'LEFT', icon, 'RIGHT', 2, 2},
        },

        BOTTOMRIGHT = {
            icon = {-space, space},
            count = {'RIGHT', icon, 'LEFT', -2, 2},
        },

        LEFT = {
            icon = {space, 0},
            count = {'LEFT', icon, 'RIGHT', 1, 0},
        },

        RIGHT = {
            icon = {-space, 0},
            count = {'RIGHT', icon, 'LEFT', -1, 0},
        },

        TOP = {
            icon = {0, -space},
            count = {'CENTER', icon, 0, 0},
        },

        BOTTOM = {
            icon = {0, space},
            count = {'CENTER', icon, 0, 0},
        },
    }
end


-----------------------------
-- functions
-----------------------------
-- Backdrop function
local function CreateBackdrop(frame)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8",
        insets = {top = 1, left = 1, bottom = 1, right = 1}})
    frame:SetBackdropColor(unpack(cfg.bColor))
	if isBeautiful then
		frame:CreateBeautyBorder(12)
		frame:SetBeautyBorderPadding(1)
	end
end
local function CreateIndicators(self, unit)
    self.AuraWatch = CreateFrame('Frame', nil, self)
    self.AuraWatch.presentAlpha = 1
    self.AuraWatch.missingAlpha = 0
    self.AuraWatch.hideCooldown = false
    self.AuraWatch.noCooldownCount = true
    self.AuraWatch.icons = {}
    self.AuraWatch.PostCreateIcon = AuraIcon

    local buffs = {}

    if (indicatorList['ALL']) then
        for key, value in pairs(indicatorList['ALL']) do
            tinsert(buffs, value)
        end
    end

    if (indicatorList[playerClass]) then
        for key, value in pairs(indicatorList[playerClass]) do
            tinsert(buffs, value)
        end
    end

    if (buffs) then
        for key, spell in pairs(buffs) do
            local icon = CreateFrame('Frame', nil, self.AuraWatch)
            icon:SetWidth(7)
            icon:SetHeight(7)
            icon:SetPoint(spell[2], self.Health, unpack(offsets[spell[2]].icon))

            icon.spellID = spell[1]
            icon.anyUnit = spell[4]
            icon.hideCooldown = spell[5]
            icon.hideCount = spell[6]

                -- exception to place PW:S above Weakened Soul

            if (spell[1] == 17) then
                icon:SetFrameLevel(icon:GetFrameLevel() + 5)
            end

                -- indicator icon

            icon.icon = icon:CreateTexture(nil, 'OVERLAY')
            icon.icon:SetAllPoints(icon)
            icon.icon:SetTexture("Interface\\Buttons\\WHITE8x8")

            if (spell[3]) then
                icon.icon:SetVertexColor(unpack(spell[3]))
            else
                icon.icon:SetVertexColor(0.8, 0.8, 0.8)
            end

            if (not icon.hideCount) then
                icon.count = icon:CreateFontString(nil, 'OVERLAY')
                icon.count:SetShadowColor(0, 0, 0)
                icon.count:SetShadowOffset(1, -1)
                icon.count:SetPoint(unpack(offsets[spell[2]].count))
                icon.count:SetFont(cfg.font, 13)
            end

            self.AuraWatch.icons[spell[1]] = icon
        end
    end
end
------------------------------------------------------------------
-- Shared settings
------------------------------------------------------------------------
local function Shared(self, unit, isSingle)
	unit = gsub(unit, "%d", "")

	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self:RegisterForClicks'AnyUp'
	
	self:SetWidth(cfg.group.width)
	self:SetHeight(cfg.group.height)
	
	-----------------------------
	-- Health
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetStatusBarTexture(cfg.statusbar_texture)
	Health:SetPoint('TOP')
	Health:SetPoint('LEFT')
	Health:SetPoint('RIGHT')
	Health:SetHeight(cfg.group.height)
	CreateBackdrop(Health)
	-- Options
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.colorClass = true
	Health.colorReaction = true
	Health.colorHealth = true
	-- Register it with oUF
	self.Health = Health
	
	-----------------------------
	--Heal Prediction
	-- Position and size
	local myBar = CreateFrame('StatusBar', nil, self.Health)
	myBar:SetFrameStrata("BACKGROUND")
	myBar:SetPoint('TOP')
	myBar:SetPoint('BOTTOM')
	myBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
	myBar:SetWidth(cfg.group.width)
	myBar:SetStatusBarTexture(cfg.statusbar_texture)
	myBar:SetStatusBarColor(0,1,0)
   
	local otherBar = CreateFrame('StatusBar', nil, self.Health)
	otherBar:SetFrameStrata("BACKGROUND")
	otherBar:SetPoint('TOP')
	otherBar:SetPoint('BOTTOM')
	otherBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
	otherBar:SetWidth(cfg.group.width)
	otherBar:SetStatusBarTexture(cfg.statusbar_texture)
	otherBar:SetStatusBarColor(0,1,0)

	local healAbsorbBar = CreateFrame('StatusBar', nil, self.Health)
	healAbsorbBar:SetFrameStrata("BACKGROUND")
	healAbsorbBar:SetPoint('TOP')
	healAbsorbBar:SetPoint('BOTTOM')
	healAbsorbBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
	healAbsorbBar:SetWidth(cfg.group.width)
	healAbsorbBar:SetStatusBarTexture(cfg.statusbar_texture)
	healAbsorbBar:SetStatusBarColor(0,1,0)
   
   -- Register with oUF
   self.HealPrediction = {
      myBar = myBar,
      otherBar = otherBar,
      absorbBar = absorbBar,
      healAbsorbBar = healAbsorbBar,
      maxOverflow = 1.05,
      frequentUpdates = true,
   }
	
	-----------------------------
	--Text

	--Name
	local NameText = Health:CreateFontString(nil, "OVERLAY", "TextStatusBarText") -- parent to last child to make sure it's on top
	NameText:SetPoint("TOP",Health,0,-5) -- but anchor to the base element so it doesn't wiggle
	NameText:SetFont(cfg.font, 8, cfg.style)
	NameText:SetJustifyH("CENTER")
	self:Tag(NameText, "[name]") -- oUF will automagically update it!
	Health.text = NameText
	--Health Percent
	local HealthText = Health:CreateFontString(nil, "OVERLAY", "TextStatusBarText") -- parent to last child to make sure it's on top
	HealthText:SetPoint("BOTTOM",Health,0,5) -- but anchor to the base element so it doesn't wiggle
	HealthText:SetFont(cfg.font, 8, cfg.style)
	HealthText:SetJustifyH("CENTER")
	self:Tag(HealthText, "[perhp]") -- oUF will automagically update it!
	Health.text = HealthText

	-----------------------------
	-- Rez Icon
	-- Position and sizew
	local ResurrectIcon = self.Health:CreateTexture(nil, 'OVERLAY')
	ResurrectIcon:SetSize(16, 16)
	ResurrectIcon:SetPoint('CENTER', self.Health)
   
	-- Register it with oUF
	self.ResurrectIcon = ResurrectIcon
	
	-----------------------------
	-- Raid icons
	-- Position and size
	local RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
	RaidIcon:SetSize(16, 16)
	RaidIcon:SetPoint('CENTER', self.Health)
	
	-- Register it with oUF
	self.RaidIcon = RaidIcon
	
	-----------------------------
	-- Raid Roles
	if cfg.group.LFRRole then
		-- Position and size
		local RaidRole = self.Health:CreateTexture(nil, 'OVERLAY')
		RaidRole:SetSize(16, 16)
		RaidRole:SetPoint('TOPLEFT')
	   
		-- Register it with oUF
		self.RaidRole = RaidRole
	end
	
	-----------------------------
	-- LFD Role
	if cfg.group.LFRRole then
		-- Position and size
		local LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
		LFDRole:SetSize(16, 16)
		LFDRole:SetPoint("TOPLEFT", self.Health)

		-- Register it with oUF
		self.LFDRole = LFDRole
	end
   	------------------------
	-- Plugin: oUF_Smooth --
	------------------------
	if IsAddOnLoaded("oUF_Smooth") and not strmatch(unit, ".target$") then
		self.Health.Smooth = true
		if self.Power then
			self.Power.Smooth = true
		end
	end
   
   	----------------------------
	-- Plugin: oUF_SpellRange --
	----------------------------
	if IsAddOnLoaded("oUF_SpellRange") then
		self.SpellRange = {
			insideAlpha = 1,
			outsideAlpha = 0.5,
		}
	--Range
	elseif unit == "pet" or unit == "party" or unit == "partypet" then
		self.Range = {
			insideAlpha = 1,
			outsideAlpha = 0.5,
		}
	end
	
    if cfg.group.RaidDeBuff then
        self.RaidDebuffs = CreateFrame('Frame', nil, self)
        self.RaidDebuffs:SetHeight(18)
        self.RaidDebuffs:SetWidth(18)
        self.RaidDebuffs:SetPoint('CENTER', self)
        self.RaidDebuffs:SetFrameStrata'HIGH'

        self.RaidDebuffs:SetBackdrop(backdrop)

        self.RaidDebuffs.icon = self.RaidDebuffs:CreateTexture(nil, 'OVERLAY')
        self.RaidDebuffs.icon:SetTexCoord(.1,.9,.1,.9)
        self.RaidDebuffs.icon:SetAllPoints(self.RaidDebuffs)

        self.RaidDebuffs.cd = CreateFrame('Cooldown', nil, self.RaidDebuffs)
        self.RaidDebuffs.cd:SetAllPoints(self.RaidDebuffs)

        self.RaidDebuffs.ShowDispelableDebuff = true
        self.RaidDebuffs.FilterDispelableDebuff = true
        self.RaidDebuffs.MatchBySpellName = true
        self.RaidDebuffs.Debuffs = ns.raid_debuffs

        self.RaidDebuffs.count = self.RaidDebuffs:CreateFontString(nil, 'OVERLAY')
        self.RaidDebuffs.count:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')
        self.RaidDebuffs.count:SetPoint('BOTTOMRIGHT', self.RaidDebuffs, 'BOTTOMRIGHT', 2, 0)
        self.RaidDebuffs.count:SetTextColor(1, .9, 0)

        self.RaidDebuffs.SetDebuffTypeColor = self.RaidDebuffs.SetBackdropColor
    end
   	-----------------------------
	-- -Plugin: oUF_AuraWatch ---
	-----------------------------
	if IsAddOnLoaded("oUF_AuraWatch") then--oUF_AuraWatch check
		CreateIndicators(self, unit)
	end
end

--Spawn Frames
oUF:RegisterStyle('BobGroup', Shared)
oUF:Factory(function(self)
	self:SetActiveStyle'BobGroup'
	local party = self:SpawnHeader(nil, nil, 'raid,party',
		'showParty', true,
		'showPlayer', true,
		'showRaid', true,
		'showSolo', cfg.group.showSolo,
		'yOffset', cfg.group.offsety,
		'groupingOrder', "1,2,3,4,5,6,7,8",
		'maxColumns', cfg.group.columns,
		'unitsPerColumn', cfg.group.unitpercolumn,
		'columnAnchorPoint', cfg.group.growth,
		'sortMethod', cfg.group.sortmethod,
		'groupBy', cfg.group.groupby,
		'columnSpacing', cfg.group.offsetx,
		'point', 'LEFT',
		'columnAnchorPoint', 'BOTTOM'
	)
	--Positions (categorized by spec and class)
	if (playerClass == "PRIEST" and GetSpecialization() == 1) then
		party:SetPoint(unpack(cfg.group.healposition))
	elseif (playerClass == "PRIEST" and GetSpecialization() == 2) then
		party:SetPoint(unpack(cfg.group.healposition))
	elseif (playerClass == "PALADIN" and GetSpecialization() == 1) then
		party:SetPoint(unpack(cfg.group.healposition))
	elseif (playerClass == "DRUID" and GetSpecialization() == 4) then
		party:SetPoint(unpack(cfg.group.healposition))
	elseif (playerClass == "MONK" and GetSpecialization() == 2) then
		party:SetPoint(unpack(cfg.group.healposition))
	elseif (playerClass == "SHAMAN" and GetSpecialization() == 3) then
		party:SetPoint(unpack(cfg.group.healposition))
	else
		party:SetPoint(unpack(cfg.group.position))
	end
end)