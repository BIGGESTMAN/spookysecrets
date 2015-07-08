modifier_orrerys_sun_spell_detector = class({})

function modifier_orrerys_sun_spell_detector:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}

	return funcs
end

function modifier_orrerys_sun_spell_detector:OnAbilityExecuted( params )
	if IsServer() then
		if params.unit == self:GetParent() then
			if self:GetParent():PassivesDisabled() then
				return 0
			end

			local hAbility = params.ability 
			if hAbility ~= nil and ( not hAbility:IsItem() ) and ( not hAbility:IsToggle() ) then
				orrerys_sun:spellCast(params)
			end
		end
	end

	return 0
end