modifier_gray_thaumaturgy_debuff = class({})

function modifier_gray_thaumaturgy_debuff:IsHidden()
	return false
end

function modifier_gray_thaumaturgy_debuff:IsPurgable()
	return false
end

function modifier_gray_thaumaturgy_debuff:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
end

function modifier_gray_thaumaturgy_debuff:GetModifierBonusStats_Agility( params )
	if IsServer() then
		print( self:GetCaster():FindModifierByName("modifier_gray_thaumaturgy_stacks"):GetStackCount())
		return self:GetCaster():FindModifierByName("modifier_gray_thaumaturgy_stacks"):GetStackCount() * -1
	end
end