﻿------------------------------
--      Are you local?      --
------------------------------

local boss = BB["Gatewatcher Gyro-Kill"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Gyro-Kill",

	shadow = "Shadow Power Cast",
	shadow_desc = "Warn when Iron-Hand casts Shadow Power",
	shadow_message = "Shadow Power in 2 seconds!",

	shadowaura = "Shadow Power Gained",
	shadowaura_desc = "Warn when Gyro-Kill gains Shadow Power",
	shadowaura_message ="Gyro-Kill gains Shadow Power",
} end )

L:RegisterTranslations("koKR", function() return {
	hammer = "착암기",
	hammer_desc = "착암기 효과 시전시 알립니다.",
	hammer_trigger = "자신의 망치를 위협적으로 치켜듭니다...", -- check
	hammer_message = "3초 이내 착암기!",
	hammer_bar = "착암기",

	shadow = "어둠의 힘",
	shadow_desc = "어둠의 힘을 획득시 알립니다.",
	shadow_message = "2초 이내 어둠의 힘!",
	shadow_bar = "어둠의 힘",
} end )

L:RegisterTranslations("zhTW", function() return {
	hammer = "千斤錘特效",
	hammer_desc = "看守者發動千斤錘特效時發出警報",
	hammer_trigger = "威嚇地舉起他的錘子……",
	hammer_message = "3 秒後發動千斤錘! 近戰退後!",
	hammer_bar = "千斤錘特效",

	shadow = "暗影強化",
	shadow_desc = "看守者施放暗影強化時發出警報",
	shadow_message = "2 秒後施放暗影強化!",
	shadow_bar = "暗影強化",
} end )

L:RegisterTranslations("frFR", function() return {
	hammer = "Marteau-piqueur",
	hammer_desc = "Préviens quand le Marteau-piqueur est incanté.",
	hammer_trigger = "lève son marteau d'un air menaçant...",
	hammer_message = "Marteau-piqueur dans 3 sec. !",
	hammer_bar = "Marteau-piqueur",

	shadow = "Puissance de l'ombre",
	shadow_desc = "Préviens quand Main-en-fer gagne la Puissance de l'ombre.",
	shadow_message = "Puissance de l'ombre dans 2 sec. !",
	shadow_bar = "Puissance de l'ombre",
} end )

L:RegisterTranslations("esES", function() return {
	hammer = "Martillo",
	hammer_desc = "Avisa cuando Manoyerro alza su martillo",
	hammer_trigger = "alza su martillo amenazadoramente",
	hammer_message = "Martillo en 3 segundos!",
	hammer_bar = "Martillo",

	shadow = "Shadow Power",
	shadow_desc = "Avisa cuando Manoyerro lanza Poder de las Sombras",
	shadow_message = "Poder de las Sombras en 2 segundos!",
	shadow_bar = "Poder de las Sombras",
} end )

L:RegisterTranslations("zhCN", function() return {
	shadow = "施放暗影能量",
	shadow_desc = "当埃隆汉施放暗影能量时发出警报。",
	shadow_message = "2秒后，暗影能量！",

	shadowaura = "获得暗影能量",
	shadowaura_desc = "当盖罗基尔获得暗影能量时发出警报。",
	shadowaura_message ="盖罗基尔 - 暗影能量！",
} end )

L:RegisterTranslations("deDE", function() return {
	hammer = "Hammer",
	hammer_desc = "Vor Hammer Warnen",
	hammer_trigger = "erhebt seinen Hammer bedrohlich",
	hammer_message = "Hammer in 3 Sekunden!",
	hammer_bar = "Hammer",

	shadow = "Schattenmacht",
	shadow_desc = "Warnen, wenn Eisenhand Schattenmacht bekommt",
	shadow_message = "Schattenmacht in 2 Sekunden!",
	shadow_bar = "Schattenmacht",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

local mod = BigWigs:NewModule(boss)
mod.partyContent = true
mod.otherMenu = "Tempest Keep"
mod.zonename = BZ["The Mechanar"]
mod.enabletrigger = boss 
mod.toggleoptions = {"shadow", "shadowaura", "bosskill"}
mod.revision = tonumber(("$Revision$"):sub(12, -3))

------------------------------
--      Initialization      --
------------------------------

function mod:OnEnable()
	self:AddCombatListener("SPELL_CAST_START", "Shadow", 39193)
	self:AddCombatListener("SPELL_AURA_APPLIED", "ShadowApplied", 39193)
	self:AddCombatListener("SPELL_AURA_REMOVED", "ShadowRemoved", 39193)
	self:AddCombatListener("UNIT_DIED", "GenericBossDeath")
end

------------------------------
--      Event Handlers      --
------------------------------

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if self.db.profile.hammer and msg:find(L["hammer_trigger"]) then
		self:Message(L["hammer_message"], "Important")
		self:Bar(L["hammer"], 3, "INV_Hammer_07")
	end
end

function mod:Shadow()
	if self.db.profile.shadow then
		self:Message(L["shadow_message"], "Important")
	end
end

function mod:ShadowApplied(_, spellId, _, _, spellName)
	if self.db.profile.shadowaura then
		self:IfMessage(L["shadowaura_message"], "Important", spellId)
		self:Bar(spellName, 15, spellId)
	end
end

function mod:ShadowRemoved(_, spellId, _, _, spellName)
	if self.db.profile.shadowaura then
		self:TriggerEvent("BigWigs_StopBar", self, spellName)
	end
end
