local function getRandomBluSpawn()
	local bluSpawns = {}

	for _, teamSpawn in pairs(ents.FindAllByClass("info_player_teamspawn")) do
		if teamSpawn.m_iTeamNum == TEAM_BLUE then
			table.insert(bluSpawns, teamSpawn)
		end
	end

	return bluSpawns[math.random(#bluSpawns)]
end

timer.Simple(0.1, function()
	table.insert(CUSTOM_CANTEENS, {
		Display = "RECALL",
		Attribute = "throwable particle trail only",
		Description = "test",
		Effect = function(activator)
			local chosenSpawn = getRandomBluSpawn()
			print(chosenSpawn)
			activator:SetAbsOrigin(chosenSpawn:GetAbsOrigin())
		end
	})
end)