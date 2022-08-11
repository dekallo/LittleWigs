
--------------------------------------------------------------------------------
-- Module declaration
--

local mod, CL = BigWigs:NewBoss("Hoptallus", 961, 669)
if not mod then return end
mod:RegisterEnableMob(56717)
mod.engageId = 1413
mod.respawnTime = 30

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{112992, "SAY"}, -- Furlwind
		112944, -- Carrot Breath
		114291, -- Explosive Brew
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "Furlwind", 112992)
	self:Log("SPELL_AURA_APPLIED", "FurlwindChanneling", 112992)
	self:Log("SPELL_DAMAGE", "FurlwindDamage", 112993)
	self:Log("SPELL_MISSED", "FurlwindDamage", 112993)

	self:Log("SPELL_CAST_START", "CarrotBreath", 112944)
	self:Log("SPELL_CAST_START", "ExplosiveBrew", 114291)
end

function mod:OnEngage()
	self:CDBar(112992, 10.8) -- Furlwind
	self:CDBar(112944, 29.1) -- Carrot Breath
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local function printTarget(self, player, guid)
		self:TargetMessageOld(112992, player, "yellow", "long", nil, nil, true)
		if self:Me(guid) then
			self:Say(112992)
		end
	end

	function mod:FurlwindChanneling(args)
		self:GetBossTarget(printTarget, 0.3, args.sourceGUID)
	end

	function mod:Furlwind(args)
		self:Message(args.spellId, "yellow", CL.incoming:format(args.spellName))
		self:CastBar(args.spellId, 12.5) -- 2.5s cast + 10s channeling
		self:CDBar(args.spellId, 43.8)
	end
end

do
	local prev = 0
	function mod:FurlwindDamage(args)
		if self:Me(args.destGUID) then
			local t = GetTime()
			if (not self:Melee() and t-prev > 1.5) or t-prev > 6 then
				prev = t
				self:Message(112992, "blue", CL.near:format(args.spellName))
				self:PlaySound(112992, "alert")
			end
		end
	end
end

function mod:CarrotBreath(args)
	self:Message(args.spellId, "red", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "alarm")
	self:CDBar(args.spellId, 43.8)
end

do
	local prev = 0
	function mod:ExplosiveBrew(args) -- adds cast this, there can be many adds
		local t = GetTime()
		if t-prev > 1.5 then
			prev = t
			self:Message(args.spellId, "orange", CL.casting:format(args.spellName))
			self:PlaySound(args.spellId, "alert")
		end
	end
end
