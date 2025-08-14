--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Lil Leacher", 2664)
if not mod then return end
mod:RegisterEnableMob(243303) -- Lil Leacher
mod:SetEncounterID(3217)
mod:SetRespawnTime(15)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.lil_leacher = "Lil Leacher"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnRegister()
	self.displayName = L.lil_leacher
end

function mod:GetOptions()
	return {
	}
end

function mod:OnBossEnable()
	-- this boss has no abilities, but we can still detect engage/wipe/win
end
