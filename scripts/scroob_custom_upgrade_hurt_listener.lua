local BOT_SET_SKILL_EASY =
	"activator.SetDifficulty(0);"
local BOT_SET_SKILL_NORMAL =
	"activator.SetDifficulty(1);"
local BOT_SET_SKILL_HARD =
	"activator.SetDifficulty(2);"
local BOT_SET_SKILL_Expert =
	"activator.SetDifficulty(3);"	

AddEventCallback("player_hurt", function(eventTable)
	--PrintTable(eventTable)
	
		local attacker = ents.GetPlayerByUserId(eventTable.attacker)
		
		if not attacker then
			--print("gave up")
			return
		end
		
		local victim = ents.GetPlayerByUserId(eventTable.userid)
		
		local primary = attacker:GetPlayerItemBySlot(0)		
	
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
			attacker.m_flRageMeter = attacker.m_flRageMeter + (0.1 * eventTable.damageamount)
			
			if attacker.m_flRageMeter > 100 then
				attacker.m_flRageMeter = 100
			end
			
			attacker.m_flHypeMeter = attacker.m_flRageMeter
			return
	end
	
	if attacker.m_iClass == 10 then
		
		attacker.m_flRageMeter = attacker.m_flRageMeter + (0.1 * eventTable.damageamount)
		--print(attacker.m_flRageMeter)
		
		if attacker.m_flRageMeter >= 100 and attacker.m_flHypeMeter < 3 then
			attacker.m_flRageMeter = 0
			attacker.m_flHypeMeter = attacker.m_flHypeMeter + 1
			print("Spawn a clone")
			cloneSpawn(attacker)
		end
	end	
end)

AddEventCallback("player_death", function(eventTable)
	local attacker = ents.GetPlayerByUserId(eventTable.attacker)
	
	if not attacker then
		--print("gave up, no attacker")
		return
	end
		
	local victim = ents.GetPlayerByUserId(eventTable.userid)
		
	local attackerMelee = attacker:GetPlayerItemBySlot(2)
	
	if not attackerMelee then
		--print("gave up, no melee")
		return
	end	
	
	local attackerMeleeArbitraryStorageAttribute = attackerMelee:GetAttributeValue("tool needs giftwrap", true)
	
	if attackerMeleeArbitraryStorageAttribute == nil then
		--print("gave up, no storage attribute")
		return
	end	
	print(attackerMeleeArbitraryStorageAttribute)
	if attackerMelee:GetItemName() == "The Ullapool Caber" and attackerMeleeArbitraryStorageAttribute >= 1 then
		--print("Attacker is the correct caber")
		if victim.m_bIsMiniBoss == 1 or eventTable.weapon == "ullapool_caber" then
			--print("That was a dead giant or a caber kill, we're at 5")
			attackerMelee:SetAttributeValue("tool needs giftwrap", 5)
		else
			--print("A common just died to something other than the caber, we're at " .. attackerMeleeArbitraryStorageAttribute + 1)
			attackerMelee:SetAttributeValue("tool needs giftwrap", attackerMeleeArbitraryStorageAttribute + 1)
		end
		--print(attackerMelee:GetAttributeValue("tool needs giftwrap", true))
		
		if attackerMelee:GetAttributeValue("tool needs giftwrap", true) >= 5 and attackerMelee.m_iDetonated == 1 then
			attacker:PlaySoundToSelf("items/pumpkin_pickup.wav")
			attacker:PlaySoundToSelf("items/spawn_item.wav")
			attackerMelee.m_iDetonated = 0
		end
		
	end
end)

function demoCaberClearStorageOnHit(activator, projectile, self)
	if self.m_iDetonated ~= 0 then
		return
	end	
	
	local caberHolder = self.m_hOwner
	--print(caberHolder)

	if not util.IsLagCompensationActive() then
		util.StartLagCompensation(caberHolder)	
	end

	--ripped from red_sniper_laser.lua

	local function getEyeAngles(player)
		local pitch = player["m_angEyeAngles[0]"]
		local yaw = player["m_angEyeAngles[1]"]

		return Vector(pitch, yaw, 0)
	end

	--ripped from my med hunter script, hybrid of red sniper laser check and some original work on my end

	local TraceLineOfSight = {
		start = caberHolder, -- Start position vector. Can also be set to entity, in this case the trace will start from entity eyes position
		distance = 65, -- Used if endpos is nil
		angles = getEyeAngles(caberHolder), -- Used if endpos is nil
		mask = MASK_SOLID, -- Solid type mask, see MASK_* globals
		collisiongroup = COLLISION_GROUP_PLAYER, -- Pretend the trace to be fired by an entity belonging to this group. See COLLISION_GROUP_* globals
	}
	local lineOfSightTraceTable = util.Trace(TraceLineOfSight)
	
	local hitEntity = lineOfSightTraceTable.Entity
		
	--print(self)
	--print(self.m_iDetonated)
	print(hitEntity)
	
	if hitEntity ~= nil then
		self:SetAttributeValue("tool needs giftwrap", 1)
		print("Reset counter")
	end
end

function soldierEarrapeBannerActivateBrainrot(condition, caller, activator)

	--stored here for optimization purposes, doing up to 22 gets within a 0.2 second tick would be quite bad
	local ourTeamNum = activator.m_iTeamNum
	--the liberty launcher's support upgrade exists, and going forward I might have more buff range increases in the future
	--The +0.95 is to cancel the penalty on the banner itself when calculating this
	local sufferingRadius = 450
	
	if activator:GetAttributeValue("mod soldier buff range", true) ~= nil then
		sufferingRadius = 450 * (activator:GetAttributeValue("mod soldier buff range", true) + 0.95)
	end
		
	local playerLocation = activator:GetAbsOrigin()	
			
			
--SetModelScale			
	for _, player in pairs(ents.GetAllPlayers()) do
		if player.m_iTeamNum ~= ourTeamNum and player:IsAlive() and (player:GetAbsOrigin()):Distance(playerLocation) <= sufferingRadius then
			--this is to stop more than one jammer banner from permanently lobotomizing a bot
			--print(player:GetAttributeValue("grenades3_resupply_denied", true))
			if player:GetAttributeValue("grenades3_resupply_denied", true) ~= nil and player:GetAttributeValue("grenades3_resupply_denied", true) >= 1 then
				--print("We cannot touch this guy")
				return
			end
			local preBrainrotBotSkill = player.m_nBotSkill
			local preBrainrotDamagePenalty = player:GetAttributeValue("damage penalty", false)
			if preBrainrotDamagePenalty == nil then
				preBrainrotDamagePenalty = 1	
			end
			
			player.m_nBotSkill = 0
			player:RunScriptCode(BOT_SET_SKILL_EASY, player, player)
			
			player:SetAttributeValue("grenades3_resupply_denied", 1)
			player:SetAttributeValue("damage penalty", (preBrainrotDamagePenalty - 0.25))
			--print("Applied damage penalty of " .. (preBrainrotDamagePenalty - 0.25))
			
			local painParticle = ents.CreateWithKeys("info_particle_system", {
				effect_name = "medic_resist_bullet",
				start_active = 1,
				flag_as_weather = 0,
			}, true, true)
			painParticle:SetAbsOrigin(player:GetAbsOrigin())
			painParticle:Start()
			painParticle:AcceptInput("SetParent", "!activator", player, nil)
			timer.Simple(1, function()
				painParticle:Remove()
				--if our skill was changed by something else, back off and don't fuck them up.
				if player.m_nBotSkill == 0 then
					--print("Reset skill, it is now at " .. preBrainrotBotSkill)
					player.m_nBotSkill = preBrainrotBotSkill
					
					--If only lua had switch statements
					
					if preBrainrotBotSkill == 1 then
					
						player:RunScriptCode(BOT_SET_SKILL_NORMAL, player, player)
						
					elseif preBrainrotBotSkill == 2 then
					
						player:RunScriptCode(BOT_SET_SKILL_HARD, player, player)
						
					elseif preBrainrotBotSkill == 3 then
					
						player:RunScriptCode(BOT_SET_SKILL_EXPERT, player, player)
						
					end
				end
				
				--print("Reset damage penalty")
				player:SetAttributeValue("damage penalty", preBrainrotDamagePenalty)
					
				--print("Reset brainrotability")
				player:SetAttributeValue("grenades3_resupply_denied", 0)
			end)
		end	
	end	
end

function demoShieldSuicideBomb(damage, activator, caller)
	activatorOrigin = activator:GetAbsOrigin()
	bombOrigin = "" .. activatorOrigin[1] .. " " .. activatorOrigin[2] .. " " .. activatorOrigin[3] .. ""
			local ExplodeSound = ents.CreateWithKeys("ambient_generic",{
				["health"] = "10",
				["message"] = "Cart.Explode",
				["pitch"] = "85",
				["pitchstart"] = "85",
				["radius"] = "750",
				["spawnflags"] = "48",
				["origin"] = bombOrigin,
			
			})		
			local ExplodeEffect = ents.CreateWithKeys("info_particle_system",{
				["start_active"] = "0",
				["flag_as_weather"] = "0",
				["effect_name"] = "hightower_explosion",
				["origin"] = bombOrigin,
			})
			
			ExplodeEffect:AcceptInput("Start")
			ExplodeSound:AcceptInput("PlaySound")
			
			explosionDamage = 85 * activator:GetPlayerItemBySlot(2):GetAttributeValueByClass("mult_dmg", 1)
			
			local function inflictDamage(player, damage)
				local victimDamage = damage
				
				--This means the victim will never be killed by the explosion, they will instead be stunned for 10 seconds.
				if victimDamage > player.m_iHealth then
					victimDamage = victimDamage - (player.m_iHealth + 1)
					player:StunPlayer(10, 1, TF_STUNFLAG_BONKSTUCK, activator)
				end
			--print("Saw a valid target")
				local sufferingTable = {
					Attacker = activator, -- Attacker
					Inflictor = nil, -- Direct cause of damage, usually a projectile
					Weapon = nil,
					Damage = victimDamage,
					DamageType = DMG_BLAST, -- Damage type, see DMG_* globals. Can be combined with | operator
					DamageCustom = TF_DMG_CUSTOM_PUMPKIN_BOMB, -- Custom damage type, see TF_DMG_* globals
					CritType = 0, -- Crit type, 0 = no crit, 1 = mini crit, 2 = normal crit
					DamagePosition = nil, -- Where the target was hit at
					DamageForce = nil, -- Knockback force of the attack
					ReportedPosition = nil -- Where the attacker attacked from
				}
				player:TakeDamage(sufferingTable)
			end
			
			inflictDamage(caller, (explosionDamage - (damage + 1)))
					
			for _, player in pairs(ents.GetAllPlayers()) do
				if player.m_iTeamNum ~= activator.m_iTeamNum and player:IsAlive() and (player:GetAbsOrigin()):Distance(activatorOrigin) <= 400 and player ~= caller then
					inflictDamage(player, explosionDamage)
				end
			end
								
			timer.Simple(0.25, function()
				ExplodeEffect:AcceptInput("Stop")
				ExplodeEffect:Remove()
				ExplodeSound:Remove()
			end)			
end




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

function engineerShotgunMaintainOnKill(damage, activator, caller)
	--local sentryTable = ents.FindAllByClass("obj_sentrygun")
	--PrintTable(sentryTable)
	--local dispenserTable = ents.FindAllByClass("obj_dispenser")
	--PrintTable(dispenserTable)
	--local teleporterTable = ents.FindAllByClass("obj_teleporter")
	--PrintTable(teleporterTable)	
	
	local buildingTable = ents.FindAllByClass("obj_*")
	
	--for _, entity in pairs (sentryTable) do
	--	table.insert(buildingTable, entity)
	--end
	
	--for _, entity in pairs (dispenserTable) do
	--	table.insert(buildingTable, entity)
	--end

	--for _, entity in pairs (teleporterTable) do
	--	table.insert(buildingTable, entity)
	--end	
	
	--PrintTable(buildingTable)
	
	for _, entity in pairs(buildingTable) do
		--print(entity.m_hBuilder)
		if entity.m_hBuilder == activator then
			--object type is placed in a variable because it will be accessed multiple times
			local buildingObjectType = entity.m_iObjectType
			local buildingBaseHealth = 216
			
			--if the activator has the gunslinger mini sentry attribute, or you're a disposable building, and you're a sentry, your base health is 100
			if (activator:GetAttributeValue("mod wrench builds minisentry", true) or entity.m_bDisposableBuilding == 1) == 1 and buildingObjectType == 2 then
				buildingBaseHealth = 100
				
			elseif entity.m_iUpgradeLevel == 1 then
				buildingBaseHealth = 150
				
			elseif entity.m_iUpgradeLevel == 2 then
				buildingBaseHealth = 180
				
			end
			--if none of the above checks pass, we will assume that we are a level 3 building
		
			local buildingMaxHealth = activator:GetAttributeValueByClass("mult_engy_building_health", 1) * buildingBaseHealth
			print(buildingMaxHealth)
			print(activator:GetAttributeValueByClass("mult_engy_building_health", 1))
			
			if entity.m_bBuilding == 1 then
				entity.m_flPercentageConstructed = entity.m_flPercentageConstructed + 0.3
				entity.m_iHealth = entity.m_iHealth + buildingMaxHealth * 0.3
				if entity.m_flPercentageConstructed >= 1 then
					entity.m_bBuilding = 0
				end
			else
			
			entity.m_iHealth = entity.m_iHealth + buildingMaxHealth * 0.1
			
			end
			
			if entity.m_iHealth > buildingMaxHealth then
				entity.m_iHealth = buildingMaxHealth
			end
			
			if buildingObjectType == 2 then
				if entity.m_iUpgradeLevel ~= 1 then
				--level 2 and 3 sentries have 200 bullet ammo in them while level 1s and minis have 150
				entity.m_iAmmoShells = entity.m_iAmmoShells + 20
				--level 2s don't shoot rockets, but these calculations do nothing bad by changing their rockets netprop
				--before they fire them, so I don't care.
				entity.m_iAmmoRockets = entity.m_iAmmoRockets + 2
					if entity.m_iAmmoShells > 200 then
						entity.m_iAmmoShells = 200
					end
					if entity.m_iAmmoRockets > 20 then
						entity.m_iAmmoRockets = 20
					end
				else
				entity.m_iAmmoShells = entity.m_iAmmoShells + 15
					if entity.m_iAmmoShells > 150 then
						entity.m_iAmmoShells = 150
					end
				end
			end
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
		
				--fixes a bug where you can eject in a giant's asshole and instakill them
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
	
	function axtinguisherExplosion(damage, activator, caller)
		if not caller:InCond(22) then
			return
		end		
			
		--implicitly calls incond
		caller:RemoveCond(22)	
	
		local sphereResults = ents.FindInSphere(caller:GetAbsOrigin(), 300)		
		if sphereResults then
			--print("We got something in the sphere")
			for _, entity in pairs(sphereResults) do
					if entity:IsPlayer() and entity:IsAlive() and entity.m_iTeamNum ~= activator.m_iTeamNum then
						--print("Saw a player")
						local sufferingDamage = 65
						
						if entity:InCond(22) then
							sufferingDamage = 123
						end
						
						sufferingDamage = sufferingDamage * activator:GetPlayerItemBySlot(2):GetAttributeValueByClass("mult_dmg", 1)
						if sufferingDamage > entity.m_iHealth then
							sufferingDamage = entity.m_iHealth
							activator:AddCond(TF_COND_SPEED_BOOST, 5)
						end
					
						timer.Simple(0.01, function()
							if entity:IsAlive() == true then						
								local sufferingTable = {
									Attacker = activator, -- Attacker
									Inflictor = nil, -- Direct cause of damage, usually a projectile
									Weapon = activator:GetPlayerItemBySlot(2),
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
									activator:AddCond(32, 5)
									end
									entity:TakeDamage(sufferingTable)
									--print("Beat up a dude")
							end
						end)
					end
			end
		end	
	
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
		
		--print(activator)
		
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

--Admin functions, for use during tests. Should probably be split off into its own file to save some server memory, but
--at the moment it isn't anything gigantic


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



--This function has no right to exist, I just got jealous of hellmet's robot conversion binds
function becomeMonochrome(target)
	local modelUseInt = 1
	if not target then
		print("There was no target")
		return
	end
	local itIsI
	print(target)
	--target is a string literal
	
	local allPlayers = ents.GetAllPlayers()
	for _, player in pairs(allPlayers) do
		if player.m_szNetname == target then
			itIsI = player
			print("Found Me")
			break
		end
	end
	
	if not itIsI then
		print("Didn't find me")
		return
	end
	
	local storedClass = itIsI.m_iClass
	
	local monochrome_Character_Attributes = {
		["move speed bonus"] = 0.5,
		["damage force reduction"] = 0.01,
		["airblast vulnerability multiplier"] = 0.01,
		["override footstep sound set"] = 3,
		["crit mod disabled"] = 0,
		["health from packs decreased"] = 0.01,
		["not solid to players"] = 1,			
		["cancel falling damage"] = 1,
		["dmg taken mult from special damage type 2"] = 1.75,
		["is miniboss"] = 1,
		["model scale"] = 1.75,
		--Average of his HP between short circuit and deprecated designs
		["max health additive bonus"] = 64800,
		["voice pitch scale"] = 0,
	}
	local monochrome_Launcher_Attributes = {
		["faster reload rate"] = -0.8,
		["fire rate bonus"] = 0.4,
		["collect currency on kill"] = 1,
		["paintkit_proto_def_index"] = 420,
		["set_item_texture_wear"] = 0,
		["add cond when active"] = 36,
		["crit vs burning players"] = 1,
		["crit vs non burning players"] = 1,
		["projectile trail particle"] = "eyeboss_projectile",
		--If this command is being invoked, you're probably in one of my missions, therefore, I can
		--safely have this. If you want to know what it is, see bot_pale_burst.lua, or robot_scroob.pop
		["fire input on attack"] = "popscript^$paleBurstLogicOnAttack^",
		["mod projectile heat follow crosshair"] = 1,
		["mod projectile heat seek power"] = 100,
		["mod projectile heat aim error"] = 360,
		["mod projectile heat aim time"] = 0.7,		
		["mult dmg vs giants"] = 1.5,
	}
	local monochrome_Bison_Attributes = {
		["faster reload rate"] = 0.01,
		["fire rate bonus"] = 0.35,
		["collect currency on kill"] = 1,
		["passive reload"] = 1,
		["mult dmg vs giants"] = 1.5,
		["set item tint rgb"] = 16777215,
	}	
	
	
	itIsI:SwitchClassInPlace(3)
	--not everyone is going to have the grey gsoldier model precached
	if modelUseInt == 1 then
		itIsI:SetCustomModelWithClassAnimations("models/bots/soldier_boss/bot_soldier_gray_boss.mdl")
	else
		itIsI:SetCustomModelWithClassAnimations("models/bots/soldier_boss/bot_soldier_boss.mdl")
	end	
	
	--This was a godawful idea
	--itIsI.m_szNetname = "Monochrome"

	for _, player in pairs(allPlayers) do
		--I don't want to have 45 or 22 * number of messages, timers kicking around
		if player:IsRealPlayer() then
		player:AcceptInput("$DisplayTextChat", "{EEEEEE}Monochrome{reset} : {EEEEEE}this{66FF66}.longWindedIntro({FF0000}allPlayers{66FF66})")
			player:PlaySoundToSelf("mvm/mvm_tele_deliver.wav")
			player:PlaySoundToSelf("siren2.wav")
			--These are all started in sequence, so they need to be offset by 2 seconds each
			timer.Simple(2, function()
				player:AcceptInput("$DisplayTextChat", "{EEEEEE}Monochrome{reset} : {FF0000}allPlayers{66FF66}.m_ICareLevel < Double.NEGATIVE_INFINITY")
			end)
			timer.Simple(4, function()
				player:AcceptInput("$DisplayTextChat", "{EEEEEE}Monochrome{reset} : {FF9999}FINE")
			end)
			timer.Simple(4.5, function()
				player:AcceptInput("$DisplayTextChat", "{EEEEEE}Monochrome{reset} : {FF7777}ENGAGE")
			end)			
		end
	end		
	
	itIsI:AddCond(66, 0.4)
	itIsI:AddCond(TF_COND_MVM_BOT_STUN_RADIOWAVE, 0.5)
	itIsI:AddCond(5, 2)	
	
	local launcher = itIsI:GiveItem("Upgradeable TF_WEAPON_ROCKETLAUNCHER")
	local bison = itIsI:GiveItem("The Righteous Bison")
	local itemOverwriter = itIsI:GiveItem("The Patriot's Pouches")
	itemOverwriter:Remove()
	itemOverwriter = itIsI:GiveItem("Shortness Of Breath")
	itemOverwriter:Remove()
	itIsI:GiveItem("Tyrantium Helmet"):SetAttributeValue("set item tint rgb", 16777215)
	
	--I don't hate myself enough to copypaste 2 bajillion SetAttributeValue lines
	for name, value in pairs(monochrome_Character_Attributes) do
		itIsI:SetAttributeValue(name, value);
	end	
	for name, value in pairs(monochrome_Launcher_Attributes) do
		launcher:SetAttributeValue(name, value);
	end
	for name, value in pairs(monochrome_Bison_Attributes) do
		bison:SetAttributeValue(name, value);
	end
	
	
		local callbacks = {}

		callbacks.yeeowch = itIsI:AddCallback(ON_DEATH, function()		
			for _, player in pairs(allPlayers) do
				player:AcceptInput("$DisplayTextChat", "{EEEEEE}*DEAD* Monochrome{reset} : {66FF66}print(\"{FF9999}FUCK{66FF66}\")")
			end		
			itIsI.m_szNetname = target
			timer.Simple(0.05, function()
				removeCallbacks(itIsI, callbacks)
				for name, value in pairs(monochrome_Character_Attributes) do
					itIsI:SetAttributeValue(name, nil);
				end				
				itIsI:SwitchClassInPlace(storedClass)
				if storedClass == 3 and itIsI.m_iTeamNum == 2 then
				itIsI:SetCustomModelWithClassAnimations("models/player/soldier.mdl")
				elseif itIsI.m_iTeamNum ~= 2 then
				itIsI:SetCustomModelWithClassAnimations("models/bots/soldier/bot_soldier.mdl")
				end
			end)
		end)
		
end
	
	































