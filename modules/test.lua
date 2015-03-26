local _, cfg = ... --import config
local addon, ns = ... --get addon namespace

--Frame testing
local groups = { -- Change these to the global names your layout will make.
	arena = { "oUF_BobArena1", "oUF_BobArena2", "oUF_BobArena3", "oUF_BobArena4", "oUF_BobArena5"},
	boss = { "oUF_Boss1", "oUF_Boss2", "oUF_Boss3", "oUF_Boss4", "oUF_Boss5" },
}

local function toggle(f)
	if f.__realunit then
		f:SetAttribute("unit", f.__realunit)
		f.unit = f.__realunit
		f.__realunit = nil
		f:Hide()
	else
		f.__realunit = f:GetAttribute("unit") or f.unit
		f:SetAttribute("unit", "player")
		f.unit = "player"
		f:Show()
	end
end

SLASH_OUFTEST1 = "/otest"
SlashCmdList.OUFTEST = function(group)
	local frames = groups[strlower(strtrim(group))]
	if not frames then return end
	for i = 1, #frames do
		local frame = _G[frames[i]]
		if frame then
			toggle(frame)
		end
	end
end