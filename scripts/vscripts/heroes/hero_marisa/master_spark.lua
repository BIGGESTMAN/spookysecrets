function masterSpark(keys)
	local caster = keys.caster
	local caster_team = caster:GetTeamNumber()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local range = ability:GetLevelSpecialValueFor("range", ability_level)
	local start_radius = ability:GetLevelSpecialValueFor("start_radius", ability_level)
	local end_radius = ability:GetLevelSpecialValueFor("end_radius", ability_level)
	local full_radius_range = ability:GetLevelSpecialValueFor("full_radius_factor", ability_level) * range
	local caster_location = caster:GetAbsOrigin()
	local range = ability:GetLevelSpecialValueFor("range", ability_level)
	local target_point = caster_location + caster:GetForwardVector() * range
	local direction = (target_point - caster_location):Normalized()

	local dummy_modifier = keys.dummy_modifier

	-- Calculate the number of secondary dummies that we need to create
	local num_of_dummies = (((range) - start_radius) / (start_radius*2))
	print(num_of_dummies)
	num_of_dummies = math.ceil(num_of_dummies)
	print(num_of_dummies)

	-- Create the main wall dummy
	local dummy = CreateUnitByName("npc_dummy_blank", caster_location, false, caster, caster, caster_team)
	ability.dummy = dummy
	ability:ApplyDataDrivenModifier(dummy, dummy, dummy_modifier, {{radius = start_radius}})	

	-- Create the secondary dummies for the left half of the wall
	for i=1,num_of_dummies + 2 do
		-- Create a dummy on every interval point to fill the whole wall
		local distance = (start_radius * 2 * i - start_radius)
		local temporary_point = distance * direction
		local radius = start_radius + (end_radius - start_radius) * (distance / full_radius_range)
		if radius > end_radius then radius = end_radius end

		-- Create the secondary dummy and apply the dummy aura to it, make sure the caster of the aura is the main dummmy
		-- otherwise you wont be able to save illusion targets
		local dummy_secondary = CreateUnitByName("npc_dummy_blank", temporary_point, false, caster, caster, caster_team)
		--table.insert(ability.secondary_dummies, dummy_secondary)
		ability:ApplyDataDrivenModifier(dummy, dummy_secondary, dummy_modifier, {radius = radius})

		-- Timers:CreateTimer(duration, function()
		-- 	dummy_secondary:RemoveSelf()
		-- end)
	end

	-- Timers:CreateTimer(duration,function()
	-- 	dummy:RemoveSelf()
	-- end)

end