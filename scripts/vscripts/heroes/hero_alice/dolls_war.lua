require "libraries/animations"
require "libraries/util"

function dollsWarActivation(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()

	for doll,v in pairs(caster.dolls) do
		local doll_type = doll:GetUnitName()
		if doll_type == "shanghai_doll" then
			fireLaser(keys, doll)
		else
			spin(keys, doll)
		end
		--local laser_ability = doll:FindAbilityByName(keys.laser_ability)
		--print(laser_ability, laser_ability:GetLevel())
		--doll:CastAbilityImmediately(laser_ability, 1)
		--doll:CastAbilityOnPosition(doll:GetForwardVector() * ability:GetLevelSpecialValueFor("laser_range", ability_level) / 2, laser_ability, 1)
	end
end

function spin(keys, doll)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()

	local team = doll:GetTeamNumber()
	local point = doll:GetAbsOrigin()
	local radius = ability:GetLevelSpecialValueFor("spin_radius", ability_level)
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = FIND_ANY_ORDER

	local targets = FindUnitsInRadius(team, point, nil, radius, iTeam, iType, iFlag, iOrder, false)
	local damage = ability:GetLevelSpecialValueFor("spin_damage", ability_level)

	for k,unit in pairs(targets) do
		ApplyDamage({ victim = unit, attacker = doll, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
		ability:ApplyDataDrivenModifier(doll, unit, keys.slow_modifier, {})
	end

	ParticleManager:CreateParticle(keys.spin_particle, PATTACH_ABSORIGIN, doll)
	StartAnimation(doll, {duration=23 * 0.03 / 2, activity=ACT_DOTA_RATTLETRAP_POWERCOGS, rate=2, translate = "telebolt"})
	StartSoundEvent(keys.spin_sound, doll)

end

function fireLaser(keys, doll)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()
	local thinker_modifier = keys.thinker_modifier
	local range = ability:GetLevelSpecialValueFor("laser_range", ability_level)
	local radius = ability:GetLevelSpecialValueFor("laser_radius", ability_level)

	local targets = unitsInLine(caster, ability, thinker_modifier, doll:GetAbsOrigin(), range, radius, doll:GetForwardVector(), false)
	local damage = ability:GetLevelSpecialValueFor("laser_damage", ability_level)

	for k,unit in pairs(targets) do
		ApplyDamage({ victim = unit, attacker = doll, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	end

	StartAnimation(doll, {duration=23 * 0.03 / 2, activity=ACT_DOTA_RATTLETRAP_POWERCOGS, rate=2, translate = "telebolt"})
	StartSoundEvent(keys.laser_sound, doll)

	local particle = ParticleManager:CreateParticle(keys.laser_particle, PATTACH_ABSORIGIN_FOLLOW, doll)
	ParticleManager:SetParticleControlEnt( particle, 0, doll, PATTACH_POINT_FOLLOW, "attach_hitloc", doll:GetAbsOrigin(), true )

	local particleRange = range + radius
	local endcapPos = doll:GetAbsOrigin() + doll:GetForwardVector() * range
	ParticleManager:SetParticleControl( particle, 1, endcapPos )

	Timers:CreateTimer(0.03, function()
		ParticleManager:DestroyParticle(particle, false)
	end)
end