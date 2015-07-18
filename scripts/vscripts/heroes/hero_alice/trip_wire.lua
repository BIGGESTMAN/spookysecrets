require "libraries/util"

function createWire(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	if caster ~= target then
		local wire = {keys.caster, keys.target}
		if not caster.wires then caster.wires = {} end
		caster.wires[wire] = true

		Timers:CreateTimer(ability:GetLevelSpecialValueFor("duration", ability_level), function()
			if caster.wires[wire] then destroyWire(wire, caster) end
		end)

		caster.last_wire = wire
		-- Enable attaching-secondary-target ability
		local main_ability_name	= ability:GetAbilityName()
		local sub_ability_name	= keys.attach_ability_name
		caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
		ability:ApplyDataDrivenModifier(caster, caster, keys.attach_window_modifier, {})

		ability:ApplyDataDrivenModifier(caster, caster, keys.caster_modifier, {})
	else
		caster:SetMana(caster:GetMana() + ability:GetManaCost(ability_level))
		ability:EndCooldown()
	end
end

function updateWire(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	for wire,v in pairs(caster.wires) do
		local target1 = wire[1]
		local target2 = wire[2]
		local range = (target2:GetAbsOrigin() - target1:GetAbsOrigin()):Length2D()
		if range <= ability:GetLevelSpecialValueFor("max_length", ability_level)  and target1:IsAlive() and target2:IsAlive() then
			local lightningBolt = ParticleManager:CreateParticle("particles/econ/events/ti5/dagon_ti5.vpcf", PATTACH_WORLDORIGIN, target1)
			ParticleManager:SetParticleControl(lightningBolt,0,Vector(target1:GetAbsOrigin().x,target1:GetAbsOrigin().y,target1:GetAbsOrigin().z + target1:GetBoundingMaxs().z ))	
			ParticleManager:SetParticleControl(lightningBolt,1,Vector(target2:GetAbsOrigin().x,target2:GetAbsOrigin().y,target2:GetAbsOrigin().z + target2:GetBoundingMaxs().z ))

			local thinker_modifier = keys.thinker_modifier
			local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
			local direction = (target2:GetAbsOrigin() - target1:GetAbsOrigin()):Normalized()

			local hit_units = unitsInLine(caster, ability, thinker_modifier, target1:GetAbsOrigin(), range, radius, direction, false)

			if #hit_units > 0 then
				wire_triggered = false -- Make sure attaching to an enemy doesn't instantly break wire
				for k,unit in pairs(hit_units) do
					if unit ~= target1 and unit ~= target2 then
						wire_triggered = true
					end
				end
				if wire_triggered then
					for k,unit in pairs(hit_units) do
						ApplyDamage({victim = unit, attacker = caster, damage = ability:GetLevelSpecialValueFor("damage", ability_level), damage_type = DAMAGE_TYPE_MAGICAL})
						ability:ApplyDataDrivenModifier(caster, unit, keys.root_modifier, {})
					end
					destroyWire(wire, caster)
				end
			end
		else
			destroyWire(wire, caster)
		end
	end
end

function attach(keys)
	local caster = keys.caster
	local target = keys.target
	if caster.last_wire[2] ~= target and caster ~= target then
		caster.last_wire[1] = target
		local main_ability_name	= keys.main_ability_name
		local sub_ability_name	= keys.ability:GetAbilityName()
		caster:SwapAbilities(main_ability_name, sub_ability_name, true, false)
	end
end

function destroyWire(wire, caster)
	caster.wires[wire] = nil
	if caster:FindAbilityByName("trip_wire"):IsHidden() and wire == caster.last_wire then
		caster:SwapAbilities("trip_wire", "trip_wire_attach", true, false)
	end
end

function removeAttachAbility(keys)
	local caster = keys.caster
	if caster:FindAbilityByName("trip_wire"):IsHidden() then
		caster:SwapAbilities("trip_wire", "trip_wire_attach", true, false)
	end
end