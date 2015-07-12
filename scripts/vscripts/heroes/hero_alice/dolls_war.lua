require "libraries/animations"

function dollsWarActivation(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()

	for doll,v in pairs(caster.dolls) do
		local spin_ability = doll:FindAbilityByName(keys.spin_ability)
		doll:CastAbilityImmediately(spin_ability, 1)
		spin(keys, doll)
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