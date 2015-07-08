function blazingStarStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local speed = ability:GetLevelSpecialValueFor("speed", ability_level) * 0.03
	local traveled_distance = 0
	local caught_target = false
	local direction = nil

	ability:ApplyDataDrivenModifier(caster, caster, keys.dashing_modifier, {})
	caster:CastAbilityImmediately(caster:FindAbilityByName("master_spark"), 1)
	--caster:CastAbilityOnPosition(caster:GetAbsOrigin() + caster:GetForwardVector(), caster:FindAbilityByName("blazing_star_master_spark"), 1)

	-- Moving the caster
	Timers:CreateTimer(0, function()
		local target = keys.target

		local distance = ability:GetLevelSpecialValueFor("travel_distance", ability_level)

		if traveled_distance < distance then

			if not direction then direction = caster:GetForwardVector() end
			local target_distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()

			if not caught_target and target:IsAlive() then
				direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()

				if target_distance < ability:GetLevelSpecialValueFor("catch_radius", ability_level) then
					caught_target = true
					ability:ApplyDataDrivenModifier(caster, target, keys.caught_modifier, {})
				end
			else
				local drag_distance = ability:GetLevelSpecialValueFor("drag_distance", ability_level)
				local target_direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
				if (target_distance > drag_distance) then
					target:SetAbsOrigin(caster:GetAbsOrigin() + (target_distance - drag_distance) * target_direction)
				end
			end

			caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * speed)
			traveled_distance = traveled_distance + speed

			return 0.03
		else
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)
			FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
			caster:RemoveModifierByName(keys.dashing_modifier)
			target:RemoveModifierByName(keys.caught_modifier)
		end
	end)
end