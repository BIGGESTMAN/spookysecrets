into_delirium = class({})
LinkLuaModifier("modifier_neurotoxin", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_neurotoxin_sleep", LUA_MODIFIER_MOTION_NONE )

function into_delirium:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local ability_level = self:GetLevel() - 1

	EmitSoundOn("Hero_Bane.Nightmare", caster)

	local duration = self:GetLevelSpecialValueFor("duration", ability_level)
	local slow_per_second = self:GetLevelSpecialValueFor("slow_per_second", ability_level)
	local update_interval = self:GetLevelSpecialValueFor("update_interval", ability_level)
	local spread_range = self:GetLevelSpecialValueFor("spread_range", ability_level)
	self:GetCursorTarget():AddNewModifier(caster, self, "modifier_neurotoxin", {duration = duration})
end

-- function fantasy_nature:GetCooldown( nLevel )
-- 	if self:GetCaster():HasScepter() then
-- 		return self:GetSpecialValueFor("scepter_cooldown")
-- 	end

-- 	return self.BaseClass.GetCooldown( self, nLevel )
-- end

-- function fantasy_nature:GetManaCost( nLevel )
-- 	if self:GetCaster():HasScepter() then
-- 		return self:GetSpecialValueFor("scepter_manacost")
-- 	end

-- 	return self.BaseClass.GetManaCost(self, nLevel )
-- end