--Used rejuvenator_hit_logic as a base
function launcherReloadOnKill(damage, activator, caller)
	
	if caller.m_iTeamNum == activator.m_iTeamNum then
		--print("Our team")
		return
	end		

	local upgradeLevel = nil
	
	--Look through weapon slots to see if anyone has the vitasaw attribute, then use that value as the upgrade level
	if activator:GetPlayerItemBySlot(0):GetAttributeValue("preserve ubercharge", true) ~= nil then
		
	upgradeLevel = activator:GetPlayerItemBySlot(0):GetAttributeValue("preserve ubercharge", true)
		
	elseif 	activator:GetPlayerItemBySlot(1):GetAttributeValue("preserve ubercharge", true) ~= nil then
	upgradeLevel = activator:GetPlayerItemBySlot(1):GetAttributeValue("preserve ubercharge", true)
		
	elseif	activator:GetPlayerItemBySlot(2):GetAttributeValue("preserve ubercharge", true) ~= nil then
	upgradeLevel = activator:GetPlayerItemBySlot(2):GetAttributeValue("preserve ubercharge", true)
		
	end	
	
	--if we have no assigned level, give up
	if upgradeLevel == nil then
		print("No upgrade")
		return
	end
	
    local BASE_CLIP = 4

	local primary = activator:GetPlayerItemBySlot(0)
	
	--in case of pyro airblasts or other owner changing events
	--why the fuck are the airstrike, mangler, and direct hit different classes?
	--I can kind of understand the loose cannon having its own class, but those motherfuckers all work basically the same, except maybe the mangler
	--BUT NOOOOO I'M NOT ALLOWED TO HAVE READABLE IF STATEMENTS!
	--if primary.m_iClassname ~= "tf_weapon_grenadelauncher" and primary.m_iClassname ~= "tf_weapon_rocketlauncher" and primary.m_iClassName ~= "tf_weapon_rocketlauncher_airstrike" and primary.m_iClassName ~= "tf_weapon_rocketlauncher_directhit" and primary.m_iClassName ~= "tf_weapon_cannon" and primary.m_iClassName ~= "tf_weapon_particle_cannon" then
	--	print("We aren't a rocket launcher")
	--	return
	--end

	--fuck this class spaghetti, we're going to assume that no flamethrowers will ever have the uber retaining upgrade on them, so they'll get filtered by the upgrade level check instead	
	
		if primary:GetItemName() ~= "The Cow Mangler 5000" then
		--print(primary:GetItemName())

			local clipBonusMult = primary:GetAttributeValueByClass("mult_clipsize", 1)

			local clipBonusAtomic = primary:GetAttributeValueByClass("mult_clipsize_upgrade_atomic", 0)

			local airstrikeKills = 0
			
			local overloadRefundAmount = 0
		
		
			if primary:GetItemName() == "The Air Strike" then
				--print("We're the airstrike")
				airstrikeKills = activator.m_Shared.m_iDecapitations + 1
			end
		
			local maxClip = (BASE_CLIP * clipBonusMult) + clipBonusAtomic + airstrikeKills
		--	print(maxClip)
			if activator:IsRealPlayer() == true then
				activator.m_iAmmo[TF_AMMO_PRIMARY] = activator.m_iAmmo[TF_AMMO_PRIMARY] - upgradeLevel
				if activator.m_iAmmo[TF_AMMO_PRIMARY] < 0 then
					--if this call is tripped primary ammo will be negative
					upgradeLevel = upgradeLevel + activator.m_iAmmo[TF_AMMO_PRIMARY]
					activator.m_iAmmo[TF_AMMO_PRIMARY] = 0
					
				end
			end
			primary.m_iClip1 = primary.m_iClip1 + upgradeLevel
			

			if primary.m_iClip1 > maxClip then
				overloadRefundAmount = primary.m_iClip1 - maxClip
				activator.m_iAmmo[TF_AMMO_PRIMARY] = activator.m_iAmmo[TF_AMMO_PRIMARY] + overloadRefundAmount
				primary.m_iClip1 = maxClip

			end
		else
		--print(primary:GetItemName())

			local clipBonusMult = primary:GetAttributeValueByClass("mult_clipsize_upgrade", 1)
			--print("Clip bonus mult: " .. clipBonusMult)


			local maxClip = (BASE_CLIP * 5) * clipBonusMult
		--	print(maxClip)
		
			print(maxClip)

			primary.m_flEnergy = primary.m_flEnergy + (upgradeLevel * 5)
			if primary.m_flEnergy > maxClip then

				primary.m_flEnergy = maxClip

			end
		end	
end