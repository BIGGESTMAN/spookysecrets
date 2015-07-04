previous_location_table = {}
bonus_damage_table = {}

function windGodsFanUpdateDamage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	currentLocation = caster:GetAbsOrigin()
	if previous_location_table[caster] == nil then
		previous_location_table[caster] = currentLocation
	end
	distance_traveled = (previous_location_table[caster] - currentLocation):Length2D()
	previous_location_table[caster] = currentLocation

	caster:FindModifierByName(keys.damage_modifier):SetStackCount(0)

	local minimum_damage = ability:GetLevelSpecialValueFor("minimum_damage", ability_level)
	local maximum_damage = ability:GetLevelSpecialValueFor("maximum_damage", ability_level)
	local max_damage_distance = ability:GetLevelSpecialValueFor("max_damage_distance", ability_level)

	if caster:IsAlive() then
		if bonus_damage_table[caster] == nil then
			bonus_damage_table[caster] = minimum_damage
		end
		bonus_damage_table[caster] = bonus_damage_table[caster] + (distance_traveled / max_damage_distance) * maximum_damage

		if bonus_damage_table[caster] >= maximum_damage then
			bonus_damage_table[caster] = maximum_damage
			if not caster:HasModifier(keys.full_modifier) then
				ability:ApplyDataDrivenModifier(caster, caster, keys.full_modifier, {})
			end
		end
		--ability:ApplyDataDrivenModifier(caster, caster, keys.damage_modifier, {})
		local modifier = caster:FindModifierByName(keys.damage_modifier)
		while modifier:GetStackCount() < bonus_damage_table[caster] do
			modifier:IncrementStackCount()
		end
		--caster:FindModifierByName(keys.remaining_distance_modifier).SetStackCount(distance_remaining_table[caster])
	else
		previous_location_table[caster] = nil
		bonus_damage_table[caster] = nil
		--caster:RemoveModifierByName(keys.damage_modifier)
	end
	print("bonus_damage_table[caster]: ", bonus_damage_table[caster])
end

function windGodsFanResetDamage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	print("?")

	bonus_damage_table[caster] = ability:GetLevelSpecialValueFor("minimum_damage", ability_level)
	caster:FindModifierByName(keys.damage_modifier):SetStackCount(bonus_damage_table[caster])
	previous_location_table[caster] = nil
	caster:RemoveModifierByName(keys.full_modifier)
end