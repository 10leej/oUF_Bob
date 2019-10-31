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
	-- Plugin: oUF_RaidDebuff --
	----------------------------
	--[[
	local dbh = self:CreateTexture(nil, "OVERLAY")
	dbh:SetAllPoints(self)
	dbh:SetTexture("cfg.statusbar_texture")
	dbh:SetBlendMode("ADD")
	dbh:SetVertexColor(0,0,0,0) -- set alpha to 0 to hide the texture
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlight = dbh
	]]
end

--Spawn Frames
oUF:RegisterStyle('BobGroup', Shared)
oUF:Factory(function(self)
	self:SetActiveStyle'BobGroup'
	local party = self:SpawnHeader(nil, nil, 'raid,party,solo',
       'showRaid', true,
        'showSolo', false,
        'showPlayer', true,
        'showParty', true,
        'yOffset', -1,
        'groupFilter', '1,2,3,4,5,6,7,8',
        'groupBy', cfg.group.groupBy,
        'groupingOrder', cfg.group.groupingOrder,
        'maxColumns', cfg.group.maxColumns,
        'unitsPerColumn', cfg.group.unitsPerColumn,
        'columnSpacing', 1,
        'point', cfg.group.point,
        'startingIndex',1,
        'columnAnchorPoint', cfg.group.columnAnchor
	)

	party:SetScript("OnEvent", function(self, event, unit)
		party:UnregisterEvent(event)
		local function UpdatePosition(party)
			party:ClearAllPoints()
			party:SetPoint(unpack(cfg.group.position))
		end
		UpdatePosition(party)
		party:SetScript('OnEvent', UpdatePosition)
	end)
	party:RegisterEvent('PLAYER_ENTERING_WORLD')
end)