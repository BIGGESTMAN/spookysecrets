targets_hit_table = {}

function duplexBarrier( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local caster_team = caster:GetTeamNumber()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	targets_hit_table[caster] = {}
	ability.caster = caster
	ability.last_caster_location = caster_location
	ability.original_caster_facing = caster:GetForwardVector()
	--ability.last_caster_facing = caster:GetForwardVector()
	ability.outer_dummies = {}
	ability.outer_secondary_dummies = {}
	ability.inner_dummies = {}
	ability.inner_secondary_dummies = {}
	ability.outer_particles = {}
	ability.inner_particles = {}

	-- Make outer barrier
	for wall_number=0, 3 do
		local radius = ability:GetLevelSpecialValueFor("outer_barrier_radius", ability_level)
		local range = math.sqrt(radius * radius / 2)
		local prototype_target_point = caster_location + caster:GetForwardVector() * range
		local target_point = RotatePosition(caster_location, QAngle(0, 90 * wall_number, 0), prototype_target_point)

		-- Cosmetic variables
		local outer_dummy_modifier = keys.outer_dummy_modifier
		local wall_particle = keys.wall_particle
		local dummy_sound = keys.dummy_sound

		-- Ability variables
		local length = range * 2
		local width = ability:GetLevelSpecialValueFor("width", ability_level)
		local duration = ability:GetLevelSpecialValueFor("barrier_duration", ability_level)

		-- Targeting variables
		local direction = (target_point - caster_location):Normalized()
		local rotation_point = target_point + direction * length/2
		local end_point_left = RotatePosition(target_point, QAngle(0,90,0), rotation_point)
		local end_point_right = RotatePosition(target_point, QAngle(0,-90,0), rotation_point)

		local direction_left = (end_point_left - target_point):Normalized() 
		local direction_right = (end_point_right - target_point):Normalized()

		-- Calculate the number of secondary dummies that we need to create
		local num_of_dummies = (((length/2) - width) / (width*2))
		if num_of_dummies%2 ~= 0 then
			-- If its an uneven number then make the number even
			num_of_dummies = num_of_dummies + 1
		end
		num_of_dummies = num_of_dummies / 2

		-- Create the main wall dummy
		local dummy = CreateUnitByName("npc_dummy_blank", end_point_left, false, caster, caster, caster_team)
		table.insert(ability.outer_dummies, dummy)
		ability:ApplyDataDrivenModifier(dummy, dummy, outer_dummy_modifier, {})
		EmitSoundOn(dummy_sound, dummy)	

		-- Create the secondary dummies for the left half of the wall
		for i=1,num_of_dummies + 2 do
			-- Create a dummy on every interval point to fill the whole wall
			local temporary_point = target_point + (width * 2 * i + (width - width/10)) * direction_left

			-- Create the secondary dummy and apply the dummy aura to it, make sure the caster of the aura is the main dummmy
			-- otherwise you wont be able to save illusion targets
			local dummy_secondary = CreateUnitByName("npc_dummy_blank", temporary_point, false, caster, caster, caster_team)
			table.insert(ability.outer_secondary_dummies, dummy_secondary)
			ability:ApplyDataDrivenModifier(dummy, dummy_secondary, outer_dummy_modifier, {})

			Timers:CreateTimer(duration, function()
				dummy_secondary:RemoveSelf()
			end)
		end

		-- Create the secondary dummies for the right half of the wall
		for i=1,num_of_dummies + 2 do
			-- Create a dummy on every interval point to fill the whole wall
			local temporary_point = target_point + (width * 2 * i + (width - width/10)) * direction_right
			
			-- Create the secondary dummy and apply the dummy aura to it, make sure the caster of the aura is the main dummmy
			-- otherwise you wont be able to save illusion targets
			local dummy_secondary = CreateUnitByName("npc_dummy_blank", temporary_point, false, caster, caster, caster_team)
			table.insert(ability.outer_secondary_dummies, dummy_secondary)
			ability:ApplyDataDrivenModifier(dummy, dummy_secondary, outer_dummy_modifier, {})

			Timers:CreateTimer(duration, function()
				dummy_secondary:RemoveSelf()
			end)
		end

		-- Save the relevant data
		dummy.wall_start_time = dummy.wall_start_time or GameRules:GetGameTime()
		dummy.wall_duration = dummy_wall_duration or duration
		dummy.wall_level = dummy.wall_level or ability_level
		dummy.wall_table = dummy.wall_table or {}

		-- Create the wall particle
		local particle = ParticleManager:CreateParticle(wall_particle, PATTACH_POINT_FOLLOW, dummy)
		ParticleManager:SetParticleControl(particle, 1, end_point_right)
		table.insert(ability.outer_particles, particle)
		
		-- Set a timer to kill the sound and particle
		Timers:CreateTimer(duration,function()
			StopSoundOn(dummy_sound, dummy)
			dummy:RemoveSelf()
		end)
	end

	-- Make inner barrier
	for wall_number=0, 3 do
		local radius = ability:GetLevelSpecialValueFor("inner_barrier_radius", ability_level)
		local range = math.sqrt(radius * radius / 2)
		local prototype_target_point = caster_location + caster:GetForwardVector() * range
		-- unused code to turn inner barrier into diamond
		--prototype_target_point = RotatePosition(caster_location, QAngle(0, 45, 0), prototype_target_point)
		local target_point = RotatePosition(caster_location, QAngle(0, 90 * wall_number, 0), prototype_target_point)

		-- Cosmetic variables
		local inner_dummy_modifier = keys.inner_dummy_modifier
		local wall_particle = keys.wall_particle
		local dummy_sound = keys.dummy_sound

		-- Ability variables
		local length = range * 2
		local width = ability:GetLevelSpecialValueFor("width", ability_level)
		local duration = ability:GetLevelSpecialValueFor("barrier_duration", ability_level)

		-- Targeting variables
		local direction = (target_point - caster_location):Normalized()
		local rotation_point = target_point + direction * length/2
		local end_point_left = RotatePosition(target_point, QAngle(0,90,0), rotation_point)
		local end_point_right = RotatePosition(target_point, QAngle(0,-90,0), rotation_point)

		local direction_left = (end_point_left - target_point):Normalized() 
		local direction_right = (end_point_right - target_point):Normalized()

		-- Calculate the number of secondary dummies that we need to create
		local num_of_dummies = (((length/2) - width) / (width*2))
		if num_of_dummies%2 ~= 0 then
			-- If its an uneven number then make the number even
			num_of_dummies = num_of_dummies + 1
		end
		num_of_dummies = num_of_dummies / 2

		-- Create the main wall dummy
		local dummy = CreateUnitByName("npc_dummy_blank", end_point_left, false, caster, caster, caster_team)
		table.insert(ability.inner_dummies, dummy)
		ability:ApplyDataDrivenModifier(dummy, dummy, inner_dummy_modifier, {})
		EmitSoundOn(dummy_sound, dummy)	

		-- Create the secondary dummies for the left half of the wall
		for i=1,num_of_dummies + 2 do
			-- Create a dummy on every interval point to fill the whole wall
			local temporary_point = target_point + (width * 2 * i + (width - width/10)) * direction_left

			-- Create the secondary dummy and apply the dummy aura to it, make sure the caster of the aura is the main dummmy
			-- otherwise you wont be able to save illusion targets
			local dummy_secondary = CreateUnitByName("npc_dummy_blank", temporary_point, false, caster, caster, caster_team)
			table.insert(ability.inner_secondary_dummies, dummy_secondary)
			ability:ApplyDataDrivenModifier(dummy, dummy_secondary, inner_dummy_modifier, {})

			Timers:CreateTimer(duration, function()
				dummy_secondary:RemoveSelf()
			end)
		end

		-- Create the secondary dummies for the right half of the wall
		for i=1,num_of_dummies + 2 do
			-- Create a dummy on every interval point to fill the whole wall
			local temporary_point = target_point + (width * 2 * i + (width - width/10)) * direction_right
			
			-- Create the secondary dummy and apply the dummy aura to it, make sure the caster of the aura is the main dummmy
			-- otherwise you wont be able to save illusion targets
			local dummy_secondary = CreateUnitByName("npc_dummy_blank", temporary_point, false, caster, caster, caster_team)
			table.insert(ability.inner_secondary_dummies, dummy_secondary)
			ability:ApplyDataDrivenModifier(dummy, dummy_secondary, inner_dummy_modifier, {})

			Timers:CreateTimer(duration, function()
				dummy_secondary:RemoveSelf()
			end)
		end

		-- Save the relevant data
		dummy.wall_start_time = dummy.wall_start_time or GameRules:GetGameTime()
		dummy.wall_duration = dummy_wall_duration or duration
		dummy.wall_level = dummy.wall_level or ability_level
		dummy.wall_table = dummy.wall_table or {}

		-- Create the wall particle
		local particle = ParticleManager:CreateParticle(wall_particle, PATTACH_POINT_FOLLOW, dummy)
		ParticleManager:SetParticleControl(particle, 1, end_point_right)
		table.insert(ability.inner_particles, particle)
		
		-- Set a timer to kill the sound and particle
		Timers:CreateTimer(duration,function()
			StopSoundOn(dummy_sound, dummy)
			dummy:RemoveSelf()
		end)
	end
end

function duplexBarrierFollow( keys )
	
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local caster = ability.caster
	local caster_location = caster:GetAbsOrigin()
	local caster_movement = (caster_location - ability.last_caster_location)

	for k,v in pairs(ability.outer_dummies) do
		v:SetAbsOrigin(v:GetAbsOrigin() + caster_movement)
	end

	for k,v in pairs(ability.inner_dummies) do
		v:SetAbsOrigin(v:GetAbsOrigin() + caster_movement)
	end

	for k,v in pairs(ability.outer_secondary_dummies) do
		v:SetAbsOrigin(v:GetAbsOrigin() + caster_movement)
	end

	for k,v in pairs(ability.inner_secondary_dummies) do
		v:SetAbsOrigin(v:GetAbsOrigin() + caster_movement)
	end

	for wall_number=0, 3 do
		local radius = ability:GetLevelSpecialValueFor("outer_barrier_radius", ability_level)
		local range = math.sqrt(radius * radius / 2)
		local prototype_target_point = caster_location + ability.original_caster_facing * range
		local target_point = RotatePosition(caster_location, QAngle(0, 90 * wall_number, 0), prototype_target_point)
		local length = range * 2
		local direction = (target_point - caster_location):Normalized()
		local rotation_point = target_point + direction * length/2
		local end_point_right = RotatePosition(target_point, QAngle(0,-90,0), rotation_point)
		
		local particle = ability.outer_particles[wall_number + 1]
		ParticleManager:SetParticleControl(particle, 1, end_point_right)
	end

	for wall_number=0, 3 do
		local radius = ability:GetLevelSpecialValueFor("inner_barrier_radius", ability_level)
		local range = math.sqrt(radius * radius / 2)
		local prototype_target_point = caster_location + ability.original_caster_facing * range
		local target_point = RotatePosition(caster_location, QAngle(0, 90 * wall_number, 0), prototype_target_point)
		local length = range * 2
		local direction = (target_point - caster_location):Normalized()
		local rotation_point = target_point + direction * length/2
		local end_point_right = RotatePosition(target_point, QAngle(0,-90,0), rotation_point)
		
		local particle = ability.inner_particles[wall_number + 1]
		ParticleManager:SetParticleControl(particle, 1, end_point_right)
	end

	ability.last_caster_location = caster_location
end

--[[Author: Pizzalol
	Date: 05.04.2015.
	Acts as an aura which checks if any hero passed the wall]]
function duplexOuterBarrierAura( keys )
	local caster = keys.caster -- Main wall dummy
	local target = keys.target -- Secondary dummies
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local radius = ability:GetLevelSpecialValueFor("width", ability_level)

	local target_teams = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_flags = DOTA_UNIT_TARGET_FLAG_NONE

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, target_flags, FIND_CLOSEST, false)

	for _,unit in ipairs(units) do
		if not unit:HasModifier(keys.outer_barrier_modifier) then
			ability:ApplyDataDrivenModifier(caster, unit, outer_barrier_modifier, {})
			table.insert(targets_hit_table[ability.caster], unit)
			if unit:HasModifier(keys.inner_barrier_modifier) then
				ability:ApplyDataDrivenModifier(caster, unit, stun_modifier, {})
			end
		end
	end
end

function duplexInnerBarrierAura( keys )
	local caster = keys.caster -- Main wall dummy
	local target = keys.target -- Secondary dummies
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local radius = ability:GetLevelSpecialValueFor("width", ability_level)

	local target_teams = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_flags = DOTA_UNIT_TARGET_FLAG_NONE

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, target_flags, FIND_CLOSEST, false)

	for _,unit in ipairs(units) do
		if not unit:HasModifier(keys.inner_barrier_modifier) then
			ability:ApplyDataDrivenModifier(caster, unit, inner_barrier_modifier, {})
			table.insert(targets_hit_table[ability.caster], unit)
			if unit:HasModifier(keys.outer_barrier_modifier) then
				ability:ApplyDataDrivenModifier(caster, unit, stun_modifier, {})
			end
		end
	end
end

function removeDebuffs( keys )
	for k,unit in targets_hit_table[ability.caster] do
		if unit:HasModifier(keys.outer_barrier_modifier) then
			unit:RemoveModifierByName(keys.outer_barrier_modifier)
		end
		if unit:HasModifier(keys.inner_barrier_modifier) then
			unit:RemoveModifierByName(keys.inner_barrier_modifier)
		end
	end
	targets_hit_table[caster] = nil
end