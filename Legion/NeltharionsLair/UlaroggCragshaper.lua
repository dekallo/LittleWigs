--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ularogg Cragshaper", 1458, 1665)
if not mod then return end
mod:RegisterEnableMob(91004)
mod:SetEncounterID(1791)
mod:SetRespawnTime(15)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local abilityCount = 0
local resumeTimers = false
local totemsAlive = 0
local stanceOfTheMountainCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.totems = "Totems"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		198564, -- Stance of the Mountain
		193375, -- Bellow of the Deeps
		198428, -- Strike of the Mountain
		{198496, "TANK_HEALER"}, -- Sunder
	}, nil, {
		[193375] = L.totems,
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	self:Death("IntermissionTotemsDeath", 100818)
	self:Log("SPELL_CAST_START", "BellowOfTheDeeps", 193375)
	self:Log("SPELL_CAST_START", "StrikeOfTheMountain", 198428)
	self:Log("SPELL_CAST_START", "Sunder", 198496)
end

function mod:OnEngage()
	abilityCount = 0
	resumeTimers = false
	totemsAlive = 0
	stanceOfTheMountainCount = 1
	-- TODO confirm normal
	self:SetStage(1)
	self:CDBar(198496, 7.1) -- Sunder
	self:CDBar(198428, 15.5) -- Strike of the Mountain
	self:CDBar(193375, 20.4, L.totems) -- Bellow of the Deeps
	if self:Mythic() then
		-- 50s energy gain + .2s to ~10s delay
		self:CDBar(198564, 50.2, CL.count:format(self:SpellName(198564), stanceOfTheMountainCount)) -- Stance of the Mountain
	else
		-- 70s energy gain + delay
		self:CDBar(198564, 70.3, CL.count:format(self:SpellName(198564), stanceOfTheMountainCount)) -- Stance of the Mountain
	end
end

--------------------------------------------------------------------------------
-- Rotation calculations
--

-- this boss has a fixed ability order:
-- first [Sunder Strike Bellow Sunder Strike Sunder] x 2
-- then  [Sunder Bellow Strike Sunder Sunder Strike] x infinity
-- stance happens on a regular timer and the rotation is "paused" during Stage 2
-- boss can rarely skip an ability in its rotation, only right after Stage 2 ends.
-- TODO one time it did the initial rotation ~3 times... except it was weird
local initialRotation = {
	[1] = 198496, -- Sunder
	[2] = 198428, -- Strike
	[3] = 193375, -- Bellow
	[4] = 198496, -- Sunder
	[5] = 198428, -- Strike
	[6] = 198496, -- Sunder
}
local mainRotation = {
	[1] = 198496, -- Sunder
	[2] = 193375, -- Bellow
	[3] = 198428, -- Strike
	[4] = 198496, -- Sunder
	[5] = 198496, -- Sunder
	[6] = 198428, -- Strike
}
local timerByAbility = {
	[193375] = 6.06, -- Bellow
	[198428] = 4.82, -- Strike
	[198496] = 4.82, -- Sunder
}

-- gets the spellId of the next spell to be cast, or if an argument is passed, the spell
-- which will be cast n spells from now
-- @param id Either the GUID or the mob/npc id of the boss unit to find
function mod:GetNextCast(increment)
	local index = abilityCount + (increment or 0)
	local rotation = index <= 12 and initialRotation or mainRotation
	return rotation[(index - 1) % 6 + 1]
end

-- detects skipped casts and fixes state if an ability was skipped casts
-- are only skipped directly out of Stage 2, but check every time or we could
-- get false negatives in the case of the first Sunder in a Sunder -> Sunder
-- ability order being skipped.
function mod:CheckForSkippedCast(spellId)
	local predictedSpellId = self:GetNextCast()
	if spellId ~= predictedSpellId then
		-- set resumeTimers to true so everything gets recalculated
		resumeTimers = true
		print("ability skipped! expected "..predictedSpellId.." but was "..spellId)
		-- max lookahead needed to find the cast ability is theoretically 5, but
		-- in practice it's always been just 1 ability skipped
		for i = 1, 5 do
			-- increment counter until we find the cast ability
			abilityCount = abilityCount + 1
			print("incrementing "..i)
			if spellId == self:GetNextCast() then
				-- we found the cast spell
				return
			end
		end
	end
end

-- gets the time until the next cast of an ability given current ability count
function mod:GetTimeUntilNextCast(spellId)
	local timeUntilNext = 0
	-- calculate time until next cast
	for i = 0, 5 do -- max lookahead needed is 6
		local index = abilityCount + i
		if index == 1 then -- the very first Sunder has an extra long delay
			timeUntilNext = 7.3
		else
			local currentSpellId = self:GetNextCast(i)
			if spellId == currentSpellId and index ~= abilityCount then
				-- we found what we're looking for
				break
			else
				-- add time until the next cast
				local nextSpellId = self:GetNextCast(i + 1)
				if currentSpellId == 198496 and nextSpellId == 198496 then -- Sunder
					-- there's a special case where Sunder to Sunder incurs an extra long delay
					timeUntilNext = timeUntilNext + 8.5
				else
					timeUntilNext = timeUntilNext + timerByAbility[currentSpellId]
				end
			end
		end
	end
	return timeUntilNext
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
	if msg:find("198510", nil, true) then -- Stance of the Mountain
		self:SetStage(2)
		totemsAlive = self:Normal() and 3 or 5
		self:StopBar(198496) -- Sunder
		self:StopBar(198428) -- Strike of the Mountain
		self:StopBar(L.totems) -- Bellow of the Deeps
		self:StopBar(CL.count:format(self:SpellName(198564), stanceOfTheMountainCount)) -- Stance of the Mountain
		self:Message(198564, "cyan", CL.count:format(self:SpellName(198564), stanceOfTheMountainCount))
		self:PlaySound(198564, "long")
	end
end

function mod:IntermissionTotemsDeath()
	totemsAlive = totemsAlive - 1
	if totemsAlive == 0 then -- all of them fire UNIT_DIED
		self:SetStage(1)
		self:Message(198564, "green", CL.over:format(self:SpellName(198564))) -- Stance of the Mountain
		self:PlaySound(198564, "info")
		stanceOfTheMountainCount = stanceOfTheMountainCount + 1
		if self:Mythic() then
			-- 50s energy gain + delay
			self:CDBar(198564, 50.6, CL.count:format(self:SpellName(198564), stanceOfTheMountainCount)) -- Stance of the Mountain
		else
			-- 70s energy gain + delay
			self:CDBar(198564, 70.7, CL.count:format(self:SpellName(198564), stanceOfTheMountainCount)) -- Stance of the Mountain
		end
		-- set flag to calculate other timers on next ability cast
		resumeTimers = true
		-- start a really short bar for the next predicted cast to provide a tiny bit of warning
		local nextSpellId = self:GetNextCast(1)
		if nextSpellId == 193375 then
			self:CDBar(nextSpellId, 0.1, L.totems)
		else
			self:CDBar(nextSpellId, 0.1)
		end
	end
end

function mod:BellowOfTheDeeps(args)
	self:Message(args.spellId, "orange", CL.incoming:format(L.totems))
	self:PlaySound(args.spellId, "alert")
	abilityCount = abilityCount + 1
	self:CheckForSkippedCast(args.spellId)
	self:CDBar(args.spellId, self:GetTimeUntilNextCast(args.spellId), L.totems)
	if resumeTimers then
		resumeTimers = false
		self:CDBar(198428, self:GetTimeUntilNextCast(198428)) -- Strike of the Mountain
		self:CDBar(198496, self:GetTimeUntilNextCast(198496)) -- Sunder
	end
end

function mod:StrikeOfTheMountain(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm")
	abilityCount = abilityCount + 1
	self:CheckForSkippedCast(args.spellId)
	self:CDBar(args.spellId, self:GetTimeUntilNextCast(args.spellId))
	if resumeTimers then
		resumeTimers = false
		self:CDBar(193375, self:GetTimeUntilNextCast(193375), L.totems) -- Bellow of the Deeps
		self:CDBar(198496, self:GetTimeUntilNextCast(198496)) -- Sunder
	end
end

function mod:Sunder(args)
	self:Message(args.spellId, "purple")
	self:PlaySound(args.spellId, "alert")
	abilityCount = abilityCount + 1
	self:CheckForSkippedCast(args.spellId)
	self:CDBar(args.spellId, self:GetTimeUntilNextCast(args.spellId))
	if resumeTimers then
		resumeTimers = false
		self:CDBar(193375, self:GetTimeUntilNextCast(193375), L.totems) -- Bellow of the Deeps
		self:CDBar(198428, self:GetTimeUntilNextCast(198428)) -- Strike of the Mountain
	end
end
