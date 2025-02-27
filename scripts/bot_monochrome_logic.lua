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

	check = timer.Create(0.015, function()

		if not IsValid(activator) or not activator:IsAlive() then
			terminate()
			return
		end			
		
		if activator:GetAttributeValue("sniper no headshots", false) == 1 then
				
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
					primary.m_iClip1 = maxClip			
					secondary:SetAttributeValue("disable weapon switch", 0)							
					activator:WeaponSwitchSlot(0)			
				end, 1)
			end		
		end

		if not activator:InCond(6) then
			if started then
				hideLaser(laser, pointer)

				started = false
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

	activator:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageInfo)
		-- just in case
		if not activator:IsAlive() then
			return
		end
		
		local curHealth = activator.m_iHealth
		local damage = damageInfo.Damage

		--anti lava suicide clause.
		if (damage == 99999.0) then
			--print("We tripped this clause")
			damageInfo.Damage = 0
			damageInfo.DamageType = DMG_GENERIC
			activator:SetAbsOrigin((Vector(-1674.74, -1130.49, 111.72)))
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
			timer.Simple(1, function()
				teleParticle:Remove()
			end)
				local setHealthDmgInfo = {
					Attacker = damageInfo.Attacker,
					Inflictor = damageInfo.Inflictor,
					Weapon = damageInfo.Weapon,
					Damage = 0,
					CritType = 0,
					DamageType = damageInfo.DamageType,
					DamageCustom = damageInfo.DamageCustom,
					DamagePosition = damageInfo.DamagePosition,
					DamageForce = damageInfo.DamageForce,
					ReportedPosition = damageInfo.ReportedPosition,
				}
				--print(setHealthDmgInfo.Damage)
				activator:TakeDamage(setHealthDmgInfo)				
			return true
		end			
			
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
							activator:BotCommand("despawn")	
							terminate()		
						end)
								
					end
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
	callbacks.waveReset = AddEventCallback("mvm_reset_stats", function ()
		terminate()	
	end)	
end
