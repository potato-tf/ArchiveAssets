--Used rejuvenator_hit_logic as a base
function directHitHESH(damage, activator, caller)
	
		--stop shrapnel from proccing on rocket jump or weird hits with teammates
		if activator.m_iTeamNum == caller.m_iTeamNum then
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

			if activator:GetPlayerItemBySlot(0):GetAttributeValue("rocket specialist", true) == 1 then
			shrapnelMimic = ents.CreateWithKeys("tf_point_weapon_mimic", {
				teamnum = activator.m_iTeamNum,
				["$weaponname"] = "SHRAPNEL_GUN_ROCKETSPEC",
			})
			else
			shrapnelMimic = ents.CreateWithKeys("tf_point_weapon_mimic", {
				teamnum = activator.m_iTeamNum,
				["$weaponname"] = "SHRAPNEL_GUN",
			})		
			end
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