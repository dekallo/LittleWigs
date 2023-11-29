--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Archmage Sol", 1279, 1208)
if not mod then return end
mod:RegisterEnableMob(82682) -- Archmage Sol
mod:SetEncounterID(1751)
mod:SetRespawnTime(30)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local lastCinderboltStormCd = 0
local lastGlacialFusionCd = 0
local lastSpatialCompressionCd = 0
local debugLastCinder = 0
local debugLastGlacial = 0
local debugLastSpatial = 0
local debugLastBarCinder = 0
local debugLastBarGlacial = 0
local debugLastBarSpatial = 0

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		427899, -- Cinderbolt Storm
		428082, -- Glacial Fusion
		428139, -- Spatial Compression
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "CinderboltStorm", 427899)
	self:Log("SPELL_AURA_APPLIED", "GlacialFusion", 428082)
	self:Log("SPELL_CAST_START", "SpatialCompression", 428139)
end

function mod:OnEngage()
	local t = GetTime() -- TODO delete
	debugLastCinder = t
	debugLastGlacial = t
	debugLastSpatial = t
	debugLastBarCinder = 3.3
	debugLastBarGlacial = 24.2
	debugLastBarSpatial = 48.3
	self:SetStage(1)
	if self:Mythic() then
		lastCinderboltStormCd = 3.3
		lastGlacialFusionCd = 24.2
		lastSpatialCompressionCd = 43.3
	end
	self:CDBar(427899, 3.3) -- Cinderbolt Storm
	self:CDBar(428082, 24.2) -- Glacial Fusion
	self:CDBar(428139, 43.3) -- Spatial Compression
end

function mod:OnWin()
    local trashMod = BigWigs:GetBossModule("The Everbloom Trash", true)
    if trashMod then
        trashMod:Enable()
        trashMod:ArchmageSolDefeated()
    end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:TimerDebug(t, spellId, newTimer, newMax)
	local debugInterval, debugBarInterval
	if spellId == 427899 then
		debugInterval = round(t - debugLastCinder, 1)
		debugBarInterval = round(debugLastBarCinder - (t - debugLastCinder), 1)
		debugLastBar = debugLastBarCinder
	elseif spellId == 428082 then
		debugInterval = round(t - debugLastGlacial, 1)
		debugBarInterval = round(debugLastBarGlacial - (t - debugLastGlacial), 1)
		debugLastBar = debugLastBarGlacial
	elseif spellId == 428139 then
		debugInterval = round(t - debugLastSpatial, 1)
		debugBarInterval = round(debugLastBarSpatial - (t - debugLastSpatial), 1)
		debugLastBar = debugLastBarSpatial
	end
	local timeLeft = self:BarTimeLeft(spellId)
	local spellName = self:SpellName(spellId)
	if newMax then
		print(spellName.." set to {"..newTimer..","..newMax.."} (was "..round(timeLeft,1)..")")
	else
		print(spellName.." set to "..newTimer.." (was "..round(timeLeft,1)..")")
	end
	print("actual interval "..debugInterval..", bar had "..debugBarInterval.." of "..debugLastBar)
	if spellId == 427899 then
		debugLastCinder = t
		debugLastBarCinder = newTimer
	elseif spellId == 428082 then
		debugLastGlacial = t
		debugLastBarGlacial = newTimer
	elseif spellId == 428139 then
		debugLastSpatial = t
		debugLastBarSpatial = newTimer
	end
end

function mod:CinderboltStorm(args)
	local t = GetTime() -- TODO delete
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "long")
	if self:Mythic() then
		if self:MobId(args.sourceGUID) == 82682 then -- Archmage Sol
			self:SetStage(1)
			self:TimerDebug(t, args.spellId, 19.9)
			self:CDBar(args.spellId, 19.9)
			lastCinderboltStormCd = 19.9
			-- correct Glacial Fusion bar
			if lastGlacialFusionCd > 20.4 then
				self:TimerDebug(t, 428082, 20.4, lastGlacialFusionCd)
				self:CDBar(428082, {20.4, lastGlacialFusionCd}) -- Glacial Fusion
			else
				self:TimerDebug(t, 428082, 20.4)
				self:CDBar(428082, 20.4) -- Glacial Fusion
				lastGlacialFusionCd = 20.4
			end
		else -- 213689, Spore Image
			self:TimerDebug(t, args.spellId, 38.8)
			self:CDBar(args.spellId, 38.8)
			lastCinderboltStormCd = 38.8
		end
	else -- Heroic, Normal
		self:SetStage(1)
		self:CDBar(args.spellId, 59.5)
	end
end

function mod:GlacialFusion(args)
	local t = GetTime() -- TODO delete
	self:Message(args.spellId, "orange")
	self:PlaySound(args.spellId, "alarm")
	if self:Mythic() then
		if self:MobId(args.sourceGUID) == 82682 then -- Archmage Sol
			self:SetStage(2)
			self:TimerDebug(t, args.spellId, 19.4)
			self:CDBar(args.spellId, 19.4)
			lastGlacialFusionCd = 19.4
			-- correct Spatial Compression bar
			if lastSpatialCompressionCd > 18.4 then
				self:TimerDebug(t, 428139, 18.4, lastSpatialCompressionCd)
				self:CDBar(428139, {18.4, lastSpatialCompressionCd}) -- Spatial Compression
			else
				self:TimerDebug(t, 428139, 18.4)
				self:CDBar(428139, 18.4) -- Spatial Compression
				lastSpatialCompressionCd = 18.4
			end
		else -- 213689, Spore Image
			self:TimerDebug(t, args.spellId, 40.4)
			self:CDBar(args.spellId, 40.4)
			lastGlacialFusionCd = 40.4
		end
	else -- Heroic, Normal
		self:SetStage(2)
		self:CDBar(args.spellId, 59.5)
	end
end

function mod:SpatialCompression(args)
	local t = GetTime() -- TODO delete
	self:Message(args.spellId, "yellow")
	self:PlaySound(args.spellId, "info")
	if self:Mythic() then
		if self:MobId(args.sourceGUID) == 82682 then -- Archmage Sol
			self:SetStage(3)
			self:TimerDebug(t, args.spellId, 20.5)
			self:CDBar(args.spellId, 20.5)
			lastSpatialCompressionCd = 20.5
			-- correct Cinderbolt Storm bar
			if lastCinderboltStormCd > 19.1 then
				self:TimerDebug(t, 427899, 19.1, lastCinderboltStormCd)
				self:CDBar(427899, {19.1, lastCinderboltStormCd}) -- Cinderbolt Storm
			else
				self:TimerDebug(t, 427899, 19.1)
				self:CDBar(427899, 19.1) -- Cinderbolt Storm
				lastCinderboltStormCd = 19.1
			end
		else -- 213689, Spore Image
			self:TimerDebug(t, args.spellId, 38.8)
			self:CDBar(args.spellId, 38.8)
			lastSpatialCompressionCd = 38.8
		end
	else -- Heroic, Normal
		self:SetStage(3)
		self:CDBar(args.spellId, 59.5)
	end
end
