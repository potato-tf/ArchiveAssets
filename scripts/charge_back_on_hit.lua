--Used rejuvenator_hit_logic as a base
function chargeBackOnHit(damage, activator, caller)
	
		if caller.m_bIsMiniBoss ~= 0 then
			return
		end	
	
		upgradeLevel = activator:GetPlayerItemBySlot(1):GetAttributeValue("throwable detonation time") or 1
		activator:RemoveCond(17)
		print("Removing last charge")
		print("Refilling meter")
		activator:AddCond(17, 2.5, activator)
		activator.m_flChargeMeter = 20 * upgradeLevel
		print("Charging")
end