AddEventCallback("player_death", function(eventTable)
	--PrintTable(eventTable)
	
		local attacker = ents.GetPlayerByUserId(eventTable.attacker)
		
		if not attacker then
			--print("gave up")
			return
		end
		
		local victim = ents.GetPlayerByUserId(eventTable.userid)
		
		if victim.m_iTeamNum == 1 and victim.m_bIsMiniBoss == 1 and attacker.m_iTeamNum == 2 then
				for _, player in pairs(ents.GetAllPlayers()) do
						if player.m_iTeamNum == 2 then
							player:Print(PRINT_TARGET_CENTER, "YOUR TEAM HAS KILLED A GREY GIANT. YOU ARE BEING BUFFED FOR THE NEXT 12 SECONDS")
							player:AddCond(16, 12, attacker)
							player:AddCond(26, 12, attacker)
							player:AddCond(29, 12, attacker)
						end						
				end	
		end
end)