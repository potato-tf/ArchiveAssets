--Script made by Therealscroob/Crilly, this script's goal is to get blast soldiers with the reserve shooter to pull out their 
--reserve shooter to attack targets airborne targets

local function removeCallbacks(player, callbacks)
	if not IsValid(player) then
		return
	end

	for _, callbackId in pairs(callbacks) do
		player:RemoveCallback(callbackId)
	end
end

function ReserveCombo(_, activator)

		local callbacks = {}

		local check

		local terminated = false
	
		local secondary = activator:GetPlayerItemBySlot(1) 

		local function terminate()
			if terminated then
				return
			end

			terminated = true

			timer.Stop(check)
			removeCallbacks(activator, callbacks)

		end
		
		check = timer.Create(0.015, function()
			if not IsValid(activator) or not IsValid(secondary) then
				terminate()
				return
			end	
		
		--Find all players within 1000 units of the activator, may be decreased due to how low the reserve shooter's damage is at range
		--this would be a nice base for a potential master AI script.
		local botLocation = activator:GetAbsOrigin()
		local sphereResults = ents.FindInSphere(botLocation, 1000)
		local filteredSphereResults = {}
		local lastEntry
		
			if sphereResults then
				for _, entity in pairs(sphereResults) do
						if entity:IsPlayer() and entity.m_iTeamNum ~= activator.m_iTeamNum and entity ~= lastEntry then
								if entity:InCond(81) or entity:InCond(98) or entity:InCond(99)  or entity:InCond(125)then
									if not entity:InCond(4) and not entity:InCond(3) and not entity:InCond(66) then --so spies don't get assblasted
											table.insert(filteredSphereResults, entity)
											lastEntry = entity
										end
								end
						end
				end
					--PrintTable(filteredSphereResults)
					if filteredSphereResults and lastEntry then
								activator:WeaponSwitchSlot(1)
								secondary:SetAttributeValue("disable weapon switch", 1)		
						
						--This is taken from build_ally_bot.lua, by royal. Mince was thanked in the original comment that appeared with this.
						local targetAngles = (lastEntry:GetAbsOrigin() - (activator:GetAbsOrigin() + Vector(0,0,activator["m_vecViewOffset[2]"]))):ToAngles()
							targetAngles = Vector(targetAngles[1], targetAngles[2], 0)
							activator:SnapEyeAngles(targetAngles)
							--print("Aim")
							
							activator:RunScriptCode("activator.PressFireButton(0.01)", activator)
						else
								secondary:SetAttributeValue("disable weapon switch", 0)		
								activator:WeaponSwitchSlot(0)								
						end
			else
				return
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