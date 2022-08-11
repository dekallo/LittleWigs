
--------------------------------------------------------------------------------
-- Module declaration
--

local mod, CL = BigWigs:NewBoss("General Umbriss", 670, 131)
if not mod then return end
mod:RegisterEnableMob(39625)
mod.engageId = 1051
mod.respawnTime = 30

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{74670, "ICON"}, -- Blitz
		74634, -- Ground Siege
		74853, -- Frenzy
		74846, -- Wound
	}
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Blitz")

	self:Log("SPELL_CAST_START", "Siege", 74634)
	self:Log("SPELL_AURA_APPLIED", "Frenzy", 74853)
	self:Log("SPELL_AURA_APPLIED", "Wound", 74846)
	self:Log("SPELL_AURA_REMOVED", "WoundRemoved", 74846)
end

function mod:VerifyEnable()
	if not UnitInVehicle("player") then return true end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Blitz(_, msg, _, _, _, player)
	if msg:find(self:SpellName(74670)) then
		if player then
			self:TargetMessageOld(74670, player, "red", "alert")
			self:PrimaryIcon(74670, player)
			self:ScheduleTimer("PrimaryIcon", 3.5, 74670)
		else
			self:Message(74670, "red")
			self:PlaySound(74670, "alert")
		end
	end
end

function mod:Siege(args)
	self:Message(args.spellId, "orange")
end

function mod:UNIT_HEALTH(event, unit)
	local hp = UnitHealth(unit) / UnitHealthMax(unit) * 100
	if hp < 36 then
		self:UnregisterUnitEvent(event, unit)
		self:Message(74853, "yellow", CL.soon:format(self:SpellName(74853)))
	end
end

function mod:Frenzy(args)
	self:Message(args.spellId, "yellow")
	self:PlaySound(args.spellId, "long")
end

function mod:Wound(args)
	self:TargetMessageOld(args.spellId, args.destName, "yellow")
	self:TargetBar(args.spellId, 10, args.destName)
end

function mod:WoundRemoved(args)
	self:StopBar(args.spellName, args.destName)
end

