--Used rejuvenator_hit_logic as a base
function pomsonEMPhit(damage, activator, caller)

    if caller.m_iHealth > caller.m_iMaxHealth * 0.5 or caller.m_bIsMiniBoss == 1 or caller:IsRealPlayer() == true then 
        return 
    end 
	
	if damage < 10 then --afterburn stunlocking is ridiculous
		return
	end

		
	local upgradeLevel = (activator:GetPlayerItemBySlot(0):GetAttributeValue("disguise speed penalty")) or 0.25
    --print(damage)
    --print(activator)
    --print(caller)	

    caller:AddCond(71, (upgradeLevel * 2), activator)
end