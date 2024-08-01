--Used rejuvenator_hit_logic as a base
function chargeBackOnKill(damage, activator, caller)

	local upgradeLevel = (activator:GetPlayerItemBySlot(0):GetAttributeValue("mult airblast refire time")) - 1
	--print(upgradeLevel)

	local primary = activator:GetPlayerItemBySlot(0)
	
	activator.m_flChargeMeter = activator.m_flChargeMeter + 20 * upgradeLevel
	
	if activator.m_flChargeMeter > 100 then
		activator.m_flChargeMeter = 100
	end	
end