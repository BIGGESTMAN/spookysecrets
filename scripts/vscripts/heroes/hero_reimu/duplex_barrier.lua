--[[Author: Pizzalol, kritth
	Date: 05.04.2015.
	Create the wall dummies at along the wall]]
function duplexBarrier( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local caster_team = caster:GetTeamNumber()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local debug_duration = 5
	local debug_wall_particle = "particles/units/heroes/hero_wisp/wisp_overcharge.vpcf"

	ability.caster = caster
	ability.last_caster_location = caster_location
	ability.original_caster_facing = caster:GetForwardVector()
	--ability.last_caster_facing = caster:GetForwardVector()
	ability.outer_dummies = {}
	ability.outer_secondary_dummies = {}
	ability.inner_dummies = {}
	ability.inner_secondary_dummies = {}
	ability.particles = {}

	-- Make outer barrier
	for wall_number=0, 3 do
		local radius = ability:GetLevelSpecialValueFor("outer_barrier_radius", ability_level)
		local range = math.sqrt(radius * radius / 2)
		local prototype_target_point = caster_location + caster:GetForwardVector() * range
		local target_point = RotatePosition(caster_location, QAngle(0, 90 * wall_number, 0), prototype_target_point)

		-- Cosmetic variables
		local dummy_modifier = keys.dummy_modifier
		local wall_particle = debug_wall_particle
		local dummy_sound = keys.dummy_sound

		-- Ability variables
		local length = range * 2
		local width = ability:GetLevelSpecialValueFor("width", ability_level)
		local duration = debug_duration --ability:GetLevelSpecialValueFor("duration", ability_level)

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
		ability:ApplyDataDrivenModifier(dummy, dummy, dummy_modifier, {})
		EmitSoundOn(dummy_sound, dummy)	

		-- Create the secondary dummies for the left half of the wall
		for i=1,num_of_dummies + 2 do
			-- Create a dummy on every interval point to fill the whole wall
			local temporary_point = target_point + (width * 2 * i + (width - width/10)) * direction_left

			-- Create the secondary dummy and apply the dummy aura to it, make sure the caster of the aura is the main dummmy
			-- otherwise you wont be able to save illusion targets
			local dummy_secondary = CreateUnitByName("npc_dummy_blank", temporary_point, false, caster, caster, caster_team)
			table.insert(ability.outer_secondary_dummies, dummy_secondary)
			ability:ApplyDataDrivenModifier(dummy, dummy_secondary, dummy_modifier, {})

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
			ability:ApplyDataDrivenModifier(dummy, dummy_secondary, dummy_modifier, {})

			Timers:CreateTimer(duration, function()
				dummy_secondary:RemoveSelf()
			end)
		end

		-- Save the relevant data
		dummy.wall_start_time = dummy.wall_start_time or GameRules:GetGameTime()
		dummy.wall_duration = dummy_wall_duration or duration
		dummy.wall_level = dummy.wall_level or ability_level
		dummy.wall_table = dummy.wall_table or {}

		--[[ Create the wall particle
		local particle = ParticleManager:CreateParticle(wall_particle, PATTACH_ABSORIGIN_FOLLOW, dummy)
		ParticleManager:SetParticleControl(particle, 1, end_point_right)
		table.insert(ability.particles, particle)
		--]]
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
		local dummy_modifier = keys.dummy_modifier
		local wall_particle = debug_wall_particle
		local dummy_sound = keys.dummy_sound

		-- Ability variables
		local length = range * 2
		local width = ability:GetLevelSpecialValueFor("width", ability_level)
		local duration = debug_duration --ability:GetLevelSpecialValueFor("duration", ability_level)

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
		ability:ApplyDataDrivenModifier(dummy, dummy, dummy_modifier, {})
		EmitSoundOn(dummy_sound, dummy)	

		-- Create the secondary dummies for the left half of the wall
		for i=1,num_of_dummies + 2 do
			-- Create a dummy on every interval point to fill the whole wall
			local temporary_point = target_point + (width * 2 * i + (width - width/10)) * direction_left

			-- Create the secondary dummy and apply the dummy aura to it, make sure the caster of the aura is the main dummmy
			-- otherwise you wont be able to save illusion targets
			local dummy_secondary = CreateUnitByName("npc_dummy_blank", temporary_point, false, caster, caster, caster_team)
			table.insert(ability.inner_secondary_dummies, dummy_secondary)
			ability:ApplyDataDrivenModifier(dummy, dummy_secondary, dummy_modifier, {})

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
			ability:ApplyDataDrivenModifier(dummy, dummy_secondary, dummy_modifier, {})

			Timers:CreateTimer(duration, function()
				dummy_secondary:RemoveSelf()
			end)
		end

		-- Save the relevant data
		dummy.wall_start_time = dummy.wall_start_time or GameRules:GetGameTime()
		dummy.wall_duration = dummy_wall_duration or duration
		dummy.wall_level = dummy.wall_level or ability_level
		dummy.wall_table = dummy.wall_table or {}

		--[[ Create the wall particle
		local particle = ParticleManager:CreateParticle(wall_particle, PATTACH_ABSORIGIN_FOLLOW, dummy)
		ParticleManager:SetParticleControl(particle, 1, end_point_right)
		table.insert(ability.particles, particle)
		--]]
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

	for k,v in pairs(ability.inner_dummies) do
		v:SetAbsOrigin(v:GetAbsOrigin() + caster_movement)
	end

	for k,v in pairs(ability.outer_secondary_dummies) do
		v:SetAbsOrigin(v:GetAbsOrigin() + caster_movement)
	end

	for k,v in pairs(ability.inner_secondary_dummies) do
		v:SetAbsOrigin(v:GetAbsOrigin() + caster_movement)
	end

	for k,v in pairs(ability.outer_dummies) do
		v:SetAbsOrigin(v:GetAbsOrigin() + caster_movement)
	end
	--[[
	for k,v in pairs(ability.particles) do
		ParticleManager:DestroyParticle(v, true)
	end
	particles = {}
	--

	for wall_number=0, 3 do
		local dummy = ability.outer_dummies[wall_number + 1]
		dummy:SetAbsOrigin(dummy:GetAbsOrigin() + caster_movement)
--[[
		local radius = ability:GetLevelSpecialValueFor("outer_barrier_radius", ability_level)
		local range = math.sqrt(radius * radius / 2)
		local prototype_target_point = caster_location + ability.original_caster_facing * range
		local target_point = RotatePosition(caster_location, QAngle(0, 90 * wall_number, 0), prototype_target_point)
		local length = range * 2
		local direction = (target_point - caster_location):Normalized()
		local rotation_point = target_point + direction * length/2
		local end_point_right = RotatePosition(target_point, QAngle(0,-90,0), rotation_point)
		
		local particle = ability.particles[wall_number + 1]
		local particle = ParticleManager:CreateParticle(keys.wall_particle, PATTACH_ABSORIGIN_FOLLOW, dummy)
		ParticleManager:SetParticleControl(particle, 1, end_point_right)
		table.insert(ability.particles, particle)--
	end

	ability.last_caster_location = caster_location--]]
end

--[[Author: Pizzalol
	Date: 05.04.2015.
	Checks if there is an alive illusion of the target, if there is not then create an illusion]]
function duplexBarrierIllusionCheck( keys )
	local caster = keys.caster -- This is the dummy in this case
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability

	-- Get the original hero
	local player = caster:GetPlayerOwnerID()
	local player_hero = PlayerResource:GetPlayer(player):GetAssignedHero()
	
	-- Initialize the tracking data variables in case there was a hero at the wall spawn point
	ability.wall_level = ability.wall_level or (ability:GetLevel() - 1)
	local ability_level = ability.wall_level
	ability.wall_start_time = ability.wall_start_time or GameRules:GetGameTime() 
	ability.wall_duration = ability.wall_duration or (ability:GetLevelSpecialValueFor("duration", ability_level))
	ability.wall_table = ability.wall_table or {}

	-- Ability variables	
	local unit_name = target:GetUnitName()
	local illusion_origin = target_location + RandomVector(100)
	local illusion_duration = ability.wall_duration - (GameRules:GetGameTime() - ability.wall_start_time)
	local illusion_outgoing_damage = ability:GetLevelSpecialValueFor("replica_damage_outgoing", ability_level)
	local illusion_incoming_damage = ability:GetLevelSpecialValueFor("replica_damage_incoming", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)

	-- Check if the hit hero is a real hero
	if target:IsRealHero() then
		-- Check if the illusion of the target is alive
		if not IsValidEntity(ability.wall_table[target]) or not ability.wall_table[target]:IsAlive() then
			-- Create an illusion if its not
			local illusion = CreateUnitByName(unit_name, illusion_origin, true, player_hero, nil, caster:GetTeamNumber())
			illusion:SetPlayerID(player)
			illusion:SetControllableByPlayer(player, true)

			local target_level = target:GetLevel()
			for i = 1, target_level - 1 do
				illusion:HeroLevelUp(false)
			end

			illusion:SetAbilityPoints(0) 
			for ability_slot = 0, 15 do
				local target_ability = target:GetAbilityByIndex(ability_slot) 
				if target_ability then
					local target_ability_level = target_ability:GetLevel() 
					local target_ability_name = target_ability:GetAbilityName() 
					local illusion_ability = illusion:FindAbilityByName(target_ability_name) 
					illusion_ability:SetLevel(target_ability_level) 
				end
			end

			for item_slot = 0, 5 do
				local item = target:GetItemInSlot(item_slot) 
				if item then
					local item_name = item:GetName() 
					local new_item = CreateItem(item_name, illusion, illusion) 
					illusion:AddItem(new_item) 
				end
			end

			illusion:AddNewModifier(caster, ability, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})

			illusion:MakeIllusion() 
			illusion:SetHealth(target:GetHealth()) -- Set the health of the illusion to be the same as the target HP
			ability.wall_table[target] = illusion -- Keep track of the illusion

			-- Deal damage for creating the illusion
			local damage_table = {}
			damage_table.attacker = player_hero
			damage_table.victim = target
			damage_table.ability = ability
			damage_table.damage_type = ability:GetAbilityDamageType() 
			damage_table.damage = damage

			ApplyDamage(damage_table)
		end
	end
end

--[[Author: Pizzalol
	Date: 05.04.2015.
	Acts as an aura which checks if any hero passed the wall]]
function duplexBarrierAura( keys )
	local caster = keys.caster -- Main wall dummy
	local target = keys.target -- Secondary dummies
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local radius = ability:GetLevelSpecialValueFor("width", ability_level)
	local aura_modifier = keys.aura_modifier

	local target_teams = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, target_flags, FIND_CLOSEST, false)

	for _,unit in ipairs(units) do
		ability:ApplyDataDrivenModifier(caster, unit, aura_modifier, {Duration = 0.1})
	end
end