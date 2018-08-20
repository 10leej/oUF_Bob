local _, cfg = ... --import config
local _, ns = ... --get addon namespace
local _, playerClass = UnitClass("player")
local isBeautiful = IsAddOnLoaded("!Beautycase") --!Beautycase check

if not cfg.group.enable then return end

-----------------------------
-- functions
-----------------------------
-- Backdrop function, this is also how we cheese borders on things
local function CreateBackdrop(frame)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8",
        insets = {top = 1, left = 1, bottom = 1, right = 1}})
    frame:SetBackdropColor(unpack(cfg.bColor))
	if isBeautiful then
		frame:CreateBeautyBorder(12)
		frame:SetBeautyBorderPadding(1)
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
	--Health:CreateBeautyBorder(12)
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
	local RaidTargetIndicator = self.Health:CreateTexture(nil, 'OVERLAY')
	RaidTargetIndicator:SetSize(16, 16)
	RaidTargetIndicator:SetPoint('CENTER', self.Health)
	
	-- Register it with oUF
	self.RaidTargetIndicator = RaidTargetIndicator
	
	-----------------------------
	-- Raid Roles
	-- Position and size
	local RaidRoleIndicator = self.Health:CreateTexture(nil, 'OVERLAY')
	RaidRoleIndicator:SetSize(12, 12)
	RaidRoleIndicator:SetPoint('TOPLEFT')
   
	-- Register it with oUF
	self.RaidRoleIndicator = RaidRoleIndicator
	
	-----------------------------
	-- LFD Role
	-- Position and size
	local GroupRoleIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	GroupRoleIndicator:SetSize(12, 12)
	GroupRoleIndicator:SetPoint("TOPLEFT", self.Health)
   
	-- Register it with oUF
	self.GroupRoleIndicator = GroupRoleIndicator
	
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
	--Let dynamically update this so when we change spec frames auto move
	party:SetScript("OnEvent", function(self, event, unit)
	if event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" then
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
		end
	end)
	party:RegisterEvent("PLAYER_TALENT_UPDATE")
	party:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	party:RegisterEvent("PLAYER_ENTERING_WORLD")
end)
