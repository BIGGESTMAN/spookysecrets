function yasakasDivineWindCast(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local team = caster:GetTeamNumber()
	local origin = caster:GetAbsOrigin()
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local iOrder = FIND_ANY_ORDER
	local radius = ability:GetLevelSpecialValueFor("knockback_range", ability_level)

	local targets = FindUnitsInRadius(team, origin, nil, radius, iTeam, iType, iFlag, iOrder, false)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local damage_type = ability:GetAbilityDamageType()

	for k,unit in pairs(targets) do
		ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = damage_type})
		ability:ApplyDataDrivenModifier(caster, unit, keys.modifier, {})
	end

	local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
end

function knockback(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local speed = ability:GetLevelSpecialValueFor("knockback_speed", ability_level)
	local range = ability:GetLevelSpecialValueFor("knockback_range", ability_level)
	local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	direction.z = 0
	local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()

	if distance < range then
		target:SetAbsOrigin(target:GetAbsOrigin() + direction * speed * 0.03)
		return 0.03
	else
		target:RemoveModifierByName("modifier_knocked_back")
		FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
	end
end