local CRIT_CONDS = { 11, 34, 40, 44, 56, 105 }
local MINI_CRIT_CONDS = { 11, 34, 40, 44, 56, 105 }

local callbacks = {}
local botTypesData = {}
local botTypesTimers = {}

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

function ClearBotTimers(index, activator, handle)
	handle = handle or activator:GetHandleIndex()

	local weaponTimer = botTypesTimers[index][handle]

	if not weaponTimer then
		return
	end

	for _, timerId in pairs(weaponTimer) do
		timer.Stop(timerId)
	end

	botTypesTimers[index][handle] = nil
end

function MonoculusDeathHandle(_, tank)
	tank:AddCallback(ON_DAMAGE_RECEIVED_POST, function (_, damageInfo)
		local damage = damageInfo.Damage

		local curHealth = tank.m_iHealth

		local isLethal = curHealth - (damage + 1) <= 0

		if not isLethal then
			return
		end

		util.ParticleEffect("eyeboss_death", tank:GetAbsOrigin(), Vector(0, 0, 0))

		tank:Remove()
	end)
end

function CritPickup(pickupPropName, activator)
	local pickupProp = ents.FindByName(pickupPropName)

	pickupProp:HideTo(activator)
end

function DroneRangerProjectileSetOwner(sentryName, projectile)
	local owner = projectile.m_hOwnerEntity

	local sentryEnt = ents.FindByName(sentryName)

	sentryEnt.m_hBuilder = owner
end

-- only spawn 1 pair a time
local waitingCarrier
local waitingCarried
local waitingHeight

-- just in case
function OnWaveInit()
	waitingCarrier = nil
	waitingCarried = nil
	waitingHeight = nil
end

local function pair()
	local carrier = waitingCarrier
	local carried = waitingCarried
	local height = tonumber(waitingHeight)

	local handle = carrier:GetHandleIndex()

	local carrierCallbacks = {}
	local carrierTimers = {}

	local lastOrigin
	local function teleport()
		if not IsValid(carrier) then
			if not lastOrigin then
				return
			end

			-- prevents carried briefly disappearing after carrier death
			carried:SetAbsOrigin(lastOrigin + Vector(0, 0, height))

			return
		end

		local origin = carrier:GetAbsOrigin()
		carried:SetAbsOrigin(origin + Vector(0, 0, height))

		lastOrigin = origin
	end

	carrierTimers.teleport = timer.Create(0, function()
		teleport()
	end, 0)

	teleport()

	carrierCallbacks.died = carrier:AddCallback(ON_DEATH, function()
		timer.Simple(2, function ()
			carried:SetAttributeValue("no_attack", nil)
		end)

		-- carried:ClearFakeParent()
		ClearBottypeCallbacks("Pairs", carrier, handle)
		ClearBotTimers("Pairs", carrier, handle)

		if not lastOrigin then
			return
		end

		-- suspend in place to prevent source jank from teleporting it back to spawn
		local iterated = 1
		for i = 0, 1, 0.1 do
			timer.Simple(0.07 * iterated, function()
				carried:SetAbsOrigin(lastOrigin)
			end)

			iterated = iterated + 1
		end

		-- local top = lastOrigin + Vector(0, 0, height)
		-- for i = 0, 1, 0.1 do
		-- 	timer.Simple(0.07 * iterated, function ()
		-- 		carried:SetAbsOrigin(top)
		-- 	end)

		-- 	iterated = iterated + 1
		-- end

		-- carried:ChangeAttributes("NotCarried")

		-- if not lastOrigin then
		-- 	return
		-- end

		-- local iterated = 1
		-- local top = lastOrigin + Vector(0, 0, height)
		-- for i = 0, 1, 0.05 do
		-- 	timer.Simple(0.015 * iterated, function ()
		-- 		carried:SetAbsOrigin(top - Vector(0, 0, height * i))
		-- 	end)

		-- 	iterated = iterated + 1
		-- end
	end)
	carrierCallbacks.spawn = carrier:AddCallback(ON_SPAWN, function()
		ClearBottypeCallbacks("Pairs", carrier, handle)
		ClearBotTimers("Pairs", carrier, handle)
	end)

	waitingCarrier = nil
	waitingCarried = nil
	waitingHeight = nil

	callbacks.Pairs[handle] = carrierCallbacks
	botTypesTimers.Pairs[handle] = carrierTimers
end

function PairCarrierSpawn(height, activator)
	waitingCarrier = activator
	waitingHeight = height

	if waitingCarried then
		pair()
		return
	end
end
function PairCarriedSpawn(_, activator)
	waitingCarried = activator

	activator:SetAttributeValue("no_attack", 1)

	if waitingCarrier then
		pair()
		return
	end
end

-- teleport back to spawn instead of dying
function UndyingActivate(rechargeTime, activator, handle)
	activator:ChangeAttributes("Recharging")
	activator:AcceptInput("$TeleportToEntity", "spawnbot")

	activator:SetAttributeValue("health regen", botTypesData.Undying[handle].MaxHealth / rechargeTime)

	botTypesData.Undying[handle].Recharging = true

	local allPlayers = ents.GetAllPlayers()

	local recallText = "{blue}"
		.. activator:GetPlayerName()
		.. "{reset} has used their {9BBF4D}RECALL{reset} Power Up Canteen!"

	for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", recallText)
		player:AcceptInput("$PlaySoundToSelf", "=35|mvm/mvm_used_powerup.wav")
	end

	local undyingFirstDeathSpawn = ents.FindByName("undying_first_death")
	undyingFirstDeathSpawn:AcceptInput("Enable")

	timer.Simple(rechargeTime + 1.1, function()
		activator:SetAttributeValue("health regen", 0)
		activator:ChangeAttributes("Default")
		botTypesData.Undying[handle].Recharging = false
	end)
end

function UndyingSpawn(rechargeTime, activator)
	rechargeTime = tonumber(rechargeTime)

	local handle = activator:GetHandleIndex()

	-- if callbacks.Undying[handle] then
	-- 	UndyingEnd(activator, handle)
	-- end

	botTypesData.Undying[handle] = { MaxHealth = activator.m_iHealth, Recharging = false }

	callbacks.Undying[handle] = {}

	local undyingCallbacks = callbacks.Undying[handle]

	-- on damage
	undyingCallbacks.onDamagePre = activator:AddCallback(3, function(_, damageInfo)
		-- just in case
		if not activator:IsAlive() then
			return
		end

		if botTypesData.Undying[handle].Recharging then
			-- damageInfo.Damage = 0
			return
		end

		activator:AddCond(TF_COND_PREVENT_DEATH)

		local curHealth = activator.m_iHealth

		-- can't detect crit damage, assume all damage are crit instead for fatal check
		local damage = damageInfo.Damage * 3.1

		if curHealth - (damage + 1) <= 0 then
			damageInfo.Damage = 0
			damageInfo.DamageType = DMG_GENERIC
			-- damageInfo.CritType = 0

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

		return true
	end)

	undyingCallbacks.onDeath = activator:AddCallback(9, function()
		print("died")
		-- activator:AcceptInput("$SetProp$m_bUseBossHealthBar", "0")
		activator.m_bUseBossHealthBar = 0
		UndyingEnd(activator, handle)
	end)

	undyingCallbacks.onSpawn = activator:AddCallback(1, function()
		print("spawned")
		UndyingEnd(activator, handle)
	end)
end

function UndyingEnd(activator, handle)
	ClearBottypeCallbacks("Undying", activator, handle)
	ClearBottypeData("Undying", activator, handle)
end
