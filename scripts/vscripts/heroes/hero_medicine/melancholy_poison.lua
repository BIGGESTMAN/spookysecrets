function melancholyPoisonTick(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local update_interval = ability:GetLevelSpecialValueFor("update_interval", ability_level)

	-- Increment venom count
	if not caster.venom then caster.venom = 0 end
	caster.venom = caster.venom + ability:GetLevelSpecialValueFor("venom_gained_per_second", ability_level) * update_interval

	-- If magic damage taken recently, release venom
	if caster.venom_triggered then
		caster.venom = caster.venom - ability:GetLevelSpecialValueFor("venom_released_per_second", ability_level) * update_interval

		local team = caster:GetTeamNumber()
		local point = caster:GetAbsOrigin()
		local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
		local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		local iFlag = DOTA_UNIT_TARGET_FLAG_NONE
		local iOrder = FIND_ANY_ORDER

		local targets = FindUnitsInRadius(team, point, nil, radius, iTeam, iType, iFlag, iOrder, false)
		local damage = ability:GetLevelSpecialValueFor("damage_per_second", ability_level) * update_interval

		for k,unit in pairs(targets) do
			ApplyDamage({ victim = unit, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
			ability:ApplyDataDrivenModifier(caster, unit, keys.stun_modifier, {})
		end

		ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN, caster)

		if caster.venom < 0 then
			caster.venom = 0
			caster.venom_triggered = false
		end
	end
end

function checkVenomRelease(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local damage_taken = keys.damage_taken
end