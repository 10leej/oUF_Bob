local _, cfg = ... --import config
local _, ns = ... --get addon namespace
local _, playerClass = UnitClass("player")
local isBeautiful = IsAddOnLoaded("!Beautycase") --!Beautycase check
-----------------------------
-- Add custom functions (overrides)
local function CreateBackdrop(frame)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8",
        insets = {top = 0, left = 0, bottom = 0, right = 0}})
    frame:SetBackdropColor(unpack(cfg.bColor))
	if isBeautiful then
		frame:CreateBeautyBorder(12)
		frame:SetBeautyBorderPadding(1)
	end
end
local function Aura_PostCreateIcon(element, button)
	if isBeautiful then
		button:CreateBeautyBorder(12) --skin it
	else
		return
	end
end

------------------------------------------------------------------------
-- UnitSpecific settings
------------------------------------------------------------------------
local UnitSpecific = {
	player = function(self)
		-- player specific stuff
		self:SetSize(cfg.player.width,cfg.player.height)
		
		if not cfg.player.portrait then
			self.Portrait:SetAlpha(0)
		end
		self.Portrait:SetPoint('TOPRIGHT', self.Health, 'TOPLEFT', -2,0)
		self.Portrait:SetSize(cfg.player.height+4, cfg.player.height+4)
		
		self.Health:SetHeight(cfg.player.height/2)
		self.Power:SetHeight(cfg.player.height/4)
		
		self.Castbar:SetSize(cfg.player.cast_width, cfg.player.cast_height)
		self.Castbar:SetPoint(unpack(cfg.player.castbar_pos))
		
		self.Auras:Hide()
		
		-----------------------------
		-- Position and size
		local AltPowerBar = CreateFrame('StatusBar', nil, self)
		AltPowerBar:SetStatusBarTexture(cfg.statusbar_texture)
		AltPowerBar:SetStatusBarColor(unpack(cfg.AlternatePower.color))
		AltPowerBar:SetHeight(cfg.AlternatePower.height)
		AltPowerBar:SetWidth(cfg.AlternatePower.width)
		AltPowerBar:SetPoint(unpack(cfg.AlternatePower.position))
		CreateBackdrop(AltPowerBar)
		-- Register with oUF
		self.AltPowerBar = AltPowerBar
		
		--special bars for special classes
		if (playerClass == "DRUID" and GetSpecialization() == 1) then
			-- Eclipse Bar
			local EclipseBar = CreateFrame("Frame", nil, self)
			EclipseBar:SetPoint("TOP", self.Power, "BOTTOM", 0,0)
			EclipseBar:SetSize(cfg.player.width, cfg.player.height/4)
			self.EclipseBar = EclipseBar
			
			local LunarBar = CreateFrame("StatusBar", nil, EclipseBar)
			LunarBar:SetPoint("LEFT")
			LunarBar:SetSize(cfg.player.width, cfg.player.height/4)
			LunarBar:SetStatusBarTexture(cfg.statusbar_texture)
			LunarBar:SetStatusBarColor(0,0,.8)
			if isBeautiful then
				LunarBar:CreateBeautyBorder(12)
				LunarBar:SetBeautyBorderPadding(1)
			end
			EclipseBar.LunarBar = LunarBar
			
			local SolarBar = CreateFrame("StatusBar", nil, EclipseBar)
			SolarBar:SetPoint("LEFT", LunarBar:GetStatusBarTexture(), "RIGHT")
			SolarBar:SetSize(cfg.player.width, cfg.player.height/4)
			SolarBar:SetStatusBarTexture(cfg.statusbar_texture)
			SolarBar:SetStatusBarColor(0.6,0.3,0)
			EclipseBar.SolarBar = SolarBar
		elseif playerClass == "DEATHKNIGHT" then
			-- Runes
			local Runes = {}
			for index = 1, 6 do
				-- Position and size of the rune bar indicators
				local Rune = CreateFrame('StatusBar', nil, self)
				Rune:SetSize(cfg.player.width / 6, cfg.player.height/2)
				Rune:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', index * cfg.player.width / 6 -20, -2)
				if isBeautiful then
					Rune:CreateBeautyBorder(10)
					Rune:SetBeautyBorderPadding(1)
				end
				Rune:SetStatusBarTexture(cfg.statusbar_texture)
				Rune:SetOrientation("VERTICAL")
				CreateBackdrop(Rune)

				Runes[index] = Rune
			end
			-- Register with oUF
			self.Runes = Runes
		elseif playerClass == "SHAMAN" then
			-- Totems
			local Totems = {}
			for index = 1, MAX_TOTEMS do
				-- Position and size of the totem indicator
				local Totem = CreateFrame('Button', nil, self)
				Totem:SetSize(30, 30)
				Totem:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', index * Totem:GetWidth() - 30, -2)
				if isBeautiful then
					Totem:CreateBeautyBorder(12)
					Totem:SetBeautyBorderPadding(1)
				end
				local Icon = Totem:CreateTexture(nil, "OVERLAY")
				Icon:SetAllPoints()
				local Cooldown = CreateFrame("Cooldown", nil, Totem)
				Cooldown:SetAllPoints()
				
				Totem.Icon = Icon
				Totem.Cooldown = Cooldown
				Totems[index] = Totem
			end
			-- Register with oUF
			self.Totems = Totems
		elseif playerClass == "ROGUE" then
			self.CPoints = {}
			self.CPoints.unit = PlayerFrame.unit
			for i = 1, 5 do
				self.CPoints[i] = self.Health:CreateTexture(nil, "OVERLAY")
				self.CPoints[i]:SetHeight(cfg.player.height/4 - 2)
				self.CPoints[i]:SetWidth(cfg.player.width/6)
				self.CPoints[i]:SetTexture(cfg.statusbar_texture)	
				if i == 1 then
					self.CPoints[i]:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', 4, -2)
					self.CPoints[i]:SetVertexColor(0.69, 0.31, 0.31)
				else
					self.CPoints[i]:SetPoint("LEFT", self.CPoints[i-1], "RIGHT", 3, 0)
				end
			end
			self.CPoints[2]:SetVertexColor(0.69, 0.31, 0.31)
			self.CPoints[3]:SetVertexColor(0.65, 0.63, 0.35)
			self.CPoints[4]:SetVertexColor(0.65, 0.63, 0.35)
			self.CPoints[5]:SetVertexColor(0.33, 0.59, 0.33)
		elseif playerClass == "WARLOCK" then
			local lock = CreateFrame("Frame", "BobWarlockBar", self)
			lock:SetPoint("TOP", self.Power, "BOTTOM", 0,0)
			lock:SetWidth(cfg.player.width)
			lock:SetHeight(cfg.player.height/4)

			for i = 1, 4 do
				lock[i] = CreateFrame("StatusBar", "BobWarlockSpecBars"..i, lock)
				lock[i]:SetHeight(cfg.player.height/4)
				lock[i]:SetStatusBarTexture(cfg.statusbar_texture)
				if isBeautiful then
					lock[i]:CreateBeautyBorder(12)
					lock[i]:SetBeautyBorderPadding(1)
				end

				if i == 1 then
					lock[i]:SetWidth((125 / 4) - 2)
					lock[i]:SetPoint("LEFT", lock, "LEFT", 0, -2)
				else
					lock[i]:SetWidth((125 / 4) - 1)
					lock[i]:SetPoint("LEFT", lock[i-1], "RIGHT", 1, 0)
				end
			end
								
			self.WarlockSpecBars = lock
			
		elseif playerClass == "PRIEST" or playerClass == "PALADIN" then--All those other classes
			local numIcons = 5
			local iconSpacing = 5 -- need wider spacing
			local iconWidth = ((cfg.player.width/5) - (iconSpacing * (numIcons - 1)) / numIcons)
			local iconHeight = (cfg.player.height / 4)

			local ClassIcons = {}

			for index = 1, numIcons do
				local Icon = CreateFrame("Button", nil, self)
				Icon.SetVertexColor = nop
				Icon:SetNormalTexture(cfg.statusbar_texture)
				Icon:GetNormalTexture():SetAllPoints(true)
				Icon:SetSize(iconWidth, iconHeight)
				if index > 1 then
					Icon:SetPoint("LEFT", ClassIcons[index-1], "RIGHT", iconSpacing, 0)
				else
					Icon:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT")
				end
				if isBeautiful then -- !Beautycase load check
					Icon:CreateBeautyBorder(12)
					Icon:SetBeautyBorderPadding(1)
				end
				ClassIcons[index] = Icon
			end

			self.ClassIcons = ClassIcons
		else
			return
		end
		----------------------------
		-- Plugin: oUF_Experience --
		----------------------------
		if IsAddOnLoaded("oUF_Experience") then
			-- Position and size
			local Experience = CreateFrame('StatusBar', nil, self)
			Experience:SetPoint('BOTTOM', self.Power, 0, -cfg.player.height/4*2-2)
			Experience:SetHeight(cfg.player.height/4)
			Experience:SetWidth(cfg.player.width)
			Experience:SetStatusBarTexture(cfg.statusbar_texture)
			Experience:SetStatusBarColor(127/255,0/255,255/255)
			if isBeautiful then
				Experience:CreateBeautyBorder(12)
				Experience:SetBeautyBorderPadding(1)
			end
			
			-- Add a background
			local bg = Experience:CreateTexture(nil, 'BACKGROUND')
			bg:SetAllPoints(Experience)
			bg:SetTexture(cfg.statusbar_texture)
			bg:SetVertexColor(unpack(cfg.bColor))

			-- Text display
			local Value = Experience:CreateFontString(nil, 'OVERLAY')
			Value:SetAllPoints(Experience)
			Value:SetFontObject(GameFontHighlight)
			self:Tag(Value, '[perxp]%')

			-- Register it with oUF
			self.Experience = Experience
		end
		
		----------------------------
		-- Plugin: oUF_Reputation --
		----------------------------
		if IsAddOnLoaded("oUF_Reputation") then
			-- Position and size
			local Reputation = CreateFrame('StatusBar', nil, self)
			if IsAddOnLoaded("oUF_Experience") then
				Reputation:SetPoint('BOTTOM', self.Power, 0, -cfg.player.height/4*3-4)
			else
				Reputation:SetPoint('BOTTOM', self.Power, 0, -cfg.player.height/4*2-2)
			end
			Reputation:SetHeight(cfg.player.height/4)
			Reputation:SetWidth(cfg.player.width)
			Reputation:SetStatusBarTexture(cfg.statusbar_texture)
			if isBeautiful then
				Reputation:CreateBeautyBorder(12)
				Reputation:SetBeautyBorderPadding(1)
			end
			
			-- Color the bar by current standing
			Reputation.colorStanding = true

			-- Text display
			local Value = Reputation:CreateFontString(nil, 'OVERLAY')
			Value:SetAllPoints(Reputation)
			Value:SetFontObject(GameFontHighlight)
			self:Tag(Value, '[currep] / [maxrep]')
			
			-- Add a background
			local bg = Reputation:CreateTexture(nil, 'BACKGROUND')
			bg:SetAllPoints(Reputation)
			bg:SetTexture(cfg.statusbar_texture)
			bg:SetVertexColor(unpack(cfg.bColor))

			-- Register it with oUF
			self.Reputation = Reputation
		end
	end,
	pet = function(self)
		-- pet specific stuff
		self:SetSize(cfg.pet.width,cfg.pet.height)
		
		if not cfg.pet.portrait then
			self.Portrait:SetAlpha(0)
		end
		self.Portrait:SetPoint('TOPRIGHT', self.Health, 'TOPLEFT', -2,0)
		self.Portrait:SetSize(cfg.pet.height+4,cfg.pet.height+4)
		
		self.Health:SetHeight(cfg.pet.height/2)
		self.Power:SetHeight(cfg.pet.height/4)
		
		self.Castbar:SetPoint("TOP",self.Power,"BOTTOM",0,-2)
		self.Castbar:SetSize(cfg.pet.width, cfg.pet.height/4)
		self.Auras:Hide()
	end,
	target = function(self)
		-- target specific stuff
		self:SetSize(cfg.target.width,cfg.target.height)
		
		self.Health:SetHeight(cfg.target.height/2)
		self.Power:SetHeight(cfg.target.height/4)
		
		if not cfg.target.portrait then
			self.Portrait:SetAlpha(0)
		end
		self.Portrait:SetPoint('TOPLEFT', self.Health, 'TOPRIGHT', 2,0)
		self.Portrait:SetSize(cfg.target.height+4, cfg.target.height+4)
		
		self.Castbar:SetSize(cfg.target.cast_width, cfg.target.cast_height)
		self.Castbar:SetPoint(unpack(cfg.target.castbar_pos))
	end,
	targettarget = function(self)
		-- target specific stuff
		self:SetSize(cfg.tot.width,cfg.tot.height)
		self.Portrait:Hide()
		self.Health:SetHeight(cfg.tot.height/2)
		self.Power:SetHeight(cfg.tot.height/4)
		
		self.Castbar:Hide()
	end,
	focus = function(self)
		-- focus specific stuff
		self:SetSize(cfg.focus.width,cfg.focus.height)
		
		if not cfg.focus.portrait then
			self.Portrait:SetAlpha(0)
		end
		self.Health:SetHeight(cfg.focus.height/2)
		self.Power:SetHeight(cfg.focus.height/4)
		
		self.Portrait:SetPoint('TOPRIGHT', self.Health, 'TOPLEFT', -2,0)
		self.Portrait:SetSize(cfg.focus.height+4, cfg.focus.height+4)
		
		self.Castbar:SetSize(cfg.focus.width, cfg.focus.height/4)
		self.Castbar:SetPoint("TOP",self.Power,"BOTTOM",0,-2)
	end,
	boss = function(self)
		-- boss specific stuff
		self:SetSize(cfg.boss.width,cfg.boss.height)
		
		if not cfg.boss.portrait then
			self.Portrait:SetAlpha(0)
		end
		self.Health:SetHeight(cfg.boss.height/2)
		self.Power:SetHeight(cfg.boss.height/4)
		
		self.Portrait:SetPoint('TOPLEFT', self.Health, 'TOPRIGHT', 2,0)
		self.Portrait:SetSize(cfg.boss.height+4, cfg.boss.height+4)
		
		self.Castbar:SetSize(cfg.boss.width, cfg.boss.height/4)
		self.Castbar:SetPoint("TOP",self.Power,"BOTTOM",0,-2)
		self.Auras:Hide()
		----------------------------
		-- Plugin: oUF_Trinkets --
		----------------------------
		if IsAddOnLoaded("oUF_Trinkets") then
			if (unit and unit:find('arena%d') and (not unit:find("arena%dtarget")) and (not unit:find("arena%dpet"))) then
				self.Trinket = CreateFrame("Frame", nil, self)
				self.Trinket:SetHeight(cfg.boss.height/4)
				self.Trinket:SetWidth(cfg.boss.width)
				self.Trinket:SetPoint("TOP",self.Power,"BOTTOM", 0, -cfg.boss.height/4 * 2)
				self.Trinket.trinketUseAnnounce = true
				self.Trinket.trinketUpAnnounce = true
			end
		end
	end
}
UnitSpecific.arena = UnitSpecific.boss  -- arena is equal to boss

------------------------------------------------------------------------
-- Shared settings
------------------------------------------------------------------------
local function Shared(self, unit, isSingle)
	unit = gsub(unit, "%d", "")

	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self:RegisterForClicks'AnyUp'

 
	-- shared functions
	-----------------------------
	-- Health
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetStatusBarTexture(cfg.statusbar_texture)
	Health:SetPoint('TOP')
	Health:SetPoint('LEFT')
	Health:SetPoint('RIGHT')
	if isBeautiful then
		Health:CreateBeautyBorder(12)
		Health:SetBeautyBorderPadding(1)
	end
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
	self.Health.bg = Healthbg
	
	-----------------------------
	--Heal Prediction
   -- Position and size
   local myBar = CreateFrame('StatusBar', nil, self.Health)
   myBar:SetFrameStrata("BACKGROUND")
   myBar:SetPoint('TOP')
   myBar:SetPoint('BOTTOM')
   myBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
   myBar:SetWidth(self.Health:GetWidth())
   myBar:SetStatusBarTexture(cfg.statusbar_texture)
   myBar:SetStatusBarColor(0,1,0)
   
   local otherBar = CreateFrame('StatusBar', nil, self.Health)
   otherBar:SetFrameStrata("BACKGROUND")
   otherBar:SetPoint('TOP')
   otherBar:SetPoint('BOTTOM')
   otherBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
   otherBar:SetWidth(self.Health:GetWidth())
   otherBar:SetStatusBarTexture(cfg.statusbar_texture)
   otherBar:SetStatusBarColor(0,1,0)

   local absorbBar = CreateFrame('StatusBar', nil, self.Health)
   absorbBar:SetFrameStrata("BACKGROUND")
   absorbBar:SetPoint('TOP')
   absorbBar:SetPoint('BOTTOM')
   absorbBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
   absorbBar:SetWidth(self.Health:GetWidth())
   absorbBar:SetStatusBarTexture(cfg.statusbar_texture)
   absorbBar:SetStatusBarColor(1,1,1)

   local healAbsorbBar = CreateFrame('StatusBar', nil, self.Health)
   healAbsorbBar:SetFrameStrata("BACKGROUND")
   healAbsorbBar:SetPoint('TOP')
   healAbsorbBar:SetPoint('BOTTOM')
   healAbsorbBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
   healAbsorbBar:SetWidth(self.Health:GetWidth())
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
	-- Power
	local Power = CreateFrame("StatusBar", nil, Health)
	Power:SetStatusBarTexture(cfg.statusbar_texture)
	Power:SetPoint('TOP',Health,'BOTTOM',0,-2)
	Power:SetPoint('LEFT')
	Power:SetPoint('RIGHT')
	if isBeautiful then
		Power:CreateBeautyBorder(12)
		Power:SetBeautyBorderPadding(1)
	end
	CreateBackdrop(Power)
	-- Options
	Power.frequentUpdates = true
	Power.colorPower = true -- powertype colored bar
	Power.colorClassNPC = false -- color power based on NPC 
	Power.colorClassPet = false -- color power based on pet type
	-- Register it with oUF
	self.Power = Power
	self.Power.bg = Powerbg
	
	-----------------------------
	--Text
	--Health Percent
	local NameText = Health:CreateFontString(nil, "OVERLAY", "TextStatusBarText") -- parent to last child to make sure it's on top
	NameText:SetPoint("TOP", Health, 0,-4) -- but anchor to the base element so it doesn't wiggle
	NameText:SetFont(cfg.font, cfg.font_size, cfg.style)
	self:Tag(NameText, "[name]") -- oUF will automagically update it!
	Health.text = NameText
	--Health Percent
	local HealthText = Health:CreateFontString(nil, "OVERLAY", "TextStatusBarText") -- parent to last child to make sure it's on top
	HealthText:SetPoint("RIGHT", Health, -5,-5) -- but anchor to the base element so it doesn't wiggle
	HealthText:SetFont(cfg.font, cfg.font_size, cfg.style)
	self:Tag(HealthText, "[perhp]") -- oUF will automagically update it!
	Health.text = HealthText
	--Health Value
	local HealthText2 = Health:CreateFontString(nil, "OVERLAY", "TextStatusBarText") -- parent to last child to make sure it's on top
	HealthText2:SetPoint("LEFT", Health, 5,-5) -- but anchor to the base element so it doesn't wiggle
	HealthText2:SetFont(cfg.font, cfg.font_size, cfg.style)
	self:Tag(HealthText2, "[curhp]") -- oUF will automagically update it!
	Health.text = HealthText2
	--Power Percent
	local PowerText = Power:CreateFontString(nil, "OVERLAY", "TextStatusBarText") -- parent to last child to make sure it's on top
	PowerText:SetPoint("RIGHT", Power, -5,0) -- but anchor to the base element so it doesn't wiggle
	PowerText:SetFont(cfg.font, cfg.font_size, cfg.style)
	self:Tag(PowerText, "[perpp]") -- oUF will automagically update it!
	Power.text = PowerText
	--Power Value
	local PowerText2 = Power:CreateFontString(nil, "OVERLAY", "TextStatusBarText") -- parent to last child to make sure it's on top
	PowerText2:SetPoint("LEFT", Power, 5,0) -- but anchor to the base element so it doesn't wiggle
	PowerText2:SetFont(cfg.font, cfg.font_size, cfg.style)
	self:Tag(PowerText2, "[curpp]") -- oUF will automagically update it!
	Power.text = PowerText2
	
	-----------------------------
	-- 3D Portrait
	-- Position and size
	local Portrait = CreateFrame('PlayerModel', nil, self)
	CreateBackdrop(Portrait)
	-- Register it with oUF
	self.Portrait = Portrait
	
	-----------------------------
	-- Castbar
	-- Position and size
	local Castbar = CreateFrame("StatusBar", nil, self)
	Castbar:SetStatusBarTexture(cfg.statusbar_texture)
	Castbar:SetStatusBarColor(unpack(cfg.castbar_color))
	if isBeautiful then
		Castbar:CreateBeautyBorder(12)
		Castbar:SetBeautyBorderPadding(1)
	end
	
	-- Add a background
	local Background = Castbar:CreateTexture(nil, 'BACKGROUND')
	Background:SetTexture(cfg.statusbar_texture)
	Background:SetAllPoints(Castbar)
	Background:SetTexture(0, 0, 0, .5)
   
	-- Add a spark
	local Spark = Castbar:CreateTexture(nil, "OVERLAY")
	Spark:SetSize(20, 10)
	Spark:SetBlendMode("ADD")
   
	-- Add a timer
	local Time = Castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	Time:SetFont(cfg.font, cfg.font_size, cfg.style)
	Time:SetTextColor(0.95, 0.95, 0.95)
	Time:SetPoint("RIGHT", Castbar, -3, 1)
   
	-- Add spell text
	local Text = Castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	Text:SetFont(cfg.font, cfg.font_size, cfg.style)
	Text:SetTextColor(0.95, 0.95, 0.95)
	Text:SetPoint("LEFT", Castbar, 3, 1)
   
	-- Add Shield
	local Shield = Castbar:CreateTexture(nil, "OVERLAY")
	Shield:SetSize(20, 10)
	Shield:SetPoint("CENTER", Castbar)
  
	-- Add safezone
	local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")
   
	-- Register it with oUF
	self.Castbar = Castbar
	self.Castbar.bg = Background
	self.Castbar.Spark = Spark
	self.Castbar.Time = Time
	self.Castbar.Text = Text
	self.Castbar.SafeZone = SafeZone
	
	-----------------------------
	-- Auras
	local Auras = CreateFrame("Frame", nil, self)
	Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0,1)
	Auras:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 1)
	Auras:SetHeight(cfg.Auras.size)
	Auras:SetHeight(cfg.Auras.size + cfg.Auras.spacing)

	Auras.size = cfg.Auras.size
	Auras.onlyShowPlayer = cfg.Auras.onlyShowPlayer
	Auras.gap = cfg.Auras.gap
	Auras.spacing = cfg.Auras.spacing
	Auras.showStealableAuras = cfg.Auras.showStealableAuras
	Auras.disableCooldown = cfg.Auras.disableCooldown
	Auras.num = cfg.Auras.number

	Auras.PostCreateIcon = Aura_PostCreateIcon
	self.Auras = Auras

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
	
	-----------------------------
	-- Quest Icon
	-- Position and size
	local QuestIcon = self.Health:CreateTexture(nil, 'OVERLAY')
	QuestIcon:SetSize(16, 16)
	QuestIcon:SetPoint('TOPLEFT', self.Health)
   
	-- Register it with oUF
	self.QuestIcon = QuestIcon
	
	-----------------------------
	-- Leader Icon
	-- Position and size
	local Leader = self.Health:CreateTexture(nil, "OVERLAY")
	Leader:SetSize(16, 16)
	Leader:SetPoint("LEFT", self.Health, "RIGHT")
   
	-- Register it with oUF
	self.Leader = Leadera
	
	-----------------------------
	-- Master looter
	-- Position and size
	local MasterLooter = self.Health:CreateTexture(nil, 'OVERLAY')
	MasterLooter:SetSize(16, 16)
	MasterLooter:SetPoint('TOP', self.Health)
   
	-- Register it with oUF
	self.MasterLooter = MasterLooter
	
	-----------------------------
	-- Combat
	-- Position and size
	local Combat = self.Health:CreateTexture(nil, "OVERLAY")
	Combat:SetSize(16, 16)
	Combat:SetPoint('TOPLEFT', self.Health)
   
	-- Register it with oUF
	self.Combat = Combat
   
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
	-- leave this in!!
	if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
	
end
 
oUF:RegisterStyle('Bob', Shared)
oUF:Factory(function(self)
	self:SetActiveStyle('Bob')
	self:Spawn('player'):SetPoint(unpack(cfg.player.position))
	self:Spawn('pet'):SetPoint(unpack(cfg.pet.position))
	self:Spawn('target'):SetPoint(unpack(cfg.target.position))
	self:Spawn('targettarget'):SetPoint(unpack(cfg.tot.position))
	self:Spawn('focus'):SetPoint(unpack(cfg.focus.position))
	for index = 1, MAX_BOSS_FRAMES do
		local boss = self:Spawn('boss' .. index)
		if(index == 1) then
			boss:SetPoint(unpack(cfg.boss.position))
		else
			boss:SetPoint('TOP', _G['oUF_Boss' .. index - 1], 'BOTTOM', 0, -20)
		end
	end
	for index = 1, 5 do
		local arena = self:Spawn('arena' .. index)
		if(index == 1) then
			arena:SetPoint(unpack(cfg.boss.position))
		else
			arena:SetPoint('TOP', _G['oUF_BobArena' .. index - 1], 'BOTTOM', 0, -20)
		end
	end
end)