
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Kyrak", 1358, 1227)
if not mod then return end
mod:RegisterEnableMob(76021)
mod.engageId = 1758
mod.respawnTime = 25

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		161199, -- Debilitating Fixation
		161203, -- Rejuvenating Serum
		161288, -- Vileblood Serum
		{155037, "TANK"}, -- Eruption
	}, {
		[161199] = -10260,
		[155037] = CL.adds,
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "DebilitatingFixation", 161199)
	self:Log("SPELL_CAST_START", "RejuvenatingSerumIncoming", 161203)
	self:Log("SPELL_CAST_SUCCESS", "RejuvenatingSerum", 161203)
	self:Log("SPELL_AURA_APPLIED", "VilebloodSerum", 161288)
	self:Log("SPELL_CAST_START", "Eruption", 155037)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:DebilitatingFixation(args)
	self:Message(args.spellId, "yellow", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "alert")
	self:CDBar(args.spellId, 20) -- 20-23
end

function mod:RejuvenatingSerumIncoming(args)
	self:Message(args.spellId, "orange", CL.incoming:format(args.spellName))
	self:PlaySound(args.spellId, "long")
end

function mod:RejuvenatingSerum(args)
	self:TargetMessageOld(args.spellId, args.destName, "orange", "warning", nil, nil, self:Dispeller("magic", true))
end

function mod:VilebloodSerum(args)
	if self:Me(args.destGUID) then
		self:Message(args.spellId, "blue", CL.underyou:format(args.spellName))
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:Eruption(args)
	local raidIcon = CombatLog_String_GetIcon(args.sourceRaidFlags)
	self:Message(args.spellId, "red", raidIcon.. args.spellName)
	self:PlaySound(args.spellId, "info")
end
