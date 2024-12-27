--Script is made to facilitate the teleport out logic for both Monochrome himself and his honor guard, along with managing his second phase's gigaburst shotgun logic.
local function removeCallbacks(player, callbacks)
	if not IsValid(player) then
		return
	end

	for _, callbackId in pairs(callbacks) do
		player:RemoveCallback(callbackId)
	end
end

--excerpt from royal's sniper laser script
local function getEyeAngles(player)
	local pitch = player["m_angEyeAngles[0]"]
	local yaw = player["m_angEyeAngles[1]"]

	return Vector(pitch, yaw, 0)
end

local function hideLaser(laser, pointer)
	if not IsValid(laser) then
		return
	end

	laser:Stop()
	laser:SetAbsOrigin(pointer:GetAbsOrigin())
end

function MonochromeLogic(_, activator)

	local callbacks = {}

	local check

	local terminated = false
	
	local laser = ents.CreateWithKeys("info_particle_system", {
		effect_name = "laser_sight_beam",
		start_active = 0,
		flag_as_weather = 0,
	}, false)

	laser:SetName("le_laser" .. tostring(activator:GetHandleIndex()))

	local pointer = Entity("info_particle_system")
	local color = Entity("info_particle_system")

	pointer:SetName("le_laserpointer" .. tostring(activator:GetHandleIndex()))
	color:SetName("le_lasercolor" .. tostring(activator:GetHandleIndex()))

	color:SetAbsOrigin(Vector(255, 255, 255))

	laser.m_hControlPointEnts[1] = pointer
	laser.m_hControlPointEnts[2] = color

	for _, e in pairs({ laser, pointer, color }) do
		e["$SetOwner"](e, activator)
	end

	laser.m_iClassname = "env_sprite"
	pointer.m_iClassname = "env_sprite"	
	
	local started = false


	local function terminate()
		if terminated then
			return
		end

		terminated = true

		timer.Stop(check)
		removeCallbacks(activator, callbacks)

		hideLaser(laser, pointer)

		timer.Simple(0.1, function()
			for _, e in pairs({ laser, pointer, color }) do
				if IsValid(e) then
					e:Remove()
				end
			end
		end)
	end
	
	local lastSphereResults = {}
	local buffedAndDebuffed = ents.GetAllPlayers()

	check = timer.Create(0.015, function()

		if not IsValid(activator) or not activator:IsAlive() then
			terminate()
			return
		end

		
		if activator:GetAttributeValue("sniper no headshots", false) >= 1 then
				
			local primary = activator:GetPlayerItemBySlot(0)
			local secondary = activator:GetPlayerItemBySlot(1)	
			local clipBonusMult = primary:GetAttributeValueByClass("mult_clipsize", 1)

			local clipBonusAtomic = primary:GetAttributeValueByClass("mult_clipsize_upgrade_atomic", 0)

			local maxClip = (4 * clipBonusMult) + clipBonusAtomic				

			if primary.m_iClip1 == 0 then	
				activator:WeaponSwitchSlot(1)	
				secondary:SetAttributeValue("disable weapon switch", 1)	
				--print("our clip is low!")
				timer.Simple(3 ,function()
					if primary then
					primary.m_iClip1 = maxClip
					end
					secondary:SetAttributeValue("disable weapon switch", 0)							
					activator:WeaponSwitchSlot(0)			
				end, 1)
			end		
		end
		
		if activator:GetAttributeValue("sniper no headshots", false) >= 2 then
		--print("We're here")
		
			if buffedAndDebuffed then
				
				for _, entity in pairs(buffedAndDebuffed)  do
					
					if entity:IsAlive() == true then
						if entity:GetAbsOrigin():Distance(activator:GetAbsOrigin()) > 200 and entity.m_iTeamNum ~= activator.m_iTeamNum and entity:GetAttributeValue("SET BONUS: mystery solving time decrease", false) == 1337 then
							entity:SetAttributeValue("damage bonus HIDDEN", nil)
							entity:SetAttributeValue("SET BONUS: mystery solving time decrease", nil)
							print("undebuffed " .. entity.m_szNetname)
						end
					end
				end
			end
			
		lastSphereResults = {}
		
		local sphereResults = ents.FindInSphere(activator:GetAbsOrigin(), 650)		
			if sphereResults then
				--print("We got something in the sphere")
				for _, entity in pairs(sphereResults) do
						--if entity:IsPlayer() then
						--	print(entity:GetAttributeValue("SET BONUS: mystery solving time decrease", true) or 0 .. ", " .. entity.m_szNetname)
						--end
						if entity:IsPlayer() and entity:GetAttributeValue("SET BONUS: mystery solving time decrease", true) ~= 1337 and entity:IsAlive() then
							--print("Saw a player")
							
							if entity.m_iTeamNum ~= activator.m_iTeamNum and entity:GetAbsOrigin():Distance(activator:GetAbsOrigin()) <= 200 then
								if activator.m_iClass == 8 then
									entity:Print(PRINT_TARGET_CENTER, "YOU'RE IMMUNE TO MONOCHROME'S DEBUFF RADIUS, GOOD FOR YOU!")
									entity:SetAttributeValue("SET BONUS: mystery solving time decrease", 1337)
								else
									entity:SetAttributeValue("SET BONUS: mystery solving time decrease", 1337)
									entity:SetAttributeValue("damage bonus HIDDEN", 0.5)
									entity:Print(PRINT_TARGET_CENTER, "YOU'RE WITHIN MONOCHROME'S DEBUFF RADIUS, YOU ARE SUFFERING A 50% DAMAGE PENALTY, BACK UP!")
									--print("debuffed " .. entity.m_szNetname)
								end
							end
						end
				end
			end
		end

		local eyeAngles = getEyeAngles(activator)

		local DefaultTraceInfo = {
			start = activator,
			distance = 10000,
			angles = eyeAngles,
			mask = MASK_SOLID,
			collisiongroup = COLLISION_GROUP_DEBRIS,
		}
		local trace = util.Trace(DefaultTraceInfo)

		laser:SetAbsOrigin(trace.StartPos)
		pointer:SetAbsOrigin(trace.HitPos)

		laser:Start()

		started = true			
		

	end, 0)

	callbacks.hurtpre = activator:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageInfo)
		-- just in case
		if not activator:IsAlive() then
			return
		end
		
		local curHealth = activator.m_iHealth
		local damage = damageInfo.Damage
			
		if (damageInfo.DamageType & DMG_CRITICAL > 0) then 
			damage = damageInfo.Damage * 3.1
		 end

		--If the incoming damage is lethal, set our health to 1 instead.
		if curHealth - (damage + 1) <= 0 and damageInfo.Attacker.m_iTeamNum ~= activator.m_iTeamNum and activator:InCond(5) == false then
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
				
				activator:AddCond(5, 99, activator)
				activator:AddCond(71, 99, activator)		
				
				timer.Simple(5 ,function()
					if activator then					
							
						local teleParticle = ents.CreateWithKeys("info_particle_system", {
							effect_name = "teleportedin_blue",
							start_active = 1,
							flag_as_weather = 0,
						}, true, true)				
						teleParticle:SetAbsOrigin(activator:GetAbsOrigin())
						teleParticle:Start()
						allPlayers = ents.GetAllPlayers()
						for _, player in pairs(allPlayers) do
							player:AcceptInput("$PlaySoundToSelf", "weapons/teleporter_send.wav")
						end				

						local teleParticle2 = ents.CreateWithKeys("info_particle_system", {
							effect_name = "wrenchmotron_teleport_beam",
							start_active = 1,
							flag_as_weather = 0,
						}, true, true)				
						teleParticle2:SetAbsOrigin(activator:GetAbsOrigin())
						teleParticle2:Start()	
						timer.Simple(1, function()
							activator:AddCond(66, 99, activator)		
							teleParticle:Remove()
							teleParticle2:Remove()	
							terminate()		
						end)
								
					end
				end)

				timer.Simple(6, function()
					activator:BotCommand("despawn")
				end)

				return true
				end				
	end)	
	
	
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



function insultVictim(damage, activator, caller)
	if not caller or caller:IsRealPlayer() == false then
		return
	end
	
	allPlayers = ents.GetAllPlayers()

	--if we just killed a medic via bison, make fun of them assuming their shield is up
	if activator.m_hActiveWeapon.m_iClassname == "tf_weapon_raygun" and caller.m_iClass == 5 then
			for _, player in pairs(allPlayers) do	   --another script done by Royal, to my knowledge
				player:AcceptInput("$DisplayTextChat", "{EEEEEE}Monochrome{reset} : {red}" .. caller.m_szNetname .. "{66FF66}:IsMoron() == {FF9999}TRUE")
			end	
			return
	end
	
	--if we just killed a facetanking heavy, make fun of them
	if caller.m_iClass == 6 and caller:GetAbsOrigin():Distance(activator:GetAbsOrigin()) < 300  then
		for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", "{EEEEEE}Monochrome{reset} : {66FF66}for {red}idiot {66FF66}in {FFEEEE}FACETANK RANGE {66FF66}do makeFunOF({red}idiot) {66FF66}end")
		end
		return	
	end	
	
	--check if they're a gigachad engie
	if caller.m_iClass == 9 and caller:GetPlayerItemBySlot(2):GetAttributeValue("max health additive bonus", true) ~= nil and caller:GetPlayerItemBySlot(2):GetAttributeValue("max health additive bonus", true) >= 350 then
			for _, player in pairs(allPlayers) do	   --another script done by Royal, to my knowledge
				player:AcceptInput("$DisplayTextChat", "{EEEEEE}Monochrome{reset} : {FFEEEE}I AM FAMILIAR WITH YOUR ILK {red}" .. caller.m_szNetname)
			end	
			return
	end

	--are you a soldier?
	if caller.m_iClass == 3 then
		for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", "{EEEEEE}Monochrome{reset} : {red}" .. caller.m_szNetname .. "{66FF66}.scale < Constants.AVERAGE")
		end
		return	
	end
	
	--are you a spy?
	if caller.m_iClass == 8 then
		for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", "{EEEEEE}Monochrome{reset} : {red}" .. caller.m_szNetname .. "{66FF66}, As the TF_CLASS_SPY, {FFEEEE}PRESS , TO CHANGE CLASS")
		end
		return		
	end

	--are you a scotres demo?
	if caller:GetPlayerItemBySlot(1):GetItemName() == "The Scottish Resistance" then
		for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", "{EEEEEE}Monochrome{reset} : {red}" .. caller.m_szNetname .. "{FFEEEE} HEAD TO {66FF66}mvm_mannhatten{FFEEEE}, YOU'LL FIND ROBOTS SLOW ENOUGH FOR YOUR {66FF66}Scottish Resistance{FFEEEE} ROTTED BRAIN")
		end
		return		
	end

	--are you a pyro?
	if caller.m_iClass == 7 then
		for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", "{EEEEEE}Monochrome{reset} : PYRO STATUS: {red}" .. caller.m_szNetname .. "{66FF66}.m_lifeState = {FF0000}0")
		end
		return		
	end	
	
	--are you an EH sniper?
	if caller.m_iClass == 2 then
		if caller:GetPlayerItemBySlot(0):GetAttributeValue("explosive sniper shot", true) > 0 or caller:GetPlayerItemBySlot(0):GetAttributeValue("explosive sniper shot", true) ~= nil then
			for _, player in pairs(allPlayers) do
				player:AcceptInput("$DisplayTextChat", "{EEEEEE}Monochrome{reset} : {66FF66}goto Places.HELL, {EEEEEE}AND TAKE {66FF66}explosive sniper shot {EEEEEE}WITH YOU")
			end			
		end	
		return
	end	

end

function insultVictimFunny(damage, activator, caller)
	if not caller or caller:IsRealPlayer() == false then
		print("target is not real")
		return
	end
	
	allPlayers = ents.GetAllPlayers()
	
	print(caller.m_iClass)

	--if we just killed a medic via bison, make fun of them assuming their shield is up
	if activator.m_hActiveWeapon.m_iClassname == "tf_weapon_raygun" and caller.m_iClass == 5 then
			for _, player in pairs(allPlayers) do	   --another script done by Royal, to my knowledge
				player:AcceptInput("$DisplayTextChat", "{ffAAFF}MonOwOchrome{reset} :  I DIDN'T KNOW {red}" .. caller.m_szNetname .. "{66FF66}:IsSiwwy() == {ffAAFF}TWUE X3")
			end
			return
	end
	
	--if we just killed a facetanking heavy, make fun of them
	if caller.m_iClass == 6 and caller:GetAbsOrigin():Distance(activator:GetAbsOrigin()) < 300  then
		for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", "{ffAAFF}MonOwOchrome{reset} : OH {red}" ..	caller.m_szNetname  .. "{ffAAFF}, I DON'T WANT TO CUDDLE WIFF YOU WIGHT NOW, MAYBE LATER")
		end
	end		
	
	--are you a gigachad engie?
	if caller.m_iClass == 9 and caller:GetPlayerItemBySlot(2):GetAttributeValue("max health additive bonus", true) ~= nil and caller:GetPlayerItemBySlot(2):GetAttributeValue("max health additive bonus", true) >= 350 then
			for _, player in pairs(allPlayers) do	   --another script done by Royal, to my knowledge
				player:AcceptInput("$DisplayTextChat", "{ffAAFF}MonOwOchrome{reset} : {FFEEEE} I WEMEMBEW BOTS WIKE YOU {red}" .. caller.m_szNetname .. "{ffAAFF}! OwO")
			end	
			return
	end

	--are you a soldier?
	if caller.m_iClass == 3 then
		for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", "{ffAAFF}MonOwOchrome{reset} : {red}" .. caller.m_szNetname .. "{66FF66}.scawe < Constants.AVEWAGE. {ffAAFF}YOU AWE GOOD JUST THE WAY YOU AWE THOUGH")
		end
		return		
	end
	
	--are you a spy?
	if caller.m_iClass == 8 then
		for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", "{ffAAFF}MonOwOchrome{reset} : {ffAAFF}WHAT AWE YOU DOING BACK THEWE {red}" .. caller.m_szNetname .. "? {FFAAFF}OwO")
		end
		return		
	end

	--are you a scotres demo?
	if caller:GetPlayerItemBySlot(1):GetItemName() == "The Scottish Resistance" then
		for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", "{ffAAFF}MonOwOchrome{reset} : IS SOMEBODY TOO USED TO {66FF66}mvm_mannhatten?{FFAFF} BWANCH OUT AND TWY NEW THINGS!")
		end
		return		
	end

	--are you a pyro?
	if caller.m_iClass == 7 then
		for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", "{ffAAFF}MonOwOchrome{reset} : YOU'WE TWYING YOUW BEST! IT'WW WOWK EVENTUAWWY!")
		end
		return		
	end	
	
	--are you a sniper in general?
	if caller.m_iClass == 2 then
		for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", "{ffAAFF}MonOwOchrome{reset} : {ffAAFF}UH OH! WOOKS WIKE SOMEBODY NEEDS TO {66FF66}goto Pwaces.BED {ffAAFF}TWY HAWDEW TOMOWWO!!")
		end
		return		
	end	

end

function wipeForwardGreys()
		local allPlayers = ents.GetAllPlayers()
		
		local forwardGreys = {}
		
		for _, player in pairs(allPlayers) do
			--print(player)
			if player.m_iTeamNum == 1 and player:IsAlive() and player:GetAttributeValue("hidden string attribute 1", false) == "IM A FORWARD GREY" then
				table.insert(forwardGreys, player)
			end	
		end		
		
		for _, player in pairs(forwardGreys) do
				player:AddCond(52, 99, player)
				player:AddCond(71, 99, player)		
				local teleParticle = ents.CreateWithKeys("info_particle_system", {
					effect_name = "teleportedin_blue",
					start_active = 1,
					flag_as_weather = 0,
				}, true, true)				
				teleParticle:SetAbsOrigin(player:GetAbsOrigin())
				teleParticle:Start()		

				local teleParticle2 = ents.CreateWithKeys("info_particle_system", {
					effect_name = "wrenchmotron_teleport_beam",
					start_active = 1,
					flag_as_weather = 0,
				}, true, true)				
				teleParticle2:SetAbsOrigin(player:GetAbsOrigin())
				teleParticle2:Start()	
				timer.Simple(1, function()
					player:AddCond(66, 99, player)		
					teleParticle:Remove()
					teleParticle2:Remove()
					player:BotCommand("despawn")
				end)				
		end
end

function annihilateEveryone()
		local allPlayers = ents.GetAllPlayers()
		
		local greyPlayers = {}
		
		local everyoneElse = {}	
		
		local disableSpawns = ents.FindByName("forceDisableSpawns")
		
		disableSpawns:AcceptInput("Trigger")		
		
		for _, player in pairs(allPlayers) do
			--print(player)
			if player.m_iTeamNum == 1 and player:IsAlive() then
				table.insert(greyPlayers, player)
				player:AddCond(5, 99, player)
				player:AddCond(71, 99, player)			
			elseif player:IsAlive() or player:IsRealPlayer() then
				table.insert(everyoneElse, player)
				--print("Put player " .. player.m_szNetname .. " into table")
				print(player.m_iTeamNum)
			end	
		end

		local fade = ents.FindByName("lose_fade")
		local fadeAnnihilation = ents.FindByName("lose_fade_annihilation")
		local botsWin = ents.FindByName("bots_Win")

		
		fade:AcceptInput("Fade")

		timer.Simple(3.25, function()
				for _, player in pairs(everyoneElse) do
						player:AcceptInput("$PlaySoundToSelf", "weapons/teleporter_send.wav")
					timer.Simple(0.25, function()
						player:AcceptInput("$PlaySoundToSelf", "weapons/teleporter_send.wav")
					end)
					timer.Simple(0.5, function()
						player:AcceptInput("$PlaySoundToSelf", "weapons/teleporter_send.wav")
					end)					
				end			
				for _, player in pairs(greyPlayers) do
						local teleParticle = ents.CreateWithKeys("info_particle_system", {
							effect_name = "teleportedin_blue",
							start_active = 1,
							flag_as_weather = 0,
						}, true, true)				
						teleParticle:SetAbsOrigin(player:GetAbsOrigin())
						teleParticle:Start()		

						local teleParticle2 = ents.CreateWithKeys("info_particle_system", {
							effect_name = "wrenchmotron_teleport_beam",
							start_active = 1,
							flag_as_weather = 0,
						}, true, true)				
						teleParticle2:SetAbsOrigin(player:GetAbsOrigin())
						teleParticle2:Start()	
						timer.Simple(1, function()
							player:AddCond(66, 99, player)		
							teleParticle:Remove()
							teleParticle2:Remove()
							if player.m_bIsMiniBoss == 0 then
								player:BotCommand("despawn")
							end
						end)				
				end

			fadeAnnihilation:AcceptInput("Fade")
		
			local sufferingTable = {
				Attacker = nil, -- Attacker
				Inflictor = nil, -- Direct cause of damage, usually a projectile
				Weapon = nil,
				Damage = 60000,
				DamageType = nil, -- Damage type, see DMG_* globals. Can be combined with | operator
				DamageCustom = nil, -- Custom damage type, see TF_DMG_* globals
				CritType = 2, -- Crit type, 0 = no crit, 1 = mini crit, 2 = normal crit
				DamagePosition = nil, -- Where the target was hit at
				DamageForce = nil, -- Knockback force of the attack
				ReportedPosition = nil -- Where the attacker attacked from
			}
			
			for _, player in pairs(everyoneElse) do
				player:TakeDamage(sufferingTable)
				if player:IsAlive() then
					player:Suicide()
				end
				--print("Killed " .. player.m_szNetname)
				player:AcceptInput("$PlaySoundToSelf", "giant_deathlaser_impact.mp3")
			end
			botsWin:AcceptInput("RoundWin")

			
		end)
end

--Thank you royal, once again
AddEventCallback("mvm_reset_stats", function ()
	--print("cleaning up leftover lasers")

	for _, laser in pairs(ents.FindAllByName("le_laser*")) do
		local ownerId = tostring(string.match(laser:GetName(), "%d+"))

		local pointer = ents.FindByName("le_laserpointer" .. ownerId)

		--print(ownerId, pointer)
		pcall(function ()
			hideLaser(laser, pointer)
		end)

		timer.Simple(1, function()
			laser:Remove()
			if pointer and IsValid(pointer) then
				pointer:Remove()
			end
		end)
	end
end)

function GreySpawnFire(_, activator)

	activator:AddOutput("BaseVelocity 0 0 700")

end

