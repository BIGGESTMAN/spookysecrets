previous_location_table = {}
distance_remaining_table = {}

function fireGust( keys )
	local caster = keys.caster
	local ability = keys.ability
	local particle = keys.particle

	local unitsNearTarget = FindUnitsInRadius(caster:GetTeamNumber(),
                            caster:GetAbsOrigin(),
                            nil,
                            ability:GetLevelSpecialValueFor("range", (ability:GetLevel() - 1)),
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
                            DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                            FIND_CLOSEST,
                            false)

	local target = unitsNearTarget[1]

	if target ~= nil then
		local projectile_info = {
	        Target = target,
	        Source = caster,
	        EffectName = particle,
	        Ability = ability,
	        bDodgeable = false,
	        bProvidesVision = true,
	        iMoveSpeed = ability:GetLevelSpecialValueFor("projectile_speed", (ability:GetLevel() - 1)),
	        iVisionRadius = 0,
	        iVisionTeamNumber = caster:GetTeamNumber(),
	        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	    }

	    ProjectileManager:CreateTrackingProjectile( projectile_info )
	    distance_remaining_table[caster] = ability:GetLevelSpecialValueFor("distance_to_ready", (ability:GetLevel() - 1))
		caster:RemoveModifierByName(keys.ready_modifier)
	end
end

function macroburstUpdateCooldown( keys )
	local caster = keys.caster
	local ability = keys.ability

	currentLocation = caster:GetAbsOrigin()
	if previous_location_table[caster] == nil then
		previous_location_table[caster] = currentLocation
	end
	distance_traveled = (previous_location_table[caster] - currentLocation):Length2D()
	previous_location_table[caster] = currentLocation

	if caster:IsAlive() then
		if distance_remaining_table[caster] == nil then
			distance_remaining_table[caster] = ability:GetLevelSpecialValueFor("distance_to_ready", (ability:GetLevel() - 1))
		end
		distance_remaining_table[caster] = distance_remaining_table[caster] - distance_traveled

		if distance_remaining_table[caster] <= 0 then
			ability:ApplyDataDrivenModifier(caster, caster, keys.ready_modifier, {})
			-- fireGust(keys)
			ability:EndCooldown()
		else
			ability:EndCooldown()
			ability:StartCooldown(distance_remaining_table[caster])
		end
	else
		distance_remaining_table[caster] = nil
		previous_location_table[caster] = nil
	end
end

function onUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability
	if distance_remaining_table[caster] and distance_remaining_table[caster] > ability:GetLevelSpecialValueFor("distance_to_ready", (ability:GetLevel() - 1)) then
		distance_remaining_table[caster] = ability:GetLevelSpecialValueFor("distance_to_ready", (ability:GetLevel() - 1))
	end
end