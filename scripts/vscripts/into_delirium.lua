into_delirium = class({})
LinkLuaModifier("modifier_neurotoxin", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_neurotoxin_sleep", LUA_MODIFIER_MOTION_NONE )

function into_delirium:OnSpellStart()
	local caster = self:GetCaster()
	local ability_level = self:GetLevel() - 1

	EmitSoundOn("Hero_Bane.Nightmare", caster)

	local duration = self:GetLevelSpecialValueFor("duration", ability_level)
	self:GetCursorTarget():AddNewModifier(caster, self, "modifier_neurotoxin", {duration = duration})
end