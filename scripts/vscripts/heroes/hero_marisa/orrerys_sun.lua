--[[
	Author: Noya, physics by BMD
	Date: 02.02.2015.
	Spawns orbs for exorcism and applies the modifier that takes care of its logic
]]

require "Physics"

function orrerysSunStart( event )
	local caster = event.caster
	if (caster:IsAlive()) then
		local ability = event.ability
		local playerID = caster:GetPlayerID()
		local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
		local duration = 10
		local orbs = ability:GetLevelSpecialValueFor( "orbs", ability:GetLevel() - 1 )
		local delay_between_orb_spawns = ability:GetLevelSpecialValueFor( "delay_between_orb_spawns", ability:GetLevel() - 1 )
		local unit_name = "orrerys_sun_orb"
		
		ability.last_caster_location = caster_location

		-- Initialize the table to keep track of all orbs
		if not caster.orbs then
			caster.orbs = {}
		end

		local existing_orb_count = 0
		for k,orb in pairs(caster.orbs) do
			existing_orb_count = existing_orb_count + 1
		end

		print("Spawning "..orbs - existing_orb_count.." orbs")
		for i=1,orbs - existing_orb_count do
			Timers:CreateTimer(i * delay_between_orb_spawns, function()
				local unit = CreateUnitByName(unit_name, caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())

				-- The modifier takes care of the physics and logic
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_orrerys_sun_orb", {})
				
				-- Add the spawned unit to the table
				table.insert(caster.orbs, unit)
			end)
		end
	end
end

-- Movement logic for each spirit
-- Units have 4 states: 
	-- acquiring: transition after completing one target-return cycle.
	-- target_acquired: tracking an enemy or point to collide
	-- returning: After colliding with an enemy, move back to the casters location
	-- end: moving back to the caster to be destroyed and heal
function orbPhysics( event )
	local caster = event.caster
	local unit = event.target
	local ability = event.ability
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local orb_speed = ability:GetLevelSpecialValueFor( "orb_speed", ability:GetLevel() - 1 )
	local min_damage = ability:GetLevelSpecialValueFor( "min_damage", ability:GetLevel() - 1 )
	local max_damage = ability:GetLevelSpecialValueFor( "max_damage", ability:GetLevel() - 1 )
	local max_damage = ability:GetLevelSpecialValueFor( "max_damage", ability:GetLevel() - 1 )
	local average_damage = ability:GetLevelSpecialValueFor( "average_damage", ability:GetLevel() - 1 )
	local give_up_distance = ability:GetLevelSpecialValueFor( "give_up_distance", ability:GetLevel() - 1 )
	local max_distance = ability:GetLevelSpecialValueFor( "max_distance", ability:GetLevel() - 1 )
	local heal_percent = ability:GetLevelSpecialValueFor( "heal_percent", ability:GetLevel() - 1 ) * 0.01
	local min_time_between_attacks = ability:GetLevelSpecialValueFor( "min_time_between_attacks", ability:GetLevel() - 1 )
	local abilityDamageType = ability:GetAbilityDamageType()
	local abilityTargetType = ability:GetAbilityTargetType()
	local particleDamage = "particles/units/heroes/hero_death_prophet/death_prophet_exorcism_attack.vpcf"
	local particleDamageBuilding = "particles/units/heroes/hero_death_prophet/death_prophet_exorcism_attack_building.vpcf"
	--local particleNameHeal = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_start_sparks_b.vpcf"

	-- Make the spirit a physics unit
	Physics:Unit(unit)

	-- General properties
	unit:PreventDI(true)
	unit:SetAutoUnstuck(false)
	unit:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	unit:FollowNavMesh(false)
	unit:SetPhysicsVelocityMax(orb_speed)
	unit:SetPhysicsVelocity(orb_speed * RandomVector(1))
	unit:SetPhysicsFriction(0)
	unit:Hibernate(false)
	unit:SetGroundBehavior(PHYSICS_GROUND_LOCK)

	-- Initial default state
	unit.target_acquired = false

	-- This is to skip frames
	local frameCount = 0

	-- Store the damage done
	unit.damage_done = 0

	-- Store the interval between attacks, starting at min_time_between_attacks
	unit.last_attack_time = GameRules:GetGameTime() - min_time_between_attacks

	-- Color Debugging for points and paths. Turn it false later!
	local Debug = false
	local pathColor = Vector(255,255,255) -- White to draw path
	local targetColor = Vector(255,0,0) -- Red for enemy targets
	local idleColor = Vector(0,255,0) -- Green for moving to idling points
	local returnColor = Vector(0,0,255) -- Blue for the return
	local endColor = Vector(0,0,0) -- Back when returning to the caster to end
	local draw_duration = 3

	-- Find one target point at random which will be used for the first acquisition.
	local point = caster:GetAbsOrigin() + RandomVector(RandomInt(radius/2, radius))

	-- This is set to repeat on each frame
	unit:OnPhysicsFrame(function(unit)

		orb_speed = ability:GetLevelSpecialValueFor( "orb_speed", ability:GetLevel() - 1 )

		-- Current positions
		local source = caster:GetAbsOrigin()
		local current_position = unit:GetAbsOrigin()

		-- COLLISION CHECK
		local distance = (point - current_position):Length()
		local collision = distance < 50

		-- MAX DISTANCE CHECK
		local distance_to_caster = (source - current_position):Length()
		if distance_to_caster > max_distance then
			if distance > max_distance then
				unit.target_acquired = false
				unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * (source - unit:GetAbsOrigin()):Normalized())
			end
			orb_speed = orb_speed + ability:GetLevelSpecialValueFor("acceleration_factor", ability:GetLevel() - 1) * (distance_to_caster - max_distance)
		else
			orb_speed = ability:GetLevelSpecialValueFor("orb_speed", ability:GetLevel() - 1)
		end

		unit:SetPhysicsVelocityMax(orb_speed)
		unit:SetPhysicsVelocity(orb_speed * unit:GetPhysicsVelocity())

		-- Move the unit orientation to adjust the particle
		unit:SetForwardVector( ( unit:GetPhysicsVelocity() ):Normalized() )

		-- Print the path on Debug mode
		if Debug then DebugDrawCircle(current_position, pathColor, 0, 2, true, draw_duration) end

		local enemies = nil

		-- Use this if skipping frames is needed (--if frameCount == 0 then..)
		frameCount = (frameCount + 1) % 3

		-- Movement and Collision detection are state independent

		-- MOVEMENT	
		-- Get the direction
		local diff = point - unit:GetAbsOrigin()
        diff.z = 0
        local direction = diff:Normalized()

		-- Calculate the angle difference
		local angle_difference = RotationDelta(VectorToAngles(unit:GetPhysicsVelocity():Normalized()), VectorToAngles(direction)).y
		
		-- Set the new velocity
		if math.abs(angle_difference) < 5 then
			-- CLAMP
			local newVel = unit:GetPhysicsVelocity():Length() * direction
			unit:SetPhysicsVelocity(newVel)
		elseif angle_difference > 0 then
			local newVel = RotatePosition(Vector(0,0,0), QAngle(0,10,0), unit:GetPhysicsVelocity())
			unit:SetPhysicsVelocity(newVel)
		else		
			local newVel = RotatePosition(Vector(0,0,0), QAngle(0,-10,0), unit:GetPhysicsVelocity())
			unit:SetPhysicsVelocity(newVel)
		end

		if not unit.target_acquired then
			unit.target_acquired = true
			point = source + RandomVector(RandomInt(radius/2, radius))
			--print("Acquiring -> Random Point Target acquired")
			if Debug then DebugDrawCircle(point, idleColor, 100, 25, true, draw_duration) end
		end

		if collision then
			unit.target_acquired = false
		end
    end)
end

-- Updates the last_targeted enemy, to focus the ghosts on it.
function orrerysSunAttack( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	-- for k,spirit in pairs(caster.orbs) do
	-- 	spirit:PerformAttack(target, true, true, true, true )
	-- end

	for i=1,ability:GetLevelSpecialValueFor("orbs", ability:GetLevel() - 1) do
		Timers:CreateTimer(i * ability:GetLevelSpecialValueFor("delay_between_orb_attacks", ability:GetLevel() - 1), function()
			caster.orbs[i]:PerformAttack(target, true, true, true, true )
		end)
	end
end

function orbAttackHit( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
		damage_table.ability = ability
		damage_table.damage = caster:GetAverageTrueAttackDamage() / 10

	ApplyDamage(damage_table)
end

-- Kill all units when the owner dies or the spell is cast while the first one is still going
function endOrrerysSun( event )
	local caster = event.caster
	local targets = caster.orbs or {}

	print("Exorcism Death")
	for _,unit in pairs(targets) do		
	   	if unit and IsValidEntity(unit) then
    	  	unit:SetPhysicsVelocity(Vector(0,0,0))
	        unit:OnPhysicsFrame(nil)

			-- Kill
	        unit:ForceKill(false)
    	end
	end
	caster.orbs = {}
end