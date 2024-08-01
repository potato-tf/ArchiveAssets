--Used rejuvenator_hit_logic as a base
function launcherReloadOnKill(damage, activator, caller)
	

	local upgradeLevel
	
	--Look through weapon slots to see if anyone has the vitasaw attribute, then use that value as the upgrade level
	if activator:GetPlayerItemBySlot(0):GetAttributeValue("preserve ubercharge", true) ~= nil then
		
	upgradeLevel = activator:GetPlayerItemBySlot(0):GetAttributeValue("preserve ubercharge", true)
		
	elseif 	activator:GetPlayerItemBySlot(1):GetAttributeValue("preserve ubercharge", true) ~= nil then
	upgradeLevel = activator:GetPlayerItemBySlot(1):GetAttributeValue("preserve ubercharge", true)
		
	elseif	activator:GetPlayerItemBySlot(2):GetAttributeValue("preserve ubercharge", true) ~= nil then
	upgradeLevel = activator:GetPlayerItemBySlot(2):GetAttributeValue("preserve ubercharge", true)
		
	end	
	
    local BASE_CLIP = 4

	local primary = activator:GetPlayerItemBySlot(0)
		if primary:GetItemName() ~= "The Cow Mangler 5000" then
		--print(primary:GetItemName())

			local clipBonusMult = primary:GetAttributeValueByClass("mult_clipsize", 1)

			local clipBonusAtomic = primary:GetAttributeValueByClass("mult_clipsize_upgrade_atomic", 0)

			local airstrikeKills = 0
		
		
			if primary:GetItemName() == "The Air Strike" then
				--print("We're the airstrike")
				airstrikeKills = activator.m_Shared.m_iDecapitations + 1
			end
		
			local maxClip = (BASE_CLIP * clipBonusMult) + clipBonusAtomic + airstrikeKills
		--	print(maxClip)

			primary.m_iClip1 = primary.m_iClip1 + upgradeLevel
			if primary.m_iClip1 > maxClip then

				primary.m_iClip1 = maxClip

			end
		else
		--print(primary:GetItemName())

			local clipBonusMult = primary:GetAttributeValueByClass("mult_clipsize_upgrade", 1)
			print("Clip bonus mult: " .. clipBonusMult)


			local maxClip = (BASE_CLIP * 5) * clipBonusMult
		--	print(maxClip)
		
			print(maxClip)

			primary.m_flEnergy = primary.m_flEnergy + (upgradeLevel * 5)
			if primary.m_flEnergy > maxClip then

				primary.m_flEnergy = maxClip

			end
		end	
end