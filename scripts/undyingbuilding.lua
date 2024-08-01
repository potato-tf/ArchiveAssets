--excerpt from royal's undying runner code, customized to work for buildings with major assistance from seelpit

ents.AddCreateCallback("obj_dispenser", function(entity, classname)	
	timer.Simple(0, function()
		if not IsValid(entity) then
			return
		end
		local name = entity:GetName()
	--	util.PrintToChatAll("Dispenser name: "..name)
	--enormous if statement needed because tf_glow is a piece of shit
		if name == "objective1_1" or name == "objective1_2" or name == "objective1_3" or name == "objective1_4" or name == "objective1_0"  then
		UndyingBuildingSpawn(entity)
		globalDispenserCount = 5			
		end
		if name == "sideObjective" then		
		UndyingSentrySpawn(entity)			
		end					
	end)
end)

ents.AddCreateCallback("obj_sentrygun", function(entity, classname)	
	timer.Simple(0, function()
		if not IsValid(entity) then
			return
		end
		local name = entity:GetName()
	--	util.PrintToChatAll("Dispenser name: "..name)
	--enormous if statement needed because tf_glow is a piece of shit
		if name == "sideObjective" then
		UndyingSentrySpawn(entity)			
		end
	end)
end)

local 	function killGlow(activator)
	local targetString = activator:GetName() .. "_glow"
	--print(targetString)
		if targetString == "objective1_3_glow" then
		--done shields is two ents, so this needs to be ran twice.
			local DoneShieldsRemover = ents.FindByName("DoneShieldsRemover")
			DoneShieldsRemover:AcceptInput("Trigger")
		
			local allPlayers = ents.GetAllPlayers()
			for _, player in pairs(allPlayers) do	   
				player:AcceptInput("$PlaySoundToSelf", "ambient/energy/zap9.wav")
			end
		return
		end	
	local glowEnt = ents.FindByName(targetString)	
		--print(IsValid(glowEnt))	
		if IsValid(glowEnt) then
			glowEnt:AcceptInput("Kill")
			--print("Glow murdered")
		end
	return
end


function UndyingBuildingSpawn(activator)
	
local invulnStatus = false	
	
local curHealth = activator.m_iHealth
	
local allPlayers = ents.GetAllPlayers()	
	
local check
	
check = timer.Create(0.5, function()	
		if not IsValid(activator) then
			timer.Stop(check)
			return	
		end
		curHealth = activator.m_iHealth	
			if curHealth > 2 then
				if activator:GetName() == "objective1_2" and globalDispenserCount > 4 then
				activator:AcceptInput("RemoveHealth", curHealth - 2, nil, nil, 0)

				activator.m_lifeState = 1
					print("Fuck off yeloz")
				
				elseif activator:GetName() == "objective1_4" and globalDispenserCount > 3 then
				activator:AcceptInput("RemoveHealth", curHealth - 2, nil, nil, 0)

				activator.m_lifeState = 1
					print("Fuck off yeloz")
				
				elseif activator:GetName() == "objective1_1" and globalDispenserCount > 2 then
				activator:AcceptInput("RemoveHealth", curHealth - 2, nil, nil, 0)

				activator.m_lifeState = 1
					print("Fuck off yeloz")
				
				elseif activator:GetName() == "objective1_3" and globalDispenserCount > 0 then
				activator:AcceptInput("RemoveHealth", curHealth - 2, nil, nil, 0)	

				activator.m_lifeState = 1
					print("Fuck off yeloz")
				end		
			end	
		--print(curHealth)		
			
				if curHealth == 2000 and invulnStatus == false then
					invulnStatus = true
					activator.m_lifeState = 1
					globalDispenserCount = globalDispenserCount - 1
					--print("do the thing")
					killGlow(activator)
					
					message = "{AAAAFF}GIGA DISPENSER {22FF22}ONLINE: {EEEE33}".. globalDispenserCount .. " {AAAAFF}LEFT, {EEEE33}FORCEFIELD DOWN."
					if globalDispenserCount == 4 then
					
						local objective1Start = ents.FindByName("objective1Start")

						objective1Start:FireOutput("OnTrigger", "", nil, 0) 

						for _, player in pairs(allPlayers) do	   
							player:AcceptInput("$PlaySoundToSelf", "ambient/energy/zap9.wav")
						end
					
					end	
					if globalDispenserCount == 3 then
					
					local objective1StartHalf = ents.FindByName("objective1StartHalf")

					objective1StartHalf:FireOutput("OnTrigger", "", nil, 0) 
					
					message = "{AAAAFF}GIGA DISPENSER {22FF22}ONLINE: {EEEE33}".. globalDispenserCount .. " {AAAAFF}LEFT, {EEEE33}FOLLOW TANK HOLOGRAM"

					for _, player in pairs(allPlayers) do	   
						player:AcceptInput("$PlaySoundToSelf", "ambient/energy/zap9.wav")
					end
					
					end					
					if globalDispenserCount == 2 then
					
						local objective1HalfDone = ents.FindByName("objective1HalfDone")

						objective1HalfDone:FireOutput("OnTrigger", "", nil, 0) 

						for _, player in pairs(allPlayers) do	   
							player:AcceptInput("$PlaySoundToSelf", "ambient/energy/zap9.wav")
						end						
					end	
				
					if globalDispenserCount == 1 then
					
						local objective1Final = ents.FindByName("objective1Final")

						objective1Final:FireOutput("OnTrigger", "", nil, 0) 
					
						message = "{EEEE33}FORCEFIELD DOWN. {AAAAFF}FINAL GIGA DISPENSER{FF2222} ENCLOSED IN SHIELD{AAAAFF} {FFAAAA}DESTROY ENEMY CHIEF"

						for _, player in pairs(allPlayers) do	   
							player:AcceptInput("$PlaySoundToSelf", "ambient/energy/zap9.wav")
						end						
					end
					
					if globalDispenserCount == -1 then
					local objective1Done = ents.FindByName("objective1Done")
					
						message = "{AAAAFF}GIGA DISPENSER ARRAY {22FF22}FULLY OPERATIONAL, {EEEE33}VICTORY."
						
						objective1Done:FireOutput("OnTrigger", "", nil, 0) 
						end
						
						--I wasn't smart enough to do this alone, I located this in timeconstraint_boss.lua
						for _, player in pairs(allPlayers) do	   --another script done by Royal, to my knowledge
							player:AcceptInput("$DisplayTextChat", message)
							player:AcceptInput("$PlaySoundToSelf", "weapons/sentry_finish.wav")
						--I just looked up what in pairs does, I now kind of feel like an idiot for not understanding how to write this
						--on my own.
					end	
			end				
			
end, 0)			
	
	activator:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageInfo)
		-- just in case
		if not activator:IsAlive() then
			return
		end
		
		curHealth = activator.m_iHealth	
			
		local damage = damageInfo.Damage
		--buildings can't get crit, don't need to check for that.		

		--If the incoming damage is lethal, set our health to 1 instead.
		if curHealth - (damage + 1) <= 0 and curHealth ~= 1 and damageInfo.Attacker.m_iTeamNum ~= activator.m_iTeamNum and invulnStatus == false  then
			damageInfo.Damage = 0
			damageInfo.DamageType = DMG_GENERIC
				-- set health to 1
				local setHealthDmgInfo = {
					Attacker = damageInfo.Attacker,
					Inflictor = damageInfo.Inflictor,
					Weapon = damageInfo.Weapon,
					Damage = curHealth - 2,
					CritType = 0,
					DamageType = damageInfo.DamageType,
					DamageCustom = damageInfo.DamageCustom,
					DamagePosition = damageInfo.DamagePosition,
					DamageForce = damageInfo.DamageForce,
					ReportedPosition = damageInfo.ReportedPosition,
				}
				activator:TakeDamage(setHealthDmgInfo)

				activator.m_lifeState = 1
				return true
		end
		--Make ourselves invincible at 2000 health
		if curHealth == 2000 then
			--print ("I'm fuckin invincible!")
			damageInfo.Damage = 0
			damageInfo.DamageType = DMG_GENERIC
			activator.m_lifeState = 1	
				
				return true
		end
		
		return true
	end)
	function ResetGigaDispCount()
		
	globalDispenserCount = 5	
		
	return	
	end	
	function DecrementGigaDispCount()
		
	globalDispenserCount = globalDispenserCount - 1	
	for _, player in pairs(allPlayers) do	   --another script done by Royal, to my knowledge
		player:AcceptInput("$DisplayTextChat", "{EEEE33}CHIEF DESTROYED,{AAAAFF}FINAL GIGA DISPENSER: {22FF22}REPAIRABLE ")
		end				
	alreadyFired = true		
		
	return	
	end	
end

function UndyingSentrySpawn(activator)
	
local activeStatus = false	
activator.m_bDisabled = 1	
	
local curHealth = activator.m_iHealth
		
local check
	
check = timer.Create(0.5, function()	
		if not IsValid(activator) then
			timer.Stop(check)
			return	
		end			
		curHealth = activator.m_iHealth
		--print(curHealth)		
			
				if curHealth == 500 then
					if activeStatus == false then
						activator:PlaySound("weapons/sentry_finish.wav")
					end
					activeStatus = true
					activator.m_bDisabled = 0
					activator.m_lifeState = 0
				end				
			
end, 0)			
	
	activator:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageInfo)
		-- just in case
		if not activator:IsAlive() then
			return
		end
		
		curHealth = activator.m_iHealth	
			
		local damage = damageInfo.Damage
		--buildings can't get crit, don't need to check for that.		

		--If the incoming damage is lethal, set our health to 1 instead.
		if curHealth - (damage + 1) <= 0 and curHealth ~= 1 and damageInfo.Attacker.m_iTeamNum ~= activator.m_iTeamNum then
			damageInfo.Damage = 0
			damageInfo.DamageType = DMG_GENERIC
				-- set health to 1
				local setHealthDmgInfo = {
					Attacker = damageInfo.Attacker,
					Inflictor = damageInfo.Inflictor,
					Weapon = damageInfo.Weapon,
					Damage = curHealth - 2,
					CritType = 0,
					DamageType = damageInfo.DamageType,
					DamageCustom = damageInfo.DamageCustom,
					DamagePosition = damageInfo.DamagePosition,
					DamageForce = damageInfo.DamageForce,
					ReportedPosition = damageInfo.ReportedPosition,
				}
				activator:TakeDamage(setHealthDmgInfo)
					if activeStatus == true then
						activator:PlaySound("weapons/sentry_damage4.wav")
					end				
				activeStatus = false
				activator.m_bDisabled = 1
				activator.m_lifeState = 1
				
				return true
		end
	end)
end