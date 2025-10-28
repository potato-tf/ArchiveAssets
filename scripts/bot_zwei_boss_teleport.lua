local TELEPORT_NODE_VECTORS = {
	Vector(-1369.48, -1519.8, 2364.99),
	Vector(-1397.15, -1833.78, 2350.39),
	Vector(-1690.76, -1833.99, 2344.98),
	Vector(-1404.74, -2194.65, 2364.48),
	Vector(-1193.95, -2314.07, 2355.18),
	Vector(-520.64, -202.03, 2120.32),
	Vector(-970.57, -228.66, 2120.32),
	Vector(-1202.12, -202.25, 2024.32),
	Vector(-1384.99, -180.67, 2123.32),
	Vector(-1381.29, -526.01, 2123.78),
	Vector(-1171.76, -555.22, 2108.78),
	Vector(-1366.58, -749.93, 2129.64),
	Vector(-1620.82, -736.94, 2116.28),
	Vector(-1005.81, -1044.78, 2264.04),
	Vector(-1348.56, -980.72, 2319.69),
	Vector(-1085.81, -1249.72, 2384.02),
	Vector(-1375, -1252.07, 2384.02),
	Vector(-1732.07, -1249.26, 2367.99),
	Vector(-1656, -1519.95, 2353.97),
	--Vector(-774.64, -1950.38, 2378.81),
	--Vector(-286.67, -1934.41, 2367),
	--Vector(108.89, -1921.46, 2326.43),
	--Vector(385.48, -1191.33, 2424.16),
	--Vector(374.44, -905.09, 2614.62),
	--Vector(96.46, -910.63, 2614.62),
	Vector(-714.7, 265.9, 2372.2),
	Vector(-407.93, 277.83, 2372.2),
	Vector(-1387.38, 349.18, 2052.17),
	Vector(-1387.27, 853.19, 2075.91),
	Vector(-1047.18, 1136.72, 2059.48),
	Vector(-914.14, 1555.04, 2055.48),
	Vector(-295.65, 1202.44, 2055.66),
	Vector(-551.86, 650.71, 2053.93),
	Vector(711, 1803.61, 2137.66),
	Vector(327.48, 1456.28, 2112.54),
	Vector(714.56, 1116.5, 2091.43),
	Vector(181.41, 738.04, 2063.44),
	Vector(647.13, 561, 2129.66),
	Vector(132.45, 419.41, 2185.94),
	--Vector(-299.77, -1050.66, 2363.78),
	Vector(-766.2, -565.81, 2300.14),
	Vector(-1627.4, 142.54, 2300),
	Vector(-331.85, -483.62, 2372.14),
	--Vector(-393.4, -1458.54, 2550),
	--Vector(511.33, -1586.55, 2700),
	Vector(-538.13, -1046.58, 2261.6),
	Vector(-241.82, -156.45, 2120.32),	
}
local TELEPORT_NODE_VECTORS_PREVIEW = {
	Vector(-1397.15, -1833.78, 2296.1),
	Vector(-1690.76, -1833.99, 2296.1),
	Vector(-1404.74, -2194.65, 2296.1),
	Vector(-1193.95, -2314.07, 2296.1),
	Vector(-520.64, -202.03, 2056.93),
	Vector(-970.57, -228.66, 2056.93),
	Vector(-1202.12, -202.25, 2050.32),
	Vector(-1384.99, -180.67, 2050.32),
	Vector(-1381.29, -526.01, 2028.78),
	Vector(-1171.76, -555.22, 2050.32),
	Vector(-1366.58, -749.93, 2050.28),
	Vector(-1620.82, -736.94, 2050.28),
	Vector(-1005.81, -1044.78, 2213.95),
	Vector(-1348.56, -980.72, 2197.83),
	Vector(-1085.81, -1249.72, 2284.13),
	Vector(-1375, -1252.07, 2303.86),
	Vector(-1732.07, -1249.26, 2303.86),
	Vector(-1656, -1519.95, 2296.1),
	Vector(-1369.48, -1519.8, 2296.1),
	--Vector(-774.64, -1950.38, 2378.81),
	--Vector(-286.67, -1934.41, 2367),
	--Vector(108.89, -1921.46, 2326.43),
	--Vector(385.48, -1191.33, 2424.16),
	--Vector(374.44, -905.09, 2614.62),
	--Vector(96.46, -910.63, 2614.62),
	Vector(-714.7, 265.9, 2271.42),
	Vector(-407.93, 277.83, 2271.42),
	Vector(-1387.38, 349.18, 1973.17),
	Vector(-1387.27, 853.19, 1973.17),
	Vector(-1047.18, 1136.72, 1973.17),
	Vector(-914.14, 1555.04, 1973.17),
	Vector(-295.65, 1202.44, 1973.17),
	Vector(-551.86, 650.71, 1973.17),
	Vector(711, 1803.61, 2081.27),
	Vector(327.48, 1456.28, 1995.27),
	Vector(714.56, 1116.5, 1980.27),
	Vector(181.41, 738.04, 1988.44),
	Vector(647.13, 561, 2020.66),
	Vector(132.45, 419.41, 2113.61),
	--Vector(-299.77, -1050.66, 2363.78),
	Vector(-766.2, -565.81, 2144.14),
	Vector(-1627.4, 142.54, 2046.12),
	Vector(-331.85, -483.62, 2106.14),
	--Vector(-393.4, -1458.54, 2550),
	--Vector(511.33, -1586.55, 2700),
	Vector(-538.13, -1046.58, 2066.8),
	Vector(-241.82, -156.45, 2056.93),	
}


--Teleport to all vectors, announce when you have done so
function teleportDiagnostics(_, activator)
	for index, Node in ipairs(TELEPORT_NODE_VECTORS) do	
		--stay at each node for 2 seconds, adds the index to it because these timers will all be spawned within 1 tick.
		timer.Simple((0.5 + (index * 0.5)), function() 
		print("Teleported to " .. index)
		activator:SetAbsOrigin(Node)
		end)
	end
end

local function getTargetTeamAggregatePosition(activator, targetTeamNumPrimary, targetTeamNumSecondary)
			local allPlayers = ents.GetAllPlayers()
			
			--Origin of the boss
			local activatorOrigin = activator:GetAbsOrigin()
			--Table to contain the players
			local targetTeam = {}
			--Closest player to the boss, will be used to determine who the outliers are
			local targetTeamFulcrum
			--Final calculation, the aggregate position of the target team.
			local targetTeamAggregatePosition = Vector(0,0,0)
			
			--Pick out our target players
			for _, player in pairs(allPlayers) do
				if player.m_iTeamNum == targetTeamNumPrimary or player.m_iTeamNum == targetTeamNumSecondary then
					--Necessary because 2 of the three possible teamnum set ups include spec, this also prevents edge-cases
					--where the boss will teleport around dead players.
					if player:IsAlive() == true then
						table.insert(targetTeam, player)
					end
				end
			end	
			--Necessary, because it is possible to get an empty targetTeam table in the event of a teamwipe.
			--This is more graceful than hitting an error when it comes time to pick the fulcrum.
			if next(targetTeam) == nil then
				return nil
			end			
			
			--PrintTable(targetTeam)
			
			--Find whoever is closest to the boss, they will be the base we use to determine outliers
			local lastDistance = 9999
			--print("Determining Fulcrum")
			for _, player in pairs(targetTeam) do
			
				local playerOrigin = player:GetAbsOrigin()
				local playerDistance = playerOrigin:Distance(activatorOrigin)
				
				if playerDistance < lastDistance then
					targetTeamFulcrum = player
					lastDistance = playerDistance
				end
			end
			
			local fulcrumOrigin = targetTeamFulcrum:GetAbsOrigin()
			--print("Fulcrum found, it is " .. targetTeamFulcrum.m_szNetname)
			
			--How many players have been added to the giga vector, if targetTeam is empty you are in deep shit
			local accountedPlayers = 0
			for _, player in pairs(targetTeam) do
				--The fulcrum player themselves will also be factored into this, if they are the only non-outlier then
				--the aggregate will be placed on them, rather than it going to 0,0,0.
				local playerOrigin = player:GetAbsOrigin()
				
				if playerOrigin:Distance(fulcrumOrigin) <= 600 then
					accountedPlayers = accountedPlayers + 1
					targetTeamAggregatePosition[1] = targetTeamAggregatePosition[1] + playerOrigin[1]
					targetTeamAggregatePosition[2] = targetTeamAggregatePosition[2] + playerOrigin[2]
				end
			end

			--Average the position of all non-outliers to get the aggregate position of red team.
			targetTeamAggregatePosition = Vector((targetTeamAggregatePosition[1] / accountedPlayers),(targetTeamAggregatePosition[2] / accountedPlayers),0)
			return targetTeamAggregatePosition

end

--This function will take the provided activator, get an aggregate position of red team, then teleport the activator to a node that is
--minDistanceFromSelf hammer units away from where they are, minDistanceToPlayer hammer units away from the team's aggregated position, 
--bounded by maxDistanceToPlayer hammer units away from the aggregated position of the team. If these three conditions cannot be satisfied,
--no teleportation will occur.
local function snapTeleportAroundPlayers(activator, targetTeamAggregatePosition, minDistanceFromSelf, maxDistanceToPlayer, minDistanceToPlayer, targetTeamNumPrimary, targetTeamNumSecondary)
			--print("It's showtime!")
			local targetTeamAggregatePosition = getTargetTeamAggregatePosition(activator, targetTeamNumPrimary, targetTeamNumSecondary)
			
			local activatorOrigin = activator:GetAbsOrigin()
			
			local activatorOriginNoVertical = Vector(activatorOrigin[1], activatorOrigin[2], 0)
			
			local successfulTeleport = false
			
			
			for index, Node in ipairs(TELEPORT_NODE_VECTORS) do
				local nodeNoVertical = Vector(Node[1], Node[2], 0)
				--print("We are checking node: " .. index)
				local nodeToTeamDistance = nodeNoVertical:Distance(targetTeamAggregatePosition)
				if nodeNoVertical:Distance(activatorOriginNoVertical) >= minDistanceFromSelf and nodeToTeamDistance <= maxDistanceToPlayer and nodeToTeamDistance >= minDistanceToPlayer then
					--print("We have teleported")
					--print("Our selected node's distance from the boss is " .. nodeNoVertical:Distance(activatorOriginNoVertical))
					--print("Our selected node's distance from the team is " .. nodeNoVertical:Distance(targetTeamAggregatePosition))
								
					

					--This will stop the boss from teleporting behind someone and "nothing personal kid"-ing them to the respawn screen					
					activator:SetAttributeValue("no_attack", 1)
					--This does not slow down the boss at all, but it is necessary to stop the boss from teleporting behind someone with a full charge,
					--then instakilling them with a shield bash.
					activator:StunPlayer(1.5, 0.5, TF_STUNFLAG_SLOWDOWN)
					
					--Cosmetic effects begin here
					activator:AddCond(6, 1.5)
					local allPlayers = ents.GetAllPlayers()
					for _, player in pairs(allPlayers) do
						player:AcceptInput("$PlaySoundToSelf", "weapons/teleporter_send.wav")
						player:AcceptInput("$PlaySoundToSelf", "=65|misc/halloween/merasmus_spell.wav")
					end						
					local teleParticle
					local teleParticleBeginning = ents.CreateWithKeys("info_particle_system", {
						effect_name = "wrenchmotron_teleport_beam",
						start_active = 1,
						flag_as_weather = 0,
					}, true, true)
					local teleParticleDestination = ents.CreateWithKeys("info_particle_system", {
						effect_name = "wrenchmotron_teleport_beam",
						start_active = 1,
						flag_as_weather = 0,
					}, true, true)					
					
					--If we're not red, use a blue teleport in effect, because grey does not have one.
					if activator.m_iTeamNum ~= 2 then
						teleParticle = ents.CreateWithKeys("info_particle_system", {
							effect_name = "teleportedin_blue",
							start_active = 1,
							flag_as_weather = 0,
						}, true, true)
						else
						teleParticle = ents.CreateWithKeys("info_particle_system", {
							effect_name = "teleportedin_blue",
							start_active = 1,
							flag_as_weather = 0,
						}, true, true)					
					end
					teleParticle:SetAbsOrigin(Node)
					teleParticle:Start()
					
					teleParticleBeginning:SetAbsOrigin(activatorOrigin)
					teleParticleBeginning:Start()
					
					teleParticleDestination:SetAbsOrigin(Node)
					teleParticleDestination:Start()					
					
					--Cosmetic effects end here
					timer.Simple(1.5, function()
						activator:SetAttributeValue("no_attack", 0)
					end)
					activator:RemoveCond(17)
					activator:SetAbsOrigin(Node)
					successfulTeleport = true
					break
				end
			end
			return successfulTeleport
end

--Function responsible for setting the values of special attacks, returns a table
--that the meta clause within zweiBossTeleLoop then sets the special values to, metaInterval
--becomes a time taken to return to normal.
--Takes the existing teleport parameters and metaInterval so they can be reset later.

--If you were to port this set up to another boss, you could pass activator to directly change the boss'
--attributes or apply conds and whatnot.
local function bossSpecialAttack(specialAttackIndex, minDistanceFromSelf, maxDistanceFromPlayers, minDistanceFromPlayers, teleportInterval, metaInterval)
	if specialAttackIndex < 2 then
		return nil
	end
	--Table the main loop will be handed, goes in the same order as this function's parameters, with the first 5 entries being the changed results
	--and the last 5 entries being the reset results
	local returnTable = {}
	if specialAttackIndex == 2 then
		--very long distance teleport.
		returnTable = {
			400,
			1200,
			600,
			12,
			1,
			minDistanceFromSelf,
			maxDistanceFromPlayers,
			minDistanceFromPlayers,
			teleportInterval,
			metaInterval,
		}
	elseif specialAttackIndex == 3 then
		--teleport panic
		--minimum distance from self is double that as min distance from players
		--to make it much more likely for him to land behind or off to the side of the team.
		--This has extra effects because it is significnatly more dangerous than a longer than usual snap teleport.
		allPlayers = ents.GetAllPlayers()
		for _, player in pairs(allPlayers) do
			player:AcceptInput("$PlaySoundToSelf", "vo/mvm/mght/demoman_mvm_m_battlecry05")
			player:AcceptInput("$PlaySoundToSelf", "weapons/cow_mangler_over_charge_shot.wav")
			player:AcceptInput("$DisplayTextChat", "{FF0000}WARNING: TELEPORT RUSH INCOMING")
		end
		local warnGameText = ents.FindByName("tele_rush_warn_text")
		warnGameText:AcceptInput("Display")
		
		returnTable = {
			300,
			600,
			300,
			1.65,
			5,
			minDistanceFromSelf,
			maxDistanceFromPlayers,
			minDistanceFromPlayers,
			teleportInterval,
			metaInterval,
		}	
	end
	
	return returnTable
	
end

function zweiBossTeleLoop(_, activator)

	local callbacks = {}

	local check

	local terminated = false
	
	--We have two teamnum vars because grey team exists, despite the naming convention, one does not take priority over the other.
	--Though it will be listed first in the teleport function to short circuit the AND logic and make the perf impact of its existence
	--slightly less significant, though it is barely existent as-is. If you are rewriting this and will be using more greys than reds or blues as enemies,
	--it might be wise to flip them for that reason. I would not recommend using greys as the main enemy to begin with, but that's your bad decision to make.
	local targetTeamNumPrimary
	
	local targetTeamNumSecondary
	
	--If we're red, our primary target is blue, and our secondary is grey
	if activator.m_iTeamNum == 2 then
		targetTeamNumPrimary = 3
		targetTeamNumSecondary = 1
	--If we're blue, our primary target is red, and our secondary is grey.
	elseif activator.m_iTeamNum == 3 then
		targetTeamNumPrimary = 2
		targetTeamNumSecondary = 1
	--If we're grey or the fucky halloween team, if that ever gets supported, blue is our primary and red is our secondary.
	--Blue is the primary because in most missions there will be more blues than reds in a given server.
	else
		targetTeamNumPrimary = 3
		targetTeamNumSecondary = 2
	end
	
	--These are variables rather than hard constants so they can be manipulated by the boss' phases	and special attacks
	--Interval between teleports, pre teleport warning occurs 1.6 seconds before this, and never occurs if the interval is less than that
	local teleportInterval = 6
	--Interval between special attacks
	local metaInterval = 6
	
	local minDistanceFromSelf = 200
	
	local maxDistanceFromPlayers = 600	
	
	local minDistanceFromPlayers = 200
	
	--I had this updating once every tick, this caused a particle leak that crashes both all clients and the server.
	local previewRefreshInterval = 0.75
	
	--Evaluated here so changing the boss' health is not a pain in the ass.
	local phaseTwoHealthBreakpoint = activator.m_iHealth * (2/3)
	
	local phaseThreeHealthBreakpoint = activator.m_iHealth * (1/3)
	
	--This variable is set to the phase number that the boss has recently changed to, in order
	--to prevent those clauses from spamming over potential alterations made by meta effects and what not.
	--Is also used to determine which special attack to use.
	local phaseUpdateComplianceLevel = 0
	
	--This table is filled in by special attacks, first 5 entries are the new stats, last 5
	--are the old stats.
	local specialAttackTable = {}
	
	--Flag used to determine which section of the special attack table to reference.
	local metaReturnsToNormal = false
	
	--Multiplier applied to teleportInterval if the red fulcrum is more than a certain distance away from the boss
	local teleportIntervalDistanceMultiplier = 1


	local function terminate()
		if terminated then
			return
		end

		terminated = true

		timer.Stop(check)
		removeCallbacks(activator, callbacks)

	end
	--This is a flag to stop the early teleport warning from earraping the players
	local timeIntervalBucketWarningHeard = false
	
	--Used when deciding to teleport, usually every 4-5 seconds, possibly longer.
	local timeIntervalBucket = 0
	--Used when choosing to perform special attacks that would compromise the integrity of timeIntervalBucket, like a teleport fever
	--that changes teleportInterval to 0.5
	local timeIntervalBucketMeta = 0
	
	--Used to determine when to preview the boss' teleports
	local timeIntervalBucketPreview = 0
	
	--Multiplies maxDistanceFromPlayers, if many consecutive failed teleports occur, this will eventually force the boss
	--to teleport away.
	local failedTeleportDistanceMultiplier = 1

	check = timer.Create(0.015, function()

		if not IsValid(activator) or not activator:IsAlive() then
			terminate()
			return
		end
		--Management if statement for phases
		if phaseUpdateComplianceLevel < 2 and activator.m_iHealth <= phaseTwoHealthBreakpoint then
			--More frequent, further teleports that are more likely to land at side and back angles
			print("We are at phase 2")
			minDistanceFromSelf = 400
			maxDistanceFromPlayers = 800
			minDistanceFromPlayers = 300
			teleportInterval = 5.5
			metaInterval = 8
			phaseUpdateComplianceLevel = 2
			
		elseif phaseUpdateComplianceLevel < 3 and activator.m_iHealth <= phaseThreeHealthBreakpoint then
			--Bold, very frequent teleports that are more likely to snap the boss a short distance away.
			--Special attack cooldown is longer because it is very significant.
			print("We are at phase 3")
			minDistanceFromSelf = 300
			maxDistanceFromPlayers = 500
			minDistanceFromPlayers = 200
			teleportInterval = 4.5
			metaInterval = 15		
			phaseUpdateComplianceLevel = 3
		end
		
		
		timeIntervalBucket = timeIntervalBucket + 0.015
		timeIntervalBucketMeta = timeIntervalBucketMeta + 0.015
		timeIntervalBucketPreview = timeIntervalBucketPreview + 0.015
		--print(timeIntervalBucket)
		if (teleportInterval - timeIntervalBucket) <= 1.6 and timeIntervalBucketWarningHeard == false then
			--If we are teleporting fast enough that there isn't room for the teleporter sound, we don't need to hear it.
			if teleportInterval - timeIntervalBucket > 0 then
				local allPlayers = ents.GetAllPlayers()
				activator:AddCond(6, 1)
				--amputator ring effect, for added visual clarity
				activator:AddCond(20, 0.75)
				for _, player in pairs(allPlayers) do
					player:AcceptInput("$PlaySoundToSelf", "weapons/teleporter_ready.wav")
					timer.Simple(0.5, function()
						player:AcceptInput("$PlaySoundToSelf", "weapons/det_pack_timer.wav")
					end)
					timer.Simple(1, function()
						player:AcceptInput("$PlaySoundToSelf", "weapons/det_pack_timer.wav")
					end)
					timer.Simple(1.5, function()
						player:AcceptInput("$PlaySoundToSelf", "weapons/det_pack_timer.wav")
					end)					
					--player:AcceptInput("$PlaySoundToSelf", "weapons/teleporter_receive.wav")
				end	
			end
			
			timeIntervalBucketWarningHeard = true
		end
		
		if timeIntervalBucket >= (teleportInterval - 0.8) then		
			--print(teleportInterval)
			timeIntervalBucket = 0
			timeIntervalBucketWarningHeard = false
			
			--If our teleports are slower than 1.2 seconds, spend some time doing a cool sword draw and swing animation
			--before we teleport, otherwise, just teleport without it
			if teleportInterval - 0.8 > 1 then
			print("Long teleport")
			activator:SetAttributeValue("deploy time increased", 0.01)
			
			activator:WeaponSwitchSlot(2)
			activator:RunScriptCode("activator.PressFireButton(1)", activator)
			activator:SetAttributeValue("disable weapon switch", 1)			
			
			timer.Simple(0.2, function()
				activator:RunScriptCode("activator.PressFireButton(1)", activator)
				activator:SetAttributeValue("gesture speed increase", 0.1)
				activator:SetAttributeValue("fire rate bonus", 10)			
			end)			
			
			timer.Simple(0.8, function()
				activator:SetAttributeValue("disable weapon switch", 0)
				activator:SetAttributeValue("fire rate bonus", 1)
				activator:SetAttributeValue("gesture speed increase", 1)
				activator:SetAttributeValue("deploy time increased", 1)
				local targetTeamAggregatePosition = getTargetTeamAggregatePosition(activator, targetTeamNumPrimary, targetTeamNumSecondary)			
				local teleportSuccess = snapTeleportAroundPlayers(activator, targetTeamAggregatePosition, minDistanceFromSelf, (maxDistanceFromPlayers * failedTeleportDistanceMultiplier), minDistanceFromPlayers, targetTeamNumPrimary, targetTeamNumSecondary)
				if not teleportSuccess then
					failedTeleportDistanceMultiplier = failedTeleportDistanceMultiplier + 2
					else
					failedTeleportDistanceMultiplier = 1
				end
				timeIntervalBucket = 0
			end)
			
			else
				print("Short teleport")
				print(teleportInterval - 0.8)
				timer.Simple(0.8, function()
					local targetTeamAggregatePosition = getTargetTeamAggregatePosition(activator, targetTeamNumPrimary, targetTeamNumSecondary)			
					local teleportSuccess = snapTeleportAroundPlayers(activator, targetTeamAggregatePosition, minDistanceFromSelf, (maxDistanceFromPlayers * failedTeleportDistanceMultiplier), minDistanceFromPlayers, targetTeamNumPrimary, targetTeamNumSecondary)
					if not teleportSuccess then
						failedTeleportDistanceMultiplier = failedTeleportDistanceMultiplier + 1
						else
						failedTeleportDistanceMultiplier = 1
					end
					timeIntervalBucket = 0
				end)
			end			
			
		end
		
		--If we've hit our meta interval, either revert to normal or call upon our special attack teleport params, if we have no special attack params for this phase, do nothing.
		if timeIntervalBucketMeta >= metaInterval then
			timeIntervalBucketMeta = 0
			if metaReturnsToNormal == true then
				--metaReturnsToNormal will never be true if specialAttackTable is nil, 
				--this is because it is only ever set to true if the table was valid to begin with.
				--No nil safety check needed here.
				minDistanceFromSelf = specialAttackTable[6]
				maxDistanceFromPlayers = specialAttackTable[7]
				minDistanceFromPlayers = specialAttackTable[8]
				teleportInterval = specialAttackTable[9]
				metaInterval = specialAttackTable[10]	
				
				metaReturnsToNormal = false
			else
				--We need to check if metaReturnsToNormal is true before we do this so special attack values do not permanently corrupt normal values.
				specialAttackTable = bossSpecialAttack(phaseUpdateComplianceLevel, minDistanceFromSelf, maxDistanceFromPlayers, minDistanceFromPlayers, teleportInterval, metaInterval)
				if specialAttackTable ~= nil then
					minDistanceFromSelf = specialAttackTable[1]
					maxDistanceFromPlayers = specialAttackTable[2]
					minDistanceFromPlayers = specialAttackTable[3]
					teleportInterval = specialAttackTable[4]
					metaInterval = specialAttackTable[5]
					
					metaReturnsToNormal = true
				end
			end
		end
		
		if timeIntervalBucketPreview >= previewRefreshInterval then
			timeIntervalBucketPreview = 0
			
			local activatorOrigin = activator:GetAbsOrigin()
			local activatorOriginNoVertical = Vector(activatorOrigin[1], activatorOrigin[2], 0)
			
			local targetTeamAggregatePosition = getTargetTeamAggregatePosition(activator, targetTeamNumPrimary, targetTeamNumSecondary)
			
			--print(targetTeamAggregatePosition[1] .. " " .. targetTeamAggregatePosition[2] .. " " .. targetTeamAggregatePosition[3])
			print(targetTeamAggregatePosition:Distance(activatorOriginNoVertical))
			if targetTeamAggregatePosition:Distance(activatorOriginNoVertical) > 1200 and timeIntervalBucketWarningHeard == false then
				if (timeIntervalBucket * 2) >= (teleportInterval - 1.6) then
					timeIntervalBucket = teleportInterval - 1.6
					print("Snapped to preview")
				elseif timeIntervalBucketWarningHeard == false then
					timeIntervalBucket = timeIntervalBucket * 2
					print("Doubled")
				end
			end
			print(timeIntervalBucket)			
			for index, Node in ipairs(TELEPORT_NODE_VECTORS_PREVIEW) do
					local nodeNoVertical = Vector(Node[1], Node[2], 0)
					if targetTeamAggregatePosition ~= nil then
						local nodeToTeamDistance = nodeNoVertical:Distance(targetTeamAggregatePosition)
						
						if nodeNoVertical:Distance(activatorOriginNoVertical) >= minDistanceFromSelf and nodeToTeamDistance <= (maxDistanceFromPlayers * failedTeleportDistanceMultiplier) and nodeToTeamDistance >= minDistanceFromPlayers then	
								local nodeOriginRetardedSyntax = "" .. Node[1] .. " " .. Node[2] .. " " .. Node[3] .. ""
								local teleWarnParticle = ents.CreateWithKeys("prop_dynamic",{
									["disableshadows"] = "1",
									["model"] = "models/props_mvm/indicator/indicator_circle.mdl",
									["defaultanim"] = "start",
									--["model"] = "models/bots/scout_boss/bot_scout_boss.mdl",
									["origin"] = nodeOriginRetardedSyntax,
									["modelscale"] = 1.75,
									["skin"] = 1,
								})
								local teleWarnParticle1 = ents.CreateWithKeys("info_particle_system", {
									effect_name = "medic_healradius_blue_buffed",
									start_active = 1,
									flag_as_weather = 0,
								}, true, true)
								teleWarnParticle1:SetAbsOrigin(Node)
								teleWarnParticle1:Start()								
								
								--print(teleWarnParticle:GetAbsOrigin())
								
								timer.Simple(previewRefreshInterval, function()
									teleWarnParticle:Remove()
									teleWarnParticle1:Remove()
								end)					
						end
					end
			end
		end
		
		
	end, 0)	
	
	
	callbacks.died = activator:AddCallback(ON_DEATH, function()
		terminate()
	end)
	callbacks.removed = activator:AddCallback(ON_REMOVE, function()
		terminate()
	end)
	callbacks.spawned = activator:AddCallback(ON_SPAWN, function()
		terminate()
	end)	
end

function debugAttack()
	print("I attacked")
end