--Used rejuvenator_hit_logic as a base
function manmelterExtinguish(damage, activator, caller)

		if not caller:IsPlayer() then
			return
		end
	
		--don't do anything to teammates
		--checked before the afterburn check as a failsafe in case it actually lights a teammate
		if activator.m_iTeamNum == caller.m_iTeamNum then
			print("we hit an ally")
			
			if caller:InCond(22) then
				print("extinguishing ally")
				caller:AddHealth(damage, false)
				caller:RemoveCond(22)
				activator.m_iRevengeCrits = activator.m_iRevengeCrits + 1
				activator:GetPlayerItemBySlot(1):SetAttributeValue("add cond when active", 11)
				--refund crits used to extinguish teammates
				if damage >= 90 then
					activator.m_iRevengeCrits = activator.m_iRevengeCrits + 1
				end
			end
			return
		end
		
		--to stop afterburn from auto extinguishing or making them burn forever
		if not caller:InCond(22) then
			--print("ignite")
			caller:IgnitePlayer(7.5, activator)
			return
		end		
			
		
		--implicitly calls incond
		caller:RemoveCond(22)
		--print("give revenge")
		activator.m_iRevengeCrits = activator.m_iRevengeCrits + 1
		activator:GetPlayerItemBySlot(1):SetAttributeValue("add cond when active", 11)
	
end
function manmelterUnfuckCrit(activator, projectile, self)
	
		--print(projectile)
		--print(self)
		if projectile.m_iRevengeCrits > 1 then
			--print("More than one crit ready")
			activator.m_bCritical = 1
		elseif projectile.m_iRevengeCrits == 1 then
			activator.m_bCritical = 1 --just in case
			--print("Final crit fired")
			self:SetAttributeValue("add cond when active", nil)
		else
			--print("No crits left")
			self:SetAttributeValue("add cond when active", nil)
		end
	
end