--Used rejuvenator_hit_logic as a base
function rescueDebuffOnHit(damage, activator, caller)
	
	local upgradeLevel = 2
	
	if activator:GetPlayerItemBySlot(0):GetAttributeValue("disguise speed penalty") then
		
		upgradeLevel = (activator:GetPlayerItemBySlot(0):GetAttributeValue("disguise speed penalty") * 2)	
	end
	
	local upgradeType = activator:GetPlayerItemBySlot(0):GetAttributeValue("disguise no burn")
	local giantMultiplier = 1
	--Used to store old attribute (if it exists) for use by other upgrade types
	local oldAttr
	
	--control value bricks, here to ensure bots don't get permanently degraded when
	--multiple debuff instances start referencing each other and overwriting old ones.
	--upgrade 1 uses an addcond, so it is safe to not have a validator for it
	
	if caller:GetAttributeValue("metal_pickup_decreased", true) and upgradeType == 2 then
		return
	end	
	
	if caller:GetAttributeValue("duckstreaks active", true) and upgradeType == 3 then
		return
	end	

	--Duration upgrades help to burn through giant duration penalty
    if caller.m_bIsMiniBoss == 1 then 
        giantMultiplier = 0.15 * upgradeLevel
    end 
	

	if upgradeType == 1 then
		caller:AddCond(30, (upgradeLevel * giantMultiplier), activator)

		elseif upgradeType == 2 then
		caller:AddCond(20, (upgradeLevel * giantMultiplier), activator)
		oldAttr = caller:GetAttributeValue("damage penalty", true) or nil
		caller:SetAttributeValue("damage penalty", ((oldAttr or 0) + 1.5))
		caller:SetAttributeValue("metal_pickup_decreased", 1)	

		--Clean up after timer ends
		timer.Simple((upgradeLevel * giantMultiplier), function() 
			caller:SetAttributeValue("damage penalty", oldAttr) 
			caller:SetAttributeValue("metal_pickup_decreased", nil)
			RemoveCond(20)	
		end)	
	
	elseif upgradeType == 3 then --gburst soldiers store their movespeed in their rocket launcher,
								--leaving true on makes some sense because of this
	caller:AddCond(50, (upgradeLevel * giantMultiplier), activator)	
	oldAttr = caller:GetAttributeValue("move speed bonus", true) or nil
	caller:SetAttributeValue("move speed bonus",((oldAttr or 1) - 0.5))
	caller:SetAttributeValue("duckstreaks active",1)	
	timer.Simple((upgradeLevel * giantMultiplier) ,function() 
			caller:SetAttributeValue("move speed bonus", oldAttr or 1) 
			caller:SetAttributeValue("duckstreaks active", nil)
			RemoveCond(50)	
		end)	
	end	
end