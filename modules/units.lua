local _, cfg = ... --import config
local _, ns = ... --get addon namespace
local _, playerClass = UnitClass("player")
local isBeautiful = IsAddOnLoaded("!Beautycase") --!Beautycase check
-----------------------------
-- Add custom functions
-----------------------------
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
		button:CreateBeautyBorder(10) --skin it
	else
		return
	end
end

local function PostUpdateClassPower(element, cur, max, diff, powerType)
	if(diff) then
		for index = 1, max do
			local Bar = element[index]
			if(max == 3) then
				Bar:SetWidth(cfg.player.width/3)
			elseif(max == 4) then
				Bar:SetWidth(index > 2 and cfg.player.width/4 or cfg.player.width/4)
			elseif(max == 5 or max == 10) then
				Bar:SetWidth((index == 1 or index == 6) and cfg.player.width/5 or cfg.player.width/5)
			elseif(max == 6) then
				Bar:SetWidth(cfg.player.width/6)
			end
			if(max == 10) then
				-- Rogue anticipation talent, align >5 on top of the first 5
				if(index == 6) then
					Bar:ClearAllPoints()
					Bar:SetPoint('LEFT', element[index - 5])
				end
			else
				if(index > 1) then
					Bar:ClearAllPoints()
					Bar:SetPoint('LEFT', element[index - 1], 'RIGHT', 0, 0)
				end
			end
		end
	end
end

local function UpdateClassPowerColor(element)
	local r, g, b = 1, 1, 2/5
	if(playerClass == 'WARLOCK') then
		r, g, b = 2/3, 1/3, 2/3
	elseif(playerClass == 'PALADIN') then
		r, g, b = 1, 1, 2/5
	elseif(playerClass == 'MAGE') then
		r, g, b = 5/6, 1/2, 5/6
	end

	for index = 1, #element do
		local Bar = element[index]
		if(playerClass == 'ROGUE' and UnitPowerMax('player', SPELL_POWER_COMBO_POINTS) == 10 and index > 5) then
			r, g, b = 1, 0, 0
		end

		Bar:SetStatusBarColor(r, g, b)
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
		
		-----------------------------
		-- Auras
		-----------------------------
		if cfg.player.auras then
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
		end
		
		----------------------------
		-- Additional Power
		----------------------------
		local AdditionalPower = CreateFrame('StatusBar', nil, self)
		AdditionalPower:SetStatusBarTexture(cfg.statusbar_texture)
		AdditionalPower:SetPoint('BOTTOM', self.Power, 0, -cfg.player.height/4-2)
		-- Add a background
		local Background = AdditionalPower:CreateTexture(nil, 'BACKGROUND')
		Background:SetAllPoints(AdditionalPower)
		Background:SetTexture(1, 1, 1, .5)
		-- Register it with oUF
		AdditionalPower.bg = Background
		self.AdditionalPower = AdditionalPower
		
		----------------------------
		--Class Power
		----------------------------
		--need to investigate this since I want to use combo points, this code was kind janky though
		--[[
		local ClassPower = {}
		ClassPower.UpdateColor = UpdateClassPowerColor
		ClassPower.PostUpdate = PostUpdateClassPower

		for index = 1, 11 do -- have to create an extra to force __max to be different from UnitPowerMax
			local Bar = CreateFrame('StatusBar', nil, self)
			Bar:SetHeight(cfg.player.height/4)
			Bar:SetStatusBarTexture(cfg.statusbar_texture)
			CreateBackdrop(Bar)

			if(index > 1) then
				Bar:SetPoint('BOTTOMLEFT', ClassPower[index - 1], 0, -cfg.player.height/4-2)
			else
				Bar:SetPoint('BOTTOMLEFT', self.Power, 0, -cfg.player.height/4-2)
			end

			if(index > 5) then
				Bar:SetFrameLevel(Bar:GetFrameLevel() + 1)
			end

			local Background = Bar:CreateTexture(nil, 'BORDER')
			Background:SetAllPoints()

			ClassPower[index] = Bar
		end
		self.ClassPower = ClassPower
		]]

		----------------------------
		-- Plugin: oUF_Experience --
		----------------------------
		if IsAddOnLoaded("oUF_Experience") then
			-- Position and size
			local Experience = CreateFrame('StatusBar', nil, self)
			Experience:SetPoint('TOP', self.Health, 0, cfg.player.height/4+2)
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
			Value:SetFont(cfg.font, cfg.font_size, cfg.style)
			self:Tag(Value, '[experience:cur] / [experience:max]')

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
				Reputation:SetPoint('TOP', self.Health, 0, cfg.player.height/4*2+4)
			else
				Reputation:SetPoint('TOP', self.Health, 0, cfg.player.height/4+2)
			end
			Reputation:SetHeight(cfg.player.height/4)
			Reputation:SetWidth(cfg.player.width)
			Reputation:SetStatusBarTexture(cfg.statusbar_texture)
			if isBeautiful then
				Reputation:CreateBeautyBorder(12)
				Reputation:SetBeautyBorderPadding(1)
			end
			Reputation:EnableMouse(true) -- Enable mouse support for tooltips/fading/clicks

			-- Add a texture widget to display reward status
			local Reward = Reputation:CreateTexture(nil, 'ARTWORK')
			Reward:SetPoint('RIGHT')
			Reward:SetSize(15, 18)
			Reputation.Reward = Reward

			-- Color the bar by current standing
			Reputation.colorStanding = true

			-- Text display
			local Value = Reputation:CreateFontString(nil, 'OVERLAY')
			Value:SetAllPoints(Reputation)
			Value:SetFontObject(GameFontHighlight)
			Value:SetFont(cfg.font, cfg.font_size, cfg.style)
			self:Tag(Value, '[reputation:cur] / [reputation:max]')

			-- Add a background
			CreateBackdrop(Reputation)

			-- Register it with oUF
			self.Reputation = Reputation
		end
			------------------------
			-- Plugin: oUF_Swing --
			------------------------
			self.Swing = CreateFrame("Frame", nil, self)
			self.Swing:SetWidth(100)
			self.Swing:SetHeight(5)
			self.Swing:SetPoint("BOTTOM", self, "TOP", 0, 2)
			self.Swing.texture = cfg.statusbar_texture
			self.Swing.color = {1, 0, 0, 0.8}
			if isBeautiful then
				self.Swing:CreateBeautyBorder(8)
				self.Swing:SetBeautyBorderPadding(1)
			end
			
	end, --end player
	
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
		--self.Auras:Hide()
		
		--Pet Happiness
		-- Position and size
		local PetHappiness = CreateFrame('Frame', nil, self)
		PetHappiness:SetSize(14, 14)
		if cfg.pet.portrait then
			PetHappiness:SetPoint('TOPLEFT',self.Portrait,1,-1)
		else
			PetHappiness:SetPoint('TOPLEFT',self.Health,1,-1)
		end

		-- Register it with oUF
		self.PetHappiness = PetHappiness
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
		
		-----------------------------
		-- Auras
		-----------------------------
		if cfg.target.auras then
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
		end
	end,
	targettarget = function(self)
		-- target specific stuff
		self:SetSize(cfg.tot.width,cfg.tot.height)
		self.Portrait:Hide()
		self.Health:SetHeight(cfg.tot.height/2)
		self.Power:SetHeight(cfg.tot.height/4)
		
		self.Castbar:Hide()
	end,
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

	-----------------------------
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
   
   -- Register with oUF
   self.HealthPrediction = {
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

	-- Add a background
	CreateBackdrop(Castbar)
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
	
   	------------------------
	-- Plugin: oUF_Smooth --
	------------------------
	if IsAddOnLoaded("oUF_Smooth") and not strmatch(unit, ".target$") then
		self.Health.Smooth = true
		if self.Power then
			self.Power.Smooth = true
		end
	end

	-- End of plugins, lets apply style to all frames not listed before this part
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
end)