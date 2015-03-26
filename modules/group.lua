local _, cfg = ... --import config
local _, ns = ... --get addon namespace
local _, playerClass = UnitClass("player")
local isBeautiful = IsAddOnLoaded("!Beautycase") --!Beautycase check

if not cfg.group.enable then return end
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
--Spawn Indicators
local indicatorPositions = { "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" }
local indicatorBackdrop = { bgFile = "Interface\\Buttons\\WHITE8X8" }
local function UpdateIndicators(self, event, unit)
    if(unit ~= self.indicators.unit) then return end
    for i = 1, #indicatorPositions do
        local position = indicatorPositions[i]
        local indicator = self.indicators[position]
        indicator:SetShown(UnitBuff(unit, indicator.aura) ~= nil)
    end
end
------------------------------------------------------------------------
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
	NameText:SetPoint("BOTTOM", Health, "TOP", 0,-12) -- but anchor to the base element so it doesn't wiggle
	NameText:SetFont(cfg.font, 8, cfg.style)
	NameText:SetJustifyH("CENTER")
	self:Tag(NameText, "[name]") -- oUF will automagically update it!
	Health.text = NameText
	--Health Percent
	local HealthText = Health:CreateFontString(nil, "OVERLAY", "TextStatusBarText") -- parent to last child to make sure it's on top
	HealthText:SetPoint("TOP", Health, "BOTTOM", 0,12) -- but anchor to the base element so it doesn't wiggle
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
	-- Position and size
	local RaidRole = self.Health:CreateTexture(nil, 'OVERLAY')
	RaidRole:SetSize(16, 16)
	RaidRole:SetPoint('TOPLEFT')
   
	-- Register it with oUF
	self.RaidRole = RaidRole
	
	-----------------------------
	-- LFD Role
	-- Position and size
	local LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
	LFDRole:SetSize(16, 16)
	LFDRole:SetPoint("TOPLEFT", self.Health)
   
	-- Register it with oUF
	self.LFDRole = LFDRole
   
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
   	----------------------------
	-------- Indicaters --------
	----------------------------
	if cfg.indicators.enable then
        local indicators = CreateFrame("Frame", nil ,self)
        indicators:SetAllPoints(true)
        indicators:EnableMouse(false)
        self.indicators = indicators
        self.indicators.unit = unit
        -- Build the indicators
        for i = 1, #indicatorPositions do
            local position = indicatorPositions[i]
            local indicator = CreateFrame("Frame", nil, indicators)
            indicator:Hide()
            indicator:SetPoint(position)
            indicator:SetSize(5, 5)
            indicator:SetBackdrop(indicatorBackdrop)
            indicator.aura = cfg.indicators["aura"..i]
            indicators[position] = indicator
        end
 
        -- Register the event on the frame itself
        self:RegisterEvent("UNIT_AURA", UpdateIndicators)
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