function fantasyNatureExplosion( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()
	if caster:HasItemInInventory("item_ultimate_scepter") then
		local targets = FindUnitsInRadius(caster:GetTeamNumber(),
	                            caster:GetAbsOrigin(),
	                            nil,
	                            ability:GetLevelSpecialValueFor("explosion_radius", ability_level),
	                            DOTA_UNIT_TARGET_TEAM_ENEMY,
	                            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
	                            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                            FIND_CLOSEST,
	                            false)

		local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.damage_type = ability:GetAbilityDamageType()
		damage_table.ability = ability
		damage_table.damage = ability:GetLevelSpecialValueFor("explosion_damage", ability_level)

		for k,target in pairs(targets) do
			damage_table.victim = target
			ApplyDamage(damage_table)
		end

		local particle = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW, caster)
		--ParticleManager:SetParticleControl(particle, 1, end_point_right)
	end
end