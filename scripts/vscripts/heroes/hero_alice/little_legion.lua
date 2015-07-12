function spawnDoll(keys)
	local movement_interval = 0.03
	local ability = keys.ability
	local ability_level = ability:GetLevel()

	local caster = keys.caster
	local doll = CreateUnitByName("hourai_doll", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
	-- Set doll stats based on skill rank
	if ability_level > 1 then
		doll:CreatureLevelUp(ability_level - 1)
	end

	if not caster.dolls then
		caster.dolls = {}
	end
	caster.dolls[doll] = true

	ability:ApplyDataDrivenModifier(caster, doll, keys.modifier, {})
	local speed = ability:GetLevelSpecialValueFor("dash_speed", ability_level) * 0.03

	-- Dash towards target
	Timers:CreateTimer(0, function()
		local target = keys.target
		doll.target = target
		doll:SetForceAttackTarget(target)
		local direction = (target:GetAbsOrigin() - doll:GetAbsOrigin()):Normalized()
		local target_distance = (target:GetAbsOrigin() - doll:GetAbsOrigin()):Length2D()

		if target_distance < doll:GetAttackRange() then
			-- Check if doll is in range
			local damage = ability:GetLevelSpecialValueFor("hourai_damage", ability_level)
			ApplyDamage({ victim = target, attacker = doll, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
			FindClearSpaceForUnit(doll, doll:GetAbsOrigin(), false)
		else
			doll:SetAbsOrigin(doll:GetAbsOrigin() + direction * speed)
			doll:SetForwardVector(direction)
			return 0.03
		end
	end)
end

function killDoll(keys)
	print("Bears")
	local doll = keys.target
	doll:ForceKill(true)
	keys.caster.dolls[doll] = nil
	local dolls_war = keys.caster:FindAbilityByName(keys.dolls_war)
	local dolls_war_level = dolls_war:GetLevel()
	if dolls_war_level > 0 then
		local team = doll:GetTeamNumber()
		local point = doll:GetAbsOrigin()
		local radius = dolls_war:GetLevelSpecialValueFor("explosion_radius", dolls_war_level)
		local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		local iFlag = DOTA_UNIT_TARGET_FLAG_NONE
		local iOrder = FIND_ANY_ORDER

		local targets = FindUnitsInRadius(team, point, nil, radius, iTeam, iType, iFlag, iOrder, false)
		local damage = dolls_war:GetLevelSpecialValueFor("explosion_health_percent", dolls_war_level) * doll:GetMaxHealth() / 100

		for k,unit in pairs(targets) do
			ApplyDamage({ victim = unit, attacker = doll, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
		end

		ParticleManager:CreateParticle(keys.explosion_particle, PATTACH_ABSORIGIN, doll)
	end
end

function deathCheck(keys)
	local doll = keys.target
	local target = doll.target
	if (not target:IsAlive()) or (target:IsInvisible() and not doll:CanEntityBeSeenByMyTeam(target)) or target:GetTeamNumber() == doll:GetTeamNumber() then
		doll:RemoveModifierByName(keys.modifier)
	end
end