--Used rejuvenator_hit_logic as a base
function directHitHESH(damage, activator, caller)
	
		--stop shrapnel from proccing on rocket jump or weird hits with teammates, or other dynamic entities
		if activator.m_iTeamNum == caller.m_iTeamNum or caller.m_iTeamNum == nil then
			return
		end
		
		--If we got here, we already know that the thing we just hit is not on our team
		--If we just hit a projectile, parry (delete) it
		if caller.m_iClassName == "baseprojectile" then
			caller:Remove()
			return
		end
	
		local rocketang = Vector(0, activator["m_angEyeAngles[1]"], 0)
		local rocketpos
		if caller.m_bIsMiniBoss ~= 0 then
			rocketpos = caller:GetAbsOrigin() + Vector(0, 0, 21.4)
		else
			rocketpos = caller:GetAbsOrigin() + Vector(0, 0, 37.5)
		end	
		
	
		local shrapnelAngOffset = -28.75
		local NUM_MIMICS = 4
	
		--print(rocketpos)
		for i = 1, NUM_MIMICS do
			local shrapnelMimic
			
			local activatorHealOnKill = activator:GetPlayerItemBySlot(0):GetAttributeValue("heal on kill", true) or 0

			shrapnelMimic = ents.CreateWithKeys("tf_point_weapon_mimic", {
				teamnum = activator.m_iTeamNum,
				["$weaponname"] = "SHRAPNEL_GUN",
			})		
			shrapnelMimic["$SetOwner"](shrapnelMimic, activator)
			shrapnelMimic["$AddWeaponAttribute"](shrapnelMimic, "heal on kill|" .. activatorHealOnKill)

			shrapnelMimic:SetAbsOrigin(rocketpos)
			local shrapnelAng = rocketang[2] + shrapnelAngOffset
			if rocketang[2] + shrapnelAngOffset > 180 then
					shrapnelAng = shrapnelAng - 180
			end
			if rocketang[2] + shrapnelAngOffset < -180 then
					shrapnelAng = shrapnelAng + 180
			end			
			shrapnelMimic:SetAbsAngles(Vector(rocketang[1], shrapnelAng, 0))
			shrapnelMimic:FireOnce()
			shrapnelMimic:Remove()
			shrapnelAngOffset = shrapnelAngOffset + 28.75
		end
	
end