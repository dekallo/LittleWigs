-------------------------------------------------------------------------------
--  Module Declaration

local mod, CL = BigWigs:NewBoss("Shirrak the Dead Watcher", 558, 523)
if not mod then return end
mod:RegisterEnableMob(18371)
-- mod.engageId = 1890 -- no boss frames
-- mod.respawnTime = 0 -- resets, doesn't respawn

-------------------------------------------------------------------------------
--  Localization

local L = mod:GetLocale()
if L then
	L.focus_fire = -5041
	L.focus_fire_desc = -5041
	L.focus_fire_icon = -5041
end

-------------------------------------------------------------------------------
--  Initialization

function mod:GetOptions()
	return {
		"focus_fire", -- Focus Fire
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")

	self:Death("Win", 18371)
end

-------------------------------------------------------------------------------
--  Event Handlers

function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, _, source, _, _, target) -- Focus Fire
	if source == self.displayName then -- this is the only BOSS_EMOTE that appears during this encounter
		self:TargetMessageOld("focus_fire", target, "yellow", nil, L.focus_fire, L.focus_fire_icon)
	end
end
