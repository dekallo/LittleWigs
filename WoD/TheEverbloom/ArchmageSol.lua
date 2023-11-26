--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Archmage Sol", 1279, 1208)
if not mod then return end
mod:RegisterEnableMob(82682) -- Archmage Sol
mod:SetEncounterID(1751)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Locals
--

local affinityCount = 0
local affinityOrder = {
	166475, -- Fire Affinity
	166476, -- Frost Affinity
	166477, -- Arcane Affinity
}
local nextAffinity = nil

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
	self:Log("SPELL_AURA_APPLIED", "AffinityApplied", 166475, 166476, 166477)
	self:Log("SPELL_AURA_APPLIED", "CinderboltStorm", 427899)
	self:Log("SPELL_AURA_APPLIED", "GlacialFusion", 428082)
	self:Log("SPELL_CAST_START", "SpatialCompression", 428139)
end

function mod:OnEngage()
	affinityCount = 0
	nextAffinity = nil
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

function mod:AffinityApplied(args)
	local expectedAffinity = affinityOrder[affinityCount % 3 + 1]
	affinityCount = affinityCount + 1
	local matchesExpected = expectedAffinity == args.spellId
	if not matchesExpected then
		print("expected "..self:SpellName(expectedAffinity).." but was "..args.spellName)
		-- TODO this is wrong, next one is just +1 from where we are (or: this whole thing is pointless)
		nextAffinity = affinityOrder[affinityCount % 3 + 1]
	end
	-- TODO this isn't the correct way to do it
	-- when it bugs out it always seems to be fire insted of arcane or frost, but then the next one is always frost
	-- so we can basically just leave it as is
end

local function startTimersForNextAffinity(self, affinity)
	print("resetting timers, expecting "..self:SpellName(affinity).." next")
	if affinity == 166475 then -- Fire Affinity
		self:CDBar(427899, {20.5, 39.0}) -- Cinderbolt Storm
		self:CDBar(428139, {20.5, 39.0}) -- Spatial Compression
		self:CDBar(428082, 39.0) -- Glacial Fusion
	elseif affinity == 166476 then -- Frost Affinity
		self:CDBar(428082, {20.5, 39.0}) -- Glacial Fusion
		self:CDBar(427899, {20.5, 39.0}) -- Cinderbolt Storm
		self:CDBar(428139, 39.0) -- Spatial Compression
	else -- Arcane Affinity
		self:CDBar(428139, {20.5, 39.0}) -- Spatial Compression
		self:CDBar(428082, {20.5, 39.0}) -- Glacial Fusion
		self:CDBar(427899, 39.0) -- Cinderbolt Storm
	end
	nextAffinity = nil
end

function mod:CinderboltStorm(args)
	self:Message(args.spellId, "red", CL.other:format(args.spellName, args.sourceName))
	self:PlaySound(args.spellId, "long")
	if self:Mythic() then
		if self:MobId(args.sourceGUID) == 82682 then -- Archmage Sol
			if not nextAffinity then
				-- TODO use the last cdtime to make the bars look better
				-- TODO i think doing it this way makes timers slightly worse? because we use aura_applied for glacial
				self:CDBar(args.spellId, {20.5, 39.0})
				self:CDBar(428082, {20.5, 39.0}) -- Glacial Fusion
				self:CDBar(428139, 39.0) -- Spatial Compression
			else -- bugged ability order
				startTimersForNextAffinity(self, nextAffinity)
			end
		else -- 213689, Spore Image
			--self:CDBar(args.spellId, 39.0)
		end
	else
		self:CDBar(args.spellId, 59.5)
	end
end

function mod:GlacialFusion(args)
	self:Message(args.spellId, "orange", CL.other:format(args.spellName, args.sourceName))
	self:PlaySound(args.spellId, "alarm")
	if self:Mythic() then
		if self:MobId(args.sourceGUID) == 82682 then -- Archmage Sol
			if not nextAffinity then
				self:CDBar(args.spellId, {20.5, 39.0})
				self:CDBar(428139, {20.5, 39.0}) -- Spatial Compression
				self:CDBar(427899, 39.0) -- Cinderbolt Storm
			else -- bugged ability order
				startTimersForNextAffinity(self, nextAffinity)
			end
		else -- 213689, Spore Image
			--self:CDBar(args.spellId, 39.0)
		end
	else
		self:CDBar(args.spellId, 59.5)
	end
end

function mod:SpatialCompression(args)
	self:Message(args.spellId, "yellow", CL.other:format(args.spellName, args.sourceName))
	self:PlaySound(args.spellId, "info")
	if self:Mythic() then
		if self:MobId(args.sourceGUID) == 82682 then -- Archmage Sol
			if not nextAffinity then
				self:CDBar(args.spellId, {20.5, 39.0})
				self:CDBar(427899, {20.5, 39.0}) -- Cinderbolt Storm
				self:CDBar(428082, 39.0) -- Glacial Fusion
			else -- bugged ability order
				startTimersForNextAffinity(self, nextAffinity)
			end
		else -- 213689, Spore Image
			--self:CDBar(args.spellId, 39.0)
		end
	else
		self:CDBar(args.spellId, 59.5)
	end
end
