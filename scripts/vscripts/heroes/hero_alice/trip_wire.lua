require "libraries/util"

function createWire(keys)
	local caster = keys.caster
	local target = keys.target
	local wire = {keys.caster, keys.target}
	if not caster.wires then caster.wires = {} end
	caster.wires[wire] = true

	Timers:CreateTimer(keys.ability:GetLevelSpecialValueFor("duration", keys.ability:GetLevel() - 1), function()
		if caster.wires[wire] then caster.wires[wire] = nil end
	end)
end

function updateWire(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()
	for wire,v in pairs(caster.wires) do
		local target1 = wire[1]
		local target2 = wire[2]
		local range = (target2:GetAbsOrigin() - target1:GetAbsOrigin()):Length2D()
		if range <= ability:GetLevelSpecialValueFor("max_length", ability_level) then
			local lightningBolt = ParticleManager:CreateParticle("particles/econ/events/ti5/dagon_ti5.vpcf", PATTACH_WORLDORIGIN, target1)
			ParticleManager:SetParticleControl(lightningBolt,0,Vector(target1:GetAbsOrigin().x,target1:GetAbsOrigin().y,target1:GetAbsOrigin().z + target1:GetBoundingMaxs().z ))	
			ParticleManager:SetParticleControl(lightningBolt,1,Vector(target2:GetAbsOrigin().x,target2:GetAbsOrigin().y,target2:GetAbsOrigin().z + target2:GetBoundingMaxs().z ))

			local thinker_modifier = keys.thinker_modifier
			local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
			local direction = (target2:GetAbsOrigin() - target1:GetAbsOrigin()):Normalized()

			local hit_units = unitsInLine(caster, ability, thinker_modifier, target1:GetAbsOrigin(), range, radius, direction, false)

			if #hit_units > 0 then
				for k,unit in pairs(hit_units) do
					ApplyDamage({victim = unit, attacker = caster, damage = ability:GetLevelSpecialValueFor("damage", ability_level), damage_type = DAMAGE_TYPE_MAGICAL})
					print(unit:GetModifierCount(), root_modifier)
					ability:ApplyDataDrivenModifier(caster, unit, keys.root_modifier, {})
					print(unit:GetModifierCount())
				end
				caster.wires[wire] = nil
			end
		else
			caster.wires[wire] = nil
		end
	end

end

function tripWireHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()
	local target = keys.target
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	print("tripWireHit")
end