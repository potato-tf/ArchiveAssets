AddEventCallback("player_hurt", function(eventTable)
	--PrintTable(eventTable)
	
		local attacker = ents.GetPlayerByUserId(eventTable.attacker)
		
		if not attacker then
			--print("gave up")
			return
		end
		
		local victim = ents.GetPlayerByUserId(eventTable.userid)
		
		local primary = attacker:GetPlayerItemBySlot(0)	
	
	if eventTable.bonuseffect == 1.0 and attacker:GetPlayerItemBySlot(2):GetAttributeValue("tool needs giftwrap", true) == 1 and attacker.m_hActiveWeapon.m_iClassname == "tf_weapon_fireaxe" and eventTable.damageamount > 40 then
		print("That was an axtinguish")
		
		--print(victim)
		--print(attacker)
		print(attacker.m_hActiveWeapon:GetItemName())
		
		local sphereResults = ents.FindInSphere(victim:GetAbsOrigin(), 300)		
		if sphereResults then
			--print("We got something in the sphere")
			for _, entity in pairs(sphereResults) do
					if entity:IsPlayer() and entity:IsAlive() and entity.m_iTeamNum ~= attacker.m_iTeamNum then
						--print("Saw a player")
						local sufferingDamage = 65
						
						if entity:InCond(22) then
							sufferingDamage = 123
						end
						
						sufferingDamage = sufferingDamage * attacker:GetPlayerItemBySlot(2):GetAttributeValueByClass("mult_dmg", 1)
						if sufferingDamage > entity.m_iHealth then
							sufferingDamage = entity.m_iHealth
						end
					
						timer.Simple(0.01, function()
							if entity:IsAlive() == true then						
								local sufferingTable = {
									Attacker = attacker, -- Attacker
									Inflictor = nil, -- Direct cause of damage, usually a projectile
									Weapon = attacker:GetPlayerItemBySlot(2),
									Damage = sufferingDamage,
									DamageType = DMG_MELEE, -- Damage type, see DMG_* globals. Can be combined with | operator
									DamageCustom = nil, -- Custom damage type, see TF_DMG_* globals
									CritType = 2, -- Crit type, 0 = no crit, 1 = mini crit, 2 = normal crit
									DamagePosition = nil, -- Where the target was hit at
									DamageForce = nil, -- Knockback force of the attack
									ReportedPosition = nil -- Where the attacker attacked from
								}
									if entity:InCond(22) and sufferingDamage >= entity.m_iHealth then
									entity:RemoveCond(22)
									attacker:AddCond(32, 5)
									end
									entity:TakeDamage(sufferingTable)
									--print("Beat up a dude")
							end
						end)
					end
			end
		end
		return
		
	end	
	
	
	
	
	if not primary then
		return
	end
	
	if eventTable.bonuseffect == 2.0 and primary:GetAttributeValue("tool needs giftwrap", true) == 1 then
		--print("That was a donk")
		
		--print(victim)
		--print(attacker)
		--print(primary)
		
		local sufferingDamage = 180 * primary:GetAttributeValueByClass("mult_dmg", 1)
		
		timer.Simple(0.05, function()
			if victim:IsAlive() == true then
			
				local sufferingTable = {
					Attacker = attacker, -- Attacker
					Inflictor = nil, -- Direct cause of damage, usually a projectile
					Weapon = nil,
					Damage = sufferingDamage,
					DamageType = nil, -- Damage type, see DMG_* globals. Can be combined with | operator
					DamageCustom = nil, -- Custom damage type, see TF_DMG_* globals
					CritType = 0, -- Crit type, 0 = no crit, 1 = mini crit, 2 = normal crit
					DamagePosition = nil, -- Where the target was hit at
					DamageForce = nil, -- Knockback force of the attack
					ReportedPosition = nil -- Where the attacker attacked from
				}
				victim:TakeDamage(sufferingTable)
				
			end
		end)
		return
	end	
	
	if primary:GetItemName() == "The Metal Popper" and attacker:InCond(12) == false and attacker:GetAttributeValue("is miniboss", true) == nil then
			--print(attacker:GetAttributeValue("is miniboss", true))
	
			--fuck the hype meter's native charge, thing is almost impossible to work with
			--1500 damage to charge
			attacker.m_flRageMeter = attacker.m_flRageMeter + (0.06 * eventTable.damageamount)
			
			if attacker.m_flRageMeter > 100 then
				attacker.m_flRageMeter = 100
			end
			
			attacker.m_flHypeMeter = attacker.m_flRageMeter
			return
	end
	
	if attacker.m_iClass == 10 then
		
		attacker.m_flRageMeter = attacker.m_flRageMeter + (0.1 * eventTable.damageamount)
		print(attacker.m_flRageMeter)
		
		if attacker.m_flRageMeter >= 100 and attacker.m_flHypeMeter < 3 then
			attacker.m_flRageMeter = 0
			attacker.m_flHypeMeter = attacker.m_flHypeMeter + 1
			print("Spawn a clone")
			cloneSpawn(attacker)
		end
	end	
end)

	local SCOUT_MECH_giantCharacterAttributes = {
		["is miniboss"] = 1,
		["not solid to players"] = 1,
		["SET BONUS: special dsp"] = 38,
		--made an entire function to stop this from erasing speed boost upgrades
		["SET BONUS: move speed set bonus"] = 0.75,
		["damage force reduction"] = 0.4,
		["airblast vulnerability multiplier"] = 0.4,
		["override footstep sound set"] = 5,
		["model scale"] = 1.75,
		["damage bonus"] = 1.5,
		["max health additive bonus"] = 875,
		["effect bar recharge rate increased"] = 0.5,
		["no revive"] = 1,
		["health from healers reduced"] = 0.5,
		["voice pitch scale"] = 0.6,
		["ammo regen"] = 30,
	}	

	local function applyAttributesOverExisting(target, newAttributes)
		local checkItemDefinition = true
	
		if target:IsPlayer() == true then
			checkItemDefinition = false
		end
	
	
		for name, value in pairs(newAttributes) do
			--detonates if an attribute takes a string arg, just don't do that
			if target:GetAttributeValue(name, checkItemDefinition) ~= nil then
				target:SetAttributeValue(name, (value + target:GetAttributeValue(name, checkItemDefinition)))
			else
				target:SetAttributeValue(name, value)
			end
		end			
	end	

--custom weapon functions, past scripts will probably be merged here
function scoutMechPrimaryCall(condition, caller, activator)

	if activator:GetAttributeValue("is miniboss", false) == 1 then
		return
	end
	
	local activatorOrigin = activator:GetAbsOrigin()
	
	local activatorAttributes activator:GetAllAttributeValues(false)
	
	activator.m_flRageMeter = 0
	
	--turn player into mech
	applyAttributesOverExisting(activator, SCOUT_MECH_giantCharacterAttributes)
	
	local teleParticle = ents.CreateWithKeys("info_particle_system", {
		effect_name = "teleportedin_red",
		start_active = 1,
		flag_as_weather = 0,
	}, true, true)				
	teleParticle:SetAbsOrigin(activator:GetAbsOrigin())
	teleParticle:Start()			

	local teleParticle2 = ents.CreateWithKeys("info_particle_system", {
		effect_name = "wrenchmotron_teleport_beam",
		start_active = 1,
		flag_as_weather = 0,
	}, true, true)				
	teleParticle2:SetAbsOrigin(activator:GetAbsOrigin())
	teleParticle2:Start()	
	timer.Simple(1, function()		
		teleParticle:Remove()
		teleParticle2:Remove()		
	end)	
	
	
	local function SCOUT_MECH_playerEjectAndReset(activator, activatorAttributes)
		
		activator:SetCustomModelWithClassAnimations("models/player/scout.mdl")
		activator:AddCond(52, 2, activator)
	
		--this is an incredibly messy way to do this, but I don't think the loss in performance is significant enough for me to care
		--This nils out all giant attributes, then reapplies the player's upgrade attributes
		for name, value in pairs(SCOUT_MECH_giantCharacterAttributes) do
			activator:SetAttributeValue(name, nil)
		end

		

		if activatorAttributes then
			for name, value in pairs(activatorAttributes) do
				activator:SetAttributeValue(name, value)
			end
		end
		
		if activator.m_iHealth < 125 then
			activator:AddHealth((125 - activator.m_iHealth))
		end
		if not activator:IsAlive() then
			activator:SetAttributeValue("not solid to players", 0)
			return
		end
		
				--fix a bug where you can eject in a giant's asshole and instakill them
		activator:SetAttributeValue("not solid to players", 1)
		
			activatorOrigin = activator:GetAbsOrigin()
			dummyOrigin = "" .. activatorOrigin[1] .. " " .. activatorOrigin[2] .. " " .. activatorOrigin[3] .. ""
			dummyAngles = "0 " .. activator["m_angEyeAngles[1]"] .. " 0"
			
			local giantBodyDummy = ents.CreateWithKeys("prop_dynamic",{
				["disableshadows"] = "1",
				["model"] = "models/bots/scout_boss/bot_scout_boss.mdl",
				["DefaultAnim"] = "PRIMARY_stun_middle",
				["origin"] = dummyOrigin,
				["angles"] = dummyAngles,
				["modelscale"] = "1.75",
			
			})
			local giantBodyDummyExplodeSound = ents.CreateWithKeys("ambient_generic",{
				["health"] = "10",
				["message"] = "Cart.Explode",
				["pitch"] = "85",
				["pitchstart"] = "85",
				["radius"] = "750",
				["spawnflags"] = "48",
				["origin"] = dummyOrigin,
				["angles"] = dummyAngles,
			
			})		
			local giantBodyDummyExplode = ents.CreateWithKeys("info_particle_system",{
				["start_active"] = "0",
				["flag_as_weather"] = "0",
				["effect_name"] = "hightower_explosion",
				["origin"] = dummyOrigin,
				["angles"] = dummyAngles,
			
			})			
			--print(giantBodyDummy)
			--ejection force, throws player out of bot and into the sky
			activator:SetAbsOrigin(Vector(activatorOrigin[1], activatorOrigin[2], activatorOrigin[3] + 24))
			activator:AddOutput("BaseVelocity 0 0 700")
			
			timer.Simple(0.75, function()
					giantBodyDummyExplode:AcceptInput("Start")
					giantBodyDummyExplodeSound:AcceptInput("PlaySound")
					
					for _, player in pairs(ents.GetAllPlayers()) do
						if player.m_iTeamNum ~= activator.m_iTeamNum and player:IsAlive() and (player:GetAbsOrigin()):Distance(activatorOrigin) <= 300 then
						--print("Saw a valid target")
							local sufferingTable = {
								Attacker = activator, -- Attacker
								Inflictor = nil, -- Direct cause of damage, usually a projectile
								Weapon = nil,
								Damage = 150 * activator:GetPlayerItemBySlot(0):GetAttributeValueByClass("mult_dmg", 1),
								DamageType = DMG_BLAST, -- Damage type, see DMG_* globals. Can be combined with | operator
								DamageCustom = TF_DMG_CUSTOM_PUMPKIN_BOMB, -- Custom damage type, see TF_DMG_* globals
								CritType = 2, -- Crit type, 0 = no crit, 1 = mini crit, 2 = normal crit
								DamagePosition = nil, -- Where the target was hit at
								DamageForce = nil, -- Knockback force of the attack
								ReportedPosition = nil -- Where the attacker attacked from
							}
							if player:TakeDamage(sufferingTable) ~= 0 then
								activator.m_flRageMeter = 0
								activator.m_flHypeMeter = activator.m_flRageMeter							
							end					
						end
					end
					
					giantBodyDummy:Remove()
					activator:SetAttributeValue("not solid to players", 0)
						
					timer.Simple(1, function()
						giantBodyDummyExplode:AcceptInput("Stop")
						giantBodyDummyExplode:Remove()
						giantBodyDummyExplodeSound:Remove()
						activator:SetAttributeValue("not solid to players", 0)
					end)
			end)
	end	
	
	activator:SetCustomModelWithClassAnimations("models/bots/scout_boss/bot_scout_boss.mdl")
		if activator.m_iHealth < 1000 then
			activator:AddHealth((1000 - activator.m_iHealth))
		end	
	
		local timeLeft = 100
		activator:PlaySoundToSelf("=50|metal_popper_giant_mode_active_1.mp3")
		local logicLoop
	
		logicLoop = timer.Create(0.2, function()
			--print(timeLeft)
			timeLeft = timeLeft - 2
			
			activator.m_flHypeMeter = timeLeft
			if activator:IsAlive() == false or timeLeft <= 0 or activator:InCond(7) then
				timer.Stop(logicLoop)
				SCOUT_MECH_playerEjectAndReset(activator, activatorAttributes)
				return
			end			
			
			if timeLeft == 80 then
				activator:PlaySoundToSelf("=40|metal_popper_giant_mode_active_2.mp3")
			elseif timeLeft == 60 then
				activator:PlaySoundToSelf("=40|metal_popper_giant_mode_active_3.mp3")			
			elseif timeLeft == 40 then
				activator:PlaySoundToSelf("=40|metal_popper_giant_mode_active_4.mp3")
			elseif timeLeft == 26 then
				activator:PlaySoundToSelf("=50|metal_popper_giant_mode_active_5.mp3")
			end
		end, 50)


	
	end
	
	function scoutAmmoOnKill(damage, activator, caller)
	
		local callerOrigin = caller:GetAbsOrigin()

		local ammoPack = ents.CreateWithKeys("item_ammopack_small",{
		["origin"] = callerOrigin[1] .. " " .. callerOrigin[2] .. " "  .. (callerOrigin[3] + 10),
		})
		
		timer.Simple(10, function()
			if ammoPack:IsValid() then
				ammoPack:Remove()
			end
		
		end)
	
	end
	
	
	function dalokasEat(tauntIndex, activator)
		print(tauntIndex)
		print(activator)
		
		if tauntIndex == "scenes/player/heavy/low/taunt04.vcd" then
			print("Diabetes gained")
			activator:AddCond(26, 12, activator)
		end
	end
	
	function heaterExplodeOnKill(damage, activator, caller)
	
		local sphereResults = ents.FindInSphere(caller:GetAbsOrigin(), 200)		
		if sphereResults then
			--print("We got something in the sphere")
			for _, entity in pairs(sphereResults) do
					if entity:IsPlayer() and entity:IsAlive() and entity.m_iTeamNum ~= activator.m_iTeamNum then
						--print("Saw a player")
							entity:IgnitePlayerDuration(10, activator)
						local sufferingTable = {
							Attacker = activator, -- Attacker
							Inflictor = nil, -- Direct cause of damage, usually a projectile
							Weapon = activator:GetPlayerItemBySlot(0),
							Damage = 20,
							DamageType = DMG_BURN, -- Damage type, see DMG_* globals. Can be combined with | operator
							DamageCustom = nil, -- Custom damage type, see TF_DMG_* globals
							CritType = 2, -- Crit type, 0 = no crit, 1 = mini crit, 2 = normal crit
							DamagePosition = nil, -- Where the target was hit at
							DamageForce = nil, -- Knockback force of the attack
							ReportedPosition = nil -- Where the attacker attacked from
						}								
							entity:TakeDamage(sufferingTable)
						end
					end
		end
	end	

	function kgbFirework(damage, activator, caller)
	
		if damage < 195 then
			return
		end
		
		local initialCallerPos = caller:GetAbsOrigin()
	
		caller:AddOutput("BaseVelocity 0 0 700")
		
		timer.Simple(1.2, function()
		
		local currentCallerPos = caller:GetAbsOrigin()
		
		if not currentCallerPos[3] > initialCallerPos[3] + 300 then
			return
		end	
	
		local sphereResults = ents.FindInSphere(currentCallerPos, 200)		
		if not sphereResults then
			return
		end	
		
		--print("We got something in the sphere")
		for _, entity in pairs(sphereResults) do
				if entity:IsPlayer() and entity:IsAlive() and entity.m_iTeamNum ~= activator.m_iTeamNum then
					--print("Saw a player")
					local sufferingTable = {
						Attacker = activator, -- Attacker
						Inflictor = nil, -- Direct cause of damage, usually a projectile
						Weapon = activator:GetPlayerItemBySlot(2),
						Damage = 50,
						DamageType = DMG_BLAST, -- Damage type, see DMG_* globals. Can be combined with | operator
						DamageCustom = nil, -- Custom damage type, see TF_DMG_* globals
						CritType = 0, -- Crit type, 0 = no crit, 1 = mini crit, 2 = normal crit
						DamagePosition = nil, -- Where the target was hit at
						DamageForce = nil, -- Knockback force of the attack
						ReportedPosition = nil -- Where the attacker attacked from
					}								
						entity:TakeDamage(sufferingTable)
					end
				end
		end)
	end		

	--thank you royal
	local function removeCallbacks(player, callbacks)
		if not IsValid(player) then
			return
		end

		for _, callbackId in pairs(callbacks) do
			player:RemoveCallback(callbackId)
		end
	end


	AddEventCallback("player_spawn", function(eventTable)
		local activator = ents.GetPlayerByUserId(eventTable.userid)
		
		if activator:IsRealPlayer() == false or activator.m_iClass ~= 10 then
			return
		end	
		local callbacks = {}
		
		print(activator)
		
		timer.Simple(0.01, function()
			callbacks.spawned = activator:AddCallback(ON_SPAWN, function()
				print("Purged due to being dead, but we didn't catch it before")
				removeCallbacks(activator, callbacks)			
			end)
		end)		
		
		callbacks.owie = activator:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageInfo)
			-- just in case
			if not activator:IsAlive() then
				print("Purged due to being dead")
				removeCallbacks(activator, callbacks)
				return
			end
			
			if activator:InCond(5) then
				return
			end
			
			curHealth = activator.m_iHealth	
				
			local damage = damageInfo.Damage
			--buildings can't get crit, don't need to check for that.
			print(curHealth .. " health compared to " .. damage .. " damage")

			--If the incoming damage is lethal, find the closest clone, swap places and angles with them, then make them die in our place. If we can't find any, just die
			if curHealth <= damage and damageInfo.Attacker.m_iTeamNum ~= activator.m_iTeamNum then
				print("we're about to die")
				local closestClone = nil
				local cloneName = "Clone (" .. activator.m_szNetname .. ")"
				local progenitorPos = activator:GetAbsOrigin()
				
				for _, player in pairs(ents.GetAllPlayers()) do
					if player.m_szNetname == cloneName and player:IsAlive() and player:IsRealPlayer() == false then
						print("we found a clone")
						if closestClone == nil then
							closestClone = player
						else
							if player:GetAbsOrigin():Distance(progenitorPos) < closestClone:GetAbsOrigin():Distance(progenitorPos) then
								closestClone = player
								print("we updated our selected clone")
							end	
						end
					end
				end
				
				local progenitorLookDirection = Vector(activator["m_angEyeAngles[0]"],activator["m_angEyeAngles[1]"], 0)
				activator:SetAbsOrigin(closestClone:GetAbsOrigin())

				
				
				activator:SnapEyeAngles(Vector(closestClone["m_angEyeAngles[0]"],closestClone["m_angEyeAngles[1]"], 0))
				
				closestClone:SnapEyeAngles(progenitorLookDirection)
				
				damageInfo.Damage = damageInfo.Damage + closestClone.m_iHealth
				
				closestClone:SetAbsOrigin(progenitorPos)				
				
				closestClone:TakeDamage(damageInfo)
				print("die clone")
				if closestClone:IsAlive() then
					closestClone:Suicide()
				end
			
				damageInfo.Damage = 0
				damageInfo.DamageType = DMG_GENERIC
					-- do absolutely nothing
					local setHealthDmgInfo = {
						Attacker = damageInfo.Attacker,
						Inflictor = damageInfo.Inflictor,
						Weapon = damageInfo.Weapon,
						Damage = 0,
						CritType = 0,
						DamageType = damageInfo.DamageType,
						DamageCustom = damageInfo.DamageCustom,
						DamagePosition = damageInfo.DamagePosition,
						DamageForce = nil,
						ReportedPosition = damageInfo.ReportedPosition,
					}
					activator:TakeDamage(setHealthDmgInfo)
					activator:AddCond(52, 4, activator)
					activator:AddHealth((200 - activator.m_iHealth))
					
					return true
			end
		end)
		callbacks.dead = activator:AddCallback(ON_DEATH, function()
			print("Purged due to being dead, but later")
			removeCallbacks(activator, callbacks)
		end)
	
	end)

function checkIfMeleeHitAllyCiv(param, activator, calller)
		if not util.IsLagCompensationActive() then
			util.StartLagCompensation(activator)	
		end
	
		--ripped from red_sniper_laser.lua
	
		local function getEyeAngles(player)
			local pitch = player["m_angEyeAngles[0]"]
			local yaw = player["m_angEyeAngles[1]"]

			return Vector(pitch, yaw, 0)
		end
	
		--ripped from my med hunter script, hybrid of red sniper laser check and some original work on my end
	
		local TraceLineOfSight = {
			start = activator, -- Start position vector. Can also be set to entity, in this case the trace will start from entity eyes position
			distance = 100, -- Used if endpos is nil
			angles = getEyeAngles(activator), -- Used if endpos is nil
			mask = MASK_SOLID, -- Solid type mask, see MASK_* globals
			collisiongroup = COLLISION_GROUP_PLAYER, -- Pretend the trace to be fired by an entity belonging to this group. See COLLISION_GROUP_* globals
		}
		local lineOfSightTraceTable = util.Trace(TraceLineOfSight)
		
		local hitEntity = lineOfSightTraceTable.Entity
		--print(lineOfSightTraceTable.Entity)
	
		if IsValid(hitEntity) and hitEntity:IsPlayer() and hitEntity.m_iTeamNum == activator.m_iTeamNum then
			local healedMaxHealth = hitEntity.m_iMaxHealth + hitEntity:GetAttributeValueByClass("add_maxhealth_nonbuffed", 0)
			+ hitEntity:GetAttributeValueByClass("add_maxhealth", 0)
		
			--print("Hit entity was healed!")
			hitEntity.m_iHealth = hitEntity.m_iHealth + (100 * activator:GetAttributeValueByClass("mult_repair_value", 1))
		
			hitEntity:TakeDamage({ -- make the bot take 1 damage so the sentry healthbar updates.
				Damage = 1,
				Attacker = activator,
				Weapon = none,
			})
			hitEntity:TakeDamage({ -- make the bot take -1 damage to nullify effect of earlier damage, could just add 1 to heal value, but I won't
				Damage = -1,
				Attacker = activator,
				Weapon = none,
			})		
		
			if hitEntity.m_iHealth < healedMaxHealth then
				activator:PlaySoundToSelf("Weapon_Wrench.HitBuilding_Success")
				hitEntity:PlaySoundToSelf("Weapon_Wrench.HitBuilding_Success")
			else
				activator:PlaySoundToSelf("Weapon_Wrench.HitBuilding_Failure")
				hitEntity:PlaySoundToSelf("Weapon_Wrench.HitBuilding_Failure")
			end
		
			if hitEntity.m_iHealth > healedMaxHealth then
				hitEntity.m_iHealth = healedMaxHealth
			end
		
		end	
end	
--could evolve this into a more general thing that takes a username instead of just killing skin king
function killSkinKing()
	local allPlayers = ents.GetAllPlayers()
	local skinKing
	
	for _, player in pairs(allPlayers) do
		if player.m_szNetname == "Skin King" then
			skinKing = player
			print("Found Skin King")
			break
		end
	end
	
	if skinKing then
		skinKing:Suicide()
	else
		print("We didn't find him")
	end

end









