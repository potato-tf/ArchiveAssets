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


function MagSpyTargettedShot(_, activator)

		local callbacks = {}

		local check

		local attackTarget = nil	

		local terminated = false
	
		local originalPrimaryAttributes = {}
	
		local primary = activator:GetPlayerItemBySlot(1)
	
		local tickCounter = 0
	
		local ATTACK_COOLDOWN_DURATION = 15	
	
		local cooldownCounter = ATTACK_COOLDOWN_DURATION / 0.015
	
		local TIME_TILL_OBLITERATION = 6
	
		local doingAttack = false

		local function terminate()
			if terminated then
				return
			end

			terminated = true

			timer.Stop(check)
			removeCallbacks(activator, callbacks)

		end

		local function checkLineOfSight(activator, caller)
		if not util.IsLagCompensationActive() then
		util.StartLagCompensation(activator)	
		end
		--thanks mince for the 
		local callerHead = caller:GetAbsOrigin() + Vector(0, 0, caller["m_vecViewOffset[2]"]);
		local traceAngles = (callerHead - (activator:GetAbsOrigin() + Vector(
				0,
				0,
				activator["m_vecViewOffset[2]"]
			))):ToAngles()
			traceAngles = Vector(traceAngles[1], traceAngles[2], 0)		
		
		
			local TraceLineOfSight = {
				start = activator, -- Start position vector. Can also be set to entity, in this case the trace will start from entity eyes position
				distance = 10000, -- Used if endpos is nil
				angles = traceAngles, -- Used if endpos is nil
				mask = MASK_SOLID, -- Solid type mask, see MASK_* globals
				collisiongroup = COLLISION_GROUP_PLAYER, -- Pretend the trace to be fired by an entity belonging to this group. See COLLISION_GROUP_* globals
			}
			local lineOfSightTraceTable = util.Trace(TraceLineOfSight)
				--PrintTable(lineOfSightTraceTable)
				--print(lineOfSightTraceTable.HitPos)
				if lineOfSightTraceTable.Hit == true and lineOfSightTraceTable.HitWorld == false then
			
					--print("Enemy is in our line of sight")
					return true			

					else
			
					--print("Enemy is not in our line of sight")
					return false
			
				end
		end	
	
				
		
		check = timer.Create(0.015, function()
			if not IsValid(activator) then
				terminate()
				return
			end	
			if doingAttack == false then
				cooldownCounter = cooldownCounter - 1
				if cooldownCounter < 0 then
					cooldownCounter = 0
				end	
				--print(cooldownCounter)
			end	
		
		--Find all players within 1250 units of the activator
		local botLocation = activator:GetAbsOrigin()
		local sphereResults = ents.FindInSphere(botLocation, 1250)
		local lastEntry
		if activator.m_iHealth < 26667 then
			ATTACK_COOLDOWN_DURATION = 8	
			TIME_TILL_OBLITERATION = 4	
		end		
		
			if sphereResults and cooldownCounter <= 0 then
				for _, entity in pairs(sphereResults) do
						if entity:IsPlayer() and entity.m_iTeamNum ~= activator.m_iTeamNum and entity ~= lastEntry and entity:GetPlayerName() ~= "Demo-Bot" then
									if not entity:InCond(4) and not entity:InCond(3) and not entity:InCond(66) then --so spies don't get assblasted
											lastEntry = entity
											--print("Found a valid enemy")
											if not IsValid(attackTarget) then
												attackTarget = lastEntry
												print("Designated new attack target")
												print(attackTarget:GetPlayerName())
											end
									end
						end
				end	
				if IsValid(attackTarget) and doingAttack == true then
						if checkLineOfSight(activator, attackTarget) == false then
							print("Lost sight of target")
							primary:SetAttributeValue("no_attack", 0) --Only fire when I let you
							
							attackTarget:Print(PRINT_TARGET_CENTER, "")
							attackTarget = nil
							tickCounter = 0							
							activator:RemoveCond(34)
							originalPrimaryAttributes = {}
							cooldownCounter = ATTACK_COOLDOWN_DURATION / 0.015
							primary:SetAttributeValue("custom weapon fire sound", "mag_deagle_shot.wav")
							primary:SetAttributeValue("damage bonus", nil) --you will die if it hits you, to put it lightly	
							for name, value in pairs(originalPrimaryAttributes) do
								primary:SetAttributeValue(name, value)
							end	
							originalPrimaryAttributes = {}	
							doingAttack = false
							
							return
						end
					else
					doingAttack = false
				end			
				
					--PrintTable(filteredSphereResults)
					if IsValid(attackTarget) and checkLineOfSight(activator, attackTarget) == true then 
						if #table.GetKeys(originalPrimaryAttributes) == 0 then
							originalPrimaryAttributes = primary:GetAllAttributeValues(true)
							activator:PlaySound("commander_warning.wav")
						end	
						activator:AddCond(34, 999, activator)
						primary:SetAttributeValue("no_attack", 1) --Only fire when I let you
					
						doingAttack = true
						
						tickCounter = tickCounter + 1
						local timeRemaining = TIME_TILL_OBLITERATION - (tickCounter * 0.015)	
						--print(timeRemaining)
					
						attackTarget:Print(PRINT_TARGET_CENTER, "YOU WILL BE INSTAKILLED IF YOU DO NOT SEEK COVER\n ".. timeRemaining)
						
						--This is taken from build_ally_bot.lua, by royal. Mince was thanked in the original comment that appeared with this.
						local lastEntryHead = Vector(attackTarget:GetAbsOrigin()[1],attackTarget:GetAbsOrigin()[2],attackTarget:GetAbsOrigin()[3] + 60)
						local targetAngles = (lastEntryHead - (activator:GetAbsOrigin() + Vector(
									0,
									0,
									activator["m_vecViewOffset[2]"]
								))):ToAngles()
								targetAngles = Vector(targetAngles[1], targetAngles[2], 0)
							activator:SnapEyeAngles(targetAngles)
							--print("Aim")
					
							if timeRemaining <= 0 and attackTarget:IsValid() and attackTarget:IsAlive() then
								primary:SetAttributeValue("no_attack", 0) --Only fire when I let you
								primary:SetAttributeValue("custom weapon fire sound", "mag_deagle_shot_mega.wav")
								primary:SetAttributeValue("damage bonus", 9999) --you will die if it hits you, to put it lightly
								
								attackTarget:Print(PRINT_TARGET_CENTER, "YOUR DEATH IS IMMINENT")
								activator:RunScriptCode("activator.PressFireButton(0.1)", activator)
								--print("Fired Weapon")
								--print(attackTarget:GetPlayerName())
							end
					end
				else
					if IsValid(attackTarget) then
					attackTarget:Print(PRINT_TARGET_CENTER, "")
					end
					attackTarget = nil
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