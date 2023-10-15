local DMG_CRITICAL = 1048576

local CRIT_CONDS = { 11, 34, 40, 44, 56, 105 }
local MINI_CRIT_CONDS = { 11, 34, 40, 44, 56, 105 }

local REJECTION_RADIUS = 450 --test out!
local REJECTION_CLASSES = {"player", "obj_*"}

local callbacks = {}
local botTypesData = {}
local botTypesTimers = {}
local runnerPhase = 1

local classIndices_Internal = {
	[1] = "Scout",
	[3] = "Soldier",
	[7] = "Pyro",
	[4] = "Demo", --was "demoman"
	[6] = "Heavy",
	[9] = "Engineer",
	[5] = "Medic",
	[2] = "Sniper",
	[8] = "Spy",
}

local CUSTOM_WEAPONS_INDICES = { "Gambler", "Thumper" }
for _, weaponIndex in pairs(CUSTOM_WEAPONS_INDICES) do
	callbacks[weaponIndex] = {}
end

local CUSTOM_BOTTYPES_INDICES = { "Undying", "Pairs" }
for _, botTypeIndex in pairs(CUSTOM_BOTTYPES_INDICES) do
	callbacks[botTypeIndex] = {}
	botTypesData[botTypeIndex] = {}
	botTypesTimers[botTypeIndex] = {}
end

function ClearBottypeCallbacks(index, activator, handle)
	handle = handle or activator:GetHandleIndex()

	local botTypeCallbacks = callbacks[index][handle]

	if not botTypeCallbacks then
		return
	end

	for _, callbackId in pairs(botTypeCallbacks) do
		activator:RemoveCallback(callbackId)
	end

	callbacks[index][handle] = nil
end

function ClearBottypeData(index, activator, handle)
	handle = handle or activator:GetHandleIndex()

	local botTypeData = botTypesData[index][handle]

	if not botTypeData then
		return
	end

	botTypesData[index][handle] = nil
end

function ClearCallbacks(index, activator, handle)
	handle = handle or activator:GetHandleIndex()

	local weaponCallbacks = callbacks[index][handle]

	if not weaponCallbacks then
		return
	end

	if activator and IsValid(activator) then
		for _, callbackId in pairs(weaponCallbacks) do
			activator:RemoveCallback(callbackId)
		end
	end

	callbacks[index][handle] = nil
end
-- Wave 3
function SpawnTele(_,activator)
	local traceStartPos = activator:GetAbsOrigin()
	local traceInfo = util.Trace({
		start = traceStartPos,
		angles = Vector(90,0,0),
	})
	if traceInfo.HitWorld then
		ents.SpawnTemplate("PortableTeleportCreater", {
			translation = traceInfo.HitPos,
		})
	end
end

function TeleInParticle(_,activator)
	util.ParticleEffect("teleportedin_blue", activator:GetAbsOrigin())
end

function SwordSummonFire(_,activator)
	local swordOwner = activator:GetHandleIndex()
	
	if not swordOwner then
		return
	end
	
	local weaponMimics = ents.FindAllByName("sword_mimic*")
	
	for _,mimic in pairs(weaponMimics) do
		if mimic.m_hOwnerEntity:GetHandleIndex() == swordOwner then
			mimic:FireUser1() --logic inside the mimic handles the firing
		end
	end
end

function StickyMimicActivate(_,activator)
    local stickyMimic = ents.FindByName("sticky_mimic")
    
    if not stickyMimic then
        return
    end
    
    local n = 0
    timer.Create(0.2, function()
        if not stickyMimic then 
            return
        end
        
        local allAngles = stickyMimic:GetAbsAngles()
        
        --Change the "rotation" value on the horizontal axis
        --Check if this really is y, please!
        allAngles[2] = n * 60
        
		
		-- util.PrintToChatAll("Firing at angle: "..tostring(allAngles))
		
        stickyMimic:SetLocalAngles(allAngles)
        stickyMimic:FireOnce()
        
        n = n + 1
    end, 6)
    
    timer.Simple(2.4, function()
        if not stickyMimic then 
            return
        end
        
        stickyMimic:DetonateStickies()
    end)
end

-- Wave 4
local currentBombSection = front
local changedBombSection = false

function UpdateBombSection(sectionName)
	-- util.PrintToChatAll("Updating bomb section to "..sectionName)
	currentBombSection = sectionName
end

-- teleport back to spawn instead of dying
function UndyingActivate(rechargeTime, activator, handle)
	
	local bomb = ents.FindByName("intel")
	bomb:ForceDrop()
	
	activator:ChangeAttributes("Recharging")
	activator:AcceptInput("$TeleportToEntity", "spawnbot")

	-- activator:SetAttributeValue("health regen", botTypesData.Undying[handle].MaxHealth / rechargeTime)
	local regenTimer = timer.Create(1, function()
		activator:AddHealth(botTypesData.Undying[handle].MaxHealth / rechargeTime, false)
	end, rechargeTime, _)

	botTypesData.Undying[handle].Recharging = true

	local allPlayers = ents.GetAllPlayers()

	local recallText = "{blue}"
		.. activator:GetPlayerName()
		.. "{reset} has used their {9BBF4D}RECALL{reset} Power Up Canteen!"

	for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", recallText)
		player:AcceptInput("$PlaySoundToSelf", "=35|mvm/mvm_used_powerup.wav")
	end

	-- Enables a spawn to check for first death.
	-- Unused for now.
	-- local undyingFirstDeathSpawn = ents.FindByName("undying_first_death")
	-- undyingFirstDeathSpawn:AcceptInput("Enable")

	-- After recharge time + 1.1 second, return to Default behavior
	timer.Simple(rechargeTime + 1.1, function()
		-- activator:SetAttributeValue("health regen", 0)
		activator:ChangeAttributes("Default")
		botTypesData.Undying[handle].Recharging = false
	end)
end

function UndyingSpawn(rechargeTime, activator)
	rechargeTime = tonumber(rechargeTime)

	local handle = activator:GetHandleIndex()
	
	botTypesData.Undying[handle] = { MaxHealth = activator.m_iHealth, Recharging = false, Section = "front" }
	
	if classIndices_Internal[activator.m_iClass] == "Heavy" then
		botTypesData.Undying[handle].Section = "front"
		
	elseif classIndices_Internal[activator.m_iClass] == "Demo" then
		botTypesData.Undying[handle].Section = "mid"
	
	elseif classIndices_Internal[activator.m_iClass] == "Scout" then
		botTypesData.Undying[handle].Section = "hatch"
		
	end

	callbacks.Undying[handle] = {}
	local undyingCallbacks = callbacks.Undying[handle]

	-- on damage
	undyingCallbacks.onDamagePre = activator:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageInfo)
		-- just in case
		if not activator:IsAlive() then
			return
		end

		if botTypesData.Undying[handle].Recharging then
			return
		end
		
		if botTypesData.Undying[handle].Section == currentBombSection then
			-- util.PrintToChatAll("Bomb is in the same section!")
			activator:AddCond(TF_COND_PREVENT_DEATH)

			local curHealth = activator.m_iHealth
			
			local damage = damageInfo.Damage
			if (damageInfo.DamageType & DMG_CRITICAL > 0) then
				damage = damageInfo.Damage * 3.1
			end

			if curHealth - (damage + 1) <= 0 then
				damageInfo.Damage = 0
				damageInfo.DamageType = DMG_GENERIC

				botTypesData.Undying[handle].Recharging = true

				-- set health to 1
		local setHealthDmgInfo = {
			Attacker = damageInfo.Attacker,
			Inflictor = damageInfo.Inflictor,
			Weapon = damageInfo.Weapon,
			Damage = curHealth - 1,
			CritType = 0,
			DamageType = damageInfo.DamageType,
			DamageCustom = damageInfo.DamageCustom,
			DamagePosition = damageInfo.DamagePosition,
			DamageForce = damageInfo.DamageForce,
			ReportedPosition = damageInfo.ReportedPosition,
		}

				activator:TakeDamage(setHealthDmgInfo)
				
				UndyingActivate(rechargeTime, activator, handle)

				return true
			end
		
		else --Bomb has changed sections, we can safely die.
			-- activator:RemoveCond(TF_COND_PREVENT_DEATH) Keeping the trolly anti-1 hit for now
			-- util.PrintToChatAll("Bomb has moved sections!")
			return true
		end
		
		return true
	end)

	undyingCallbacks.onDeath = activator:AddCallback(ON_DEATH, function()
		print("died")
		activator.m_bUseBossHealthBar = 0
		UndyingEnd(activator, handle, currentBombSection)
	end)

	undyingCallbacks.onSpawn = activator:AddCallback(ON_SPAWN, function()
		print("spawned")
		UndyingEnd(activator, handle, currentBombSection)
	end)
end

function UndyingEnd(activator, handle, section)
	ClearBottypeCallbacks("Undying", activator, handle)
	ClearBottypeData("Undying", activator, handle)
	
	local spawnsToDisable = ents.FindAllByName("spawnbot_undying*")
	for _,spawn in pairs(spawnsToDisable) do
		-- util.PrintToChatAll("Disabled spawn "..spawn:GetName().."!")
		spawn:Disable()
	end
	
	local spawnToEnable = ents.FindByName("spawnbot_undying_"..section)
	spawnToEnable:Enable()
	-- util.PrintToChatAll("Enabled spawn "..spawnToEnable:GetName().."!")
end

function ReverseGravity(_,activator) -- == caller
	--Ensure we're targeting a player, npc, or building.
	
	local disableGravity = ents.FindByName("filter_gravityless")
	local enableGravity = ents.FindByName("filter_gravityful")
	
	if not activator:IsCombatCharacter() then
		return
	end
	--Ensure they're on red.
	if activator.m_iTeamNum ~= 2 then
		return
	end
	
	if activator:IsObject() then
		-- Unless they're being carried. I'm not a monster, you can get rewarded for being a little creative.
		if activator.m_bCarried == 1 then
			return
		end
		activator.m_bDisabled = 1
		activator.m_bHasSapper = 1
		activator:AcceptInput("TakeDamage", activator.m_iHealth / 5)
		timer.Simple(4, function()
			if activator then --Verify that the building is still alive!
				activator.m_bDisabled = 0
				activator.m_bHasSapper = 0
			end
		end)
	end
	
	if activator:IsPlayer() then
		
		disableGravity:AcceptInput("TestActivator",_,activator)
		activator:AddOutput("BaseVelocity 0 0 330")
		
		activator:AcceptInput("TakeDamage", activator.m_iHealth / 5)
		activator:SetAttributeValue("dmg taken increased", 1.3)
		
		local playerLived = true
		
		local playerTimer = timer.Create(0.1, function()
			if not activator then
				return false
			end
			if not activator:IsAlive() then
				playerLived = nil
			end
			if activator.m_hGroundEntity ~= nil then
				playerLived = nil
			end
		end, 15)
		
		timer.Simple(1.5, function()
			if activator then -- Does the player still exist?

				if playerLived then -- Did the player survive while in the air?
					
					if activator:IsAlive() then -- If yes, are they still alive?
						enableGravity:AcceptInput("TestActivator",_,activator)
						activator:AddOutput("BaseVelocity 0 0 -1250")
						activator:SetAttributeValue("dmg taken increased", 1)
						
					else -- If the player is dead, reset their gravity
						enableGravity:AcceptInput("TestActivator",_,activator)
						
					end
					
				else -- If the player died mid-air, reset their gravity
					enableGravity:AcceptInput("TestActivator",_,activator)
				end
			end
		end)
	end
end

function Rejection(_, activator)
	-- util.PrintToChatAll("Rejecting!")
	
	local bossOrigin = activator:GetAbsOrigin()
	local rejectionFired = false
	
	for _, class in pairs(REJECTION_CLASSES) do
		for _, ent in pairs(ents.FindAllByClass(class)) do
			--Ensure we're targeting a player, npc, or building.
			if not ent:IsCombatCharacter() then
				goto continue
			end
			--Ensure they're on red.
			if ent.m_iTeamNum ~= 2 then
				goto continue
			end
			
			local enemyOrigin = ent:GetAbsOrigin()
			
			local traceToBoss = {
				start = bossOrigin,
				endpos = enemyOrigin,
				distance = 8192,
				angles = Vector(0,0,0),
				mask = MASK_SOLID,
				collisiongroup = COLLISION_GROUP_NONE, -- Pretend the trace to be fired by an entity belonging to this group
			}
			
			local traceToBossTable = util.Trace(traceToBoss)
			--Something's between us and the player! Cancel!
			if not traceToBossTable["Entity"]:IsValid() then
				-- util.PrintToChatAll("Hit an invalid entity, cancel!")
				goto continue
			end
			
			-- if traceToBossTable["Entity"]:IsPlayer() then
				-- util.PrintToChatAll("Hit entity: "..traceToBossTable["Entity"]:GetPlayerName())
			-- end
			
			local dist = traceToBossTable["HitPos"]:Distance(enemyOrigin)
			
			-- util.PrintToChatAll("The distance is "..tostring(dist))
								
			--The player is out of our radius! No effect!
			if dist > REJECTION_RADIUS then
				-- util.PrintToChatAll("Out of range!")
				goto continue
			end
			
			-- If they're a building, stun/disable them briefly.
			if ent:IsObject() then
				-- Unless they're being carried. I'm not a monster, you can get rewarded for being a little creative.
				if ent.m_bCarried == 1 then
					goto continue
				end
				ent.m_bDisabled = 1
				ent.m_bHasSapper = 1
				timer.Simple(4, function()
					if ent then --Verify that the building is still alive!
						ent.m_bDisabled = 0
						ent.m_bHasSapper = 0
					end
				end)
				rejectionFired = true
				-- util.PrintToChatAll("Building in radius!")
				goto continue
			end
			
			if ent:IsPlayer() then
				local pushEntity = ents.FindByName("boss_push")
				pushEntity:Enable()
				ent:AddOutput("BaseVelocity 0 0 300")
				timer.Simple(0.1, function()
					pushEntity:Disable()
				end)
				rejectionFired = true
				-- util.PrintToChatAll("Player in radius!")
			end
			
			::continue::
		end
	end
	
	if rejectionFired then
		-- util.PrintToChatAll("Target succesfully rejected!")
		-- powercore_embers_blue, powerup_supernova_explode_blue
		util.ParticleEffect("powerup_supernova_explode_blue", bossOrigin)
	end
end

function LightningStrike(_,activator)
	
	local allPlayers = ents.GetAllPlayers()
	local bossOrigin = activator:GetAbsOrigin()
	
	for _, player in pairs(allPlayers) do
		
		if player.m_iTeamNum ~= 2 then
			goto continue
		end
		
		if not player:IsAlive() then
			goto continue
		end
		-- util.PrintToChatAll("Smiting "..player:GetPlayerName().."!")
		
		if bossOrigin:Distance(player:GetAbsOrigin()) > 576 then
			goto continue
		end
		
		-- util.ParticleEffect("utaunt_electric_mist_parent", player:GetAbsOrigin())
		local particle = ents.CreateWithKeys("info_particle_system", {
			effect_name = "utaunt_electric_mist_parent",
			start_active = 1,
		}, true, true)
		
		local targetOrigin = player:GetAbsOrigin()
		particle:SetAbsOrigin(targetOrigin)
		
		timer.Simple(1.2, function()
			
			local mimic = ents.CreateWithKeys("tf_point_weapon_mimic", {
				["$preventshootparent"] = 1,
				TeamNum = activator.m_iTeamNum,
				["$weaponname"] = "Lightning Launcher", --Lightning Launcher
				["$firetime"] = 1,
			}, true, true)
			-- mimic["$SetOwner"](mimic, activator)
			
			local mimicOrigin = targetOrigin
			mimicOrigin.z = mimicOrigin.z + 90
			mimic:SetAbsOrigin(mimicOrigin)
			
			mimic:SetAbsAngles(Vector("90 0 0"))

			particle:Stop()
			particle:Remove()
			
			mimic:FireOnce()
			timer.Simple(0.2, function()
				mimic:Remove()
			end)
		end)
		
		::continue::
	end
end

function OnSCOrbSpawned(entity)
	local targetEntity = ents.FindByName("boss_target")
	if not targetEntity then
		return
	end
	
	local owner = entity.m_hOwnerEntity
	if not owner:IsValid() then
		return
	end
	
	local origin = entity:GetAbsOrigin()
	
	for _,target in pairs(ents.FindInSphere(origin, 900)) do
		if target == targetEntity then
			
			if owner.m_iAmmo[4] > 130 then
				owner.m_iAmmo[4] = owner.m_iAmmo[4] - 130
			
			else
				owner.m_iAmmo[4] = 0
			end
			
		end
	end
end

function OnSCOrbCreated(entity,classname)
	entity:AddCallback(ON_SPAWN, OnSCOrbSpawned)
end

ents.AddCreateCallback("tf_projectile_mechanicalarmorb", function(entity, classname)
	OnSCOrbCreated(entity,classname)
end)
	
	-- local targetEntity = ents.FindByName("boss_target")
	-- if not targetEntity then
		-- return
	-- end
	
	-- if ANTI_DEFLECT_ACTIVE == 0 then
		-- return
	-- end
	
	-- timer.Simple(0.1, function() --MAYBE the owner isn't immediately set??
		-- local owner = orb.m_hOwnerEntity
		
		-- if not owner:IsValid() then
			-- return
		-- end
		
		-- if owner.m_iAmmo[3] >= 130 then
			-- owner.m_iAmmo[3] = owner.m_iAmmo[3] - 65
		-- end
	-- end)
	-- local orbTimer
	-- orbTimer = timer.Create(0.05, function()
		
		-- if not orb:IsValid() then
			-- timer.Stop(orbTimer)
		-- end
		
		-- local origin = orb:GetAbsOrigin()
		-- for _,target in pairs(ents.FindInSphere(, 180)) do
			-- if target == targetEntity then
				-- orb:Kill()
			-- end
		-- end
	-- end, 20)
-- end)