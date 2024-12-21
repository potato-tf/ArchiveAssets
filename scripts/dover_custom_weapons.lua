local REDEEMER_HIT_DEBOUNCE = 10
local REDEEMER_HIT_DAMAGE = 50
-- local REDEEMER_HIT_DAMAGE_ADDITION = 10 -- increased each hit
-- local REDEEMER_HIT_DAMAGE_ADDITION_CAP = 50

local REDEEMER_HIT_DAMAGE_ADDITION_MULT_ADDITIVE = 1 -- increased each hit
local REDEEMER_HIT_DAMAGE_ADDITION_CAP_ADDITIVE = 10

local WINGER_COOLDOWN = 3

local DRONES_CAP = 2

local PHD_THRESHOLD = {
	["Small"] = -100,
	["Medium"] = 1,
	["Medium2"] = 1.8,
	["Large"] = 2.4,
	["Nuke"] = 4,
}

local PHD_EXPLOSIONS = {
	["Small"] = { Particle = "hammer_impact_button", Radius = 144, Damage = 50 },
	["Medium"] = { Particle = "ExplosionCore_buildings", Radius = 144, Damage = 125 },
	["Medium2"] = { Particle = "ExplosionCore_Wall", Radius = 144, Damage = 200 },
	["Large"] = { Particle = "ExplosionCore_Wall", Radius = 200, Damage = 250 }, --asplode_hoodoo, adjusted for minicrits
	["Nuke"] = { Particle = "skull_island_explosion", Radius = 600, Damage = 700 },
}

local PHD_FEEDBACK_CONDS = {
	-- ["Medium"] = TF_COND_SNIPERCHARGE_RAGE_BUFF,
	["Large"] = TF_COND_OFFENSEBUFF,
	["Nuke"] = TF_COND_CRITBOOSTED_CARD_EFFECT,
}

local PARRY_TIME = 0.8

local SCAVENGER_EXPLOSION_BASE_DAMAGE = 85
local SCAVENGER_EXPLOSION_BASE_DAMAGE_BOSS = 175

local classIndices_Internal = {
	[1] = "Scout",
	[3] = "Soldier",
	[7] = "Pyro",
	[4] = "Demoman",
	[6] = "Heavy",
	[9] = "Engineer",
	[5] = "Medic",
	[2] = "Sniper",
	[8] = "Spy",
}

local function findInTable(table, value)
	for i, v in pairs(table) do
		if v == value then
			return i
		end
	end
end

local function dictionaryLength(dictionary)
	local length = 0

	for i, _ in pairs(dictionary) do
		length = length + 1
	end

	return length
end

local callbacks = {}
local weaponsData = {}
local weaponTimers = {}

local CUSTOM_WEAPONS_INDICES = { "Parry", "Drone", "PHD", "SmolShield", "WingerDash", "Scavenger" }
for _, weaponIndex in pairs(CUSTOM_WEAPONS_INDICES) do
	callbacks[weaponIndex] = {}
	weaponsData[weaponIndex] = {}
	weaponTimers[weaponIndex] = {}
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

function ClearData(index, activator, handle)
	handle = handle or activator:GetHandleIndex()

	local weaponData = weaponsData[index][handle]

	if not weaponData then
		return
	end

	weaponsData[index][handle] = nil
end

function ClearTimers(index, activator, handle)
	handle = handle or activator:GetHandleIndex()

	local weaponTimer = weaponTimers[index][handle]

	if not weaponTimer then
		return
	end

	for _, timerId in pairs(weaponTimer) do
		timer.Stop(timerId)
	end

	weaponTimers[index][handle] = nil
end

function NoMercyFailSafe(exEntName, activator, caller)
	local primary = activator:GetPlayerItemBySlot(0)

	if primary == nil then
		return
	end

	local exEnt = ents.FindByName(exEntName)

	exEnt:Remove()
	caller:Remove()
	activator.m_flGravity = 0
end

function InstaLvLRefunded(_, activator)
	activator.InstantLevel = false
end
function InstaLvLPurchase(_, activator)
	activator.InstantLevel = true
end

function BuildingBuilt(_, building)
	if building.m_iHighestUpgradeLevel >= 2 then
		return
	end

	if building.m_bMiniBuilding ~= 0 then
		return
	end

	if building.m_bDisposableBuilding ~= 0 then
		return
	end

	local owner = building.m_hBuilder

	if not owner.InstantLevel then
		return
	end

	building.m_iHighestUpgradeLevel = 2
end

local cooldown_players = {}

local function _getPlayerCameraAngleUp(player)
	local pitch = player["m_angEyeAngles[0]"]

	return Vector(0, 0, -pitch)
end

local function _dash(player)
	local handle = player:GetHandleIndex()

	if cooldown_players[handle] then
		return
	end

	cooldown_players[handle] = true

	local secondary = player:GetPlayerItemBySlot(1)
	secondary:SetAttributeValue("add cond when active", nil)

	timer.Simple(WINGER_COOLDOWN, function()
		cooldown_players[handle] = nil

		if IsValid(secondary) then
			secondary:SetAttributeValue("add cond when active", TF_COND_SNIPERCHARGE_RAGE_BUFF)
		end
	end)

	local angle = _getPlayerCameraAngleUp(player)

	player:SetForwardVelocity(1000)
	player:AddOutput("BaseVelocity " .. tostring(angle * 10))
end

function WingerDashPurchased(_, activator)
	local handle = activator:GetHandleIndex()
	callbacks.WingerDash[handle] = {}

	local dashCallbacks = callbacks.WingerDash[handle]

	dashCallbacks.input = activator:AddCallback(ON_KEY_PRESSED, function(_, key)
		if key ~= IN_ATTACK2 then
			return
		end

		local secondary = activator:GetPlayerItemBySlot(1)
		local secondaryHandle = secondary:GetHandleIndex()

		if activator.m_hActiveWeapon:GetHandleIndex() ~= secondaryHandle then
			return
		end

		_dash(activator)
	end)

	dashCallbacks.died = activator:AddCallback(ON_DEATH, function()
		local secondary = activator:GetPlayerItemBySlot(1)

		if secondary:GetAttributeValue("cannot giftwrap") then
			return
		end

		WingerDashRefunded(_, activator)
	end)

	dashCallbacks.spawned = activator:AddCallback(ON_SPAWN, function()
		local secondary = activator:GetPlayerItemBySlot(1)

		if secondary:GetAttributeValue("cannot giftwrap") then
			return
		end

		WingerDashRefunded(_, activator)
	end)
end

function WingerDashRefunded(_, activator)
	if IsValid(activator) then
		ClearCallbacks("WingerDash", activator, activator:GetHandleIndex())
	end
end

function PersonalProjectileShieldRefunded(_, activator)
	if IsValid(activator) then
		ClearCallbacks("SmolShield", activator, activator:GetHandleIndex())
		ClearTimers("SmolShield", activator, activator:GetHandleIndex())
		activator.ShieldReplacementFlag = nil
	end
end

function PersonalProjectileShieldPurchase(_, activator)
	print("personal shield purchased")
	local handle = activator:GetHandleIndex()

	-- force it to level 2
	local medigun = activator:GetPlayerItemBySlot(1)
	local medigunHandle = medigun:GetHandleIndex()

	medigun:SetAttributeValue("generate rage on heal", 2)

	activator.ShieldReplacementFlag = true

	callbacks.SmolShield[handle] = {}
	weaponTimers.SmolShield[handle] = {}

	local shieldCallbacks = callbacks.SmolShield[handle]
	local shieldTimers = weaponTimers.SmolShield[handle]

	local function cancelEverything()
		if not IsValid(activator) then
			return
		end

		activator.ShieldReplacementFlag = nil

		ClearCallbacks("SmolShield", activator, handle)
		ClearTimers("SmolShield", activator, handle)
	end

	shieldCallbacks.removed = activator:AddCallback(ON_REMOVE, function()
		cancelEverything()
	end)

	shieldCallbacks.died = activator:AddCallback(ON_DEATH, function()
		if medigunHandle == activator:GetPlayerItemBySlot(1):GetHandleIndex() then
			return
		end

		cancelEverything()
	end)

	shieldCallbacks.spawned = activator:AddCallback(ON_SPAWN, function()
		if medigunHandle == activator:GetPlayerItemBySlot(1):GetHandleIndex() then
			return
		end

		cancelEverything()
	end)

	shieldTimers.DefaultCharge = timer.Create(0.1, function()
		if not IsValid(activator) then
			return true
		end

		SetDefaultShieldCharge(activator)
	end, 0)
end

-- smol shield replacement
function ReplaceAllMedigunShields()
	for _, shield in pairs(ents.FindAllByClass("entity_medigun_shield")) do
		if shield.Changed then
			goto continue
		end

		local shieldOwner = shield.m_hOwnerEntity

		if not shieldOwner or not IsValid(shieldOwner) then
			goto continue
		end

		if not shieldOwner.ShieldReplacementFlag then
			goto continue
		end

		shield.Changed = true

		shield:SetModel("models/props_mvm/mvm_comically_small_player_shield.mdl")

		::continue::
	end
end

--set shield charge to 25% whenever it'd be below that to mimic charging faster
function SetDefaultShieldCharge(activator)
	if activator.m_bRageDraining ~= 0 then
		return
	end

	if activator.m_flRageMeter >= 35 then
		return
	end

	activator.m_flRageMeter = 35
end

function OnGameTick()
	ReplaceAllMedigunShields()
end

local noReprogram = {}
function OnWaveSpawnBot(bot, _, tags)
	noReprogram[bot] = nil

	if not findInTable(tags, "no_reprogram") then
		return
	end

	noReprogram[bot] = true
end

local controlled = {}
function SeducerHit(_, activator, caller)
	if noReprogram[caller] then
		return
	end

	if not caller:IsPlayer() then
		return
	end

	if caller:IsRealPlayer() then
		return
	end

	if caller.m_bIsMiniBoss ~= 0 then
		return
	end

	if caller:InCond(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED) then
		return
	end

	if caller.m_iTeamNum == activator.m_iTeamNum then
		return
	end

	local handle = activator:GetHandleIndex()

	if controlled[handle] then
		return
	end

	controlled[handle] = caller

	caller:AddCond(TF_COND_REPROGRAMMED)
	caller:AddCond(TF_COND_CRITBOOSTED_CARD_EFFECT)

	local secondary = activator:GetPlayerItemBySlot(1)
	secondary:SetAttributeValue("add cond when active", nil)

	timer.Simple(8, function()
		controlled[handle] = nil
		caller:Suicide()

		if IsValid(secondary) then
			secondary:SetAttributeValue("add cond when active", TF_COND_SNIPERCHARGE_RAGE_BUFF)
		end
	end)
end

local redeemerDebounces = {} --value is debounce players

-- redeemer
ents.AddCreateCallback("tf_projectile_rocket", function(entity)
	timer.Simple(0, function()
		if not IsValid(entity) then
			return
		end

		local owner = entity.m_hOwnerEntity

		if not owner then
			return
		end

		if not owner.hasRedeemer or owner.hasRedeemer ~= 1 then
			return
		end

		-- not scout, just in case
		if owner.m_iClass ~= 1 then
			return
		end

		local extraDamageMult = 1

		local handle = entity:GetHandleIndex()

		redeemerDebounces[handle] = {}

		entity:AddCallback(0, function()
			redeemerDebounces[handle] = nil
		end)

		entity:AddCallback(16, function(_, target)
			if not target or not target:IsPlayer() then
				return true
			end

			if target == owner then
				return
			end

			local targetHandle = target:GetHandleIndex()

			local nextAllowedDamageTickOnTarget = redeemerDebounces[handle][targetHandle] or -1

			if CurTime() < nextAllowedDamageTickOnTarget then
				return false
			end

			local targetTeamnum = target._iTeamNum

			if targetTeamnum == owner.m_iTeamNum then
				return false
			end

			redeemerDebounces[handle][targetHandle] = CurTime() + REDEEMER_HIT_DEBOUNCE

			local secondary = owner:GetPlayerItemBySlot(1)

			local baseDamage = REDEEMER_HIT_DAMAGE
			local damageMult = secondary:GetAttributeValue("damage bonus") or 1

			local visualHitPost = target:GetAbsOrigin() + Vector(0, 0, 50)

			local damageInfo = {
				Attacker = owner,
				Inflictor = nil,
				Weapon = secondary,
				Damage = baseDamage * damageMult * extraDamageMult,
				DamageType = DMG_SHOCK,
				DamageCustom = 0,
				DamagePosition = visualHitPost,
				DamageForce = Vector(0, 0, 0),
				ReportedPosition = visualHitPost,
			}

			local dmg = target:TakeDamage(damageInfo)

			extraDamageMult = extraDamageMult + REDEEMER_HIT_DAMAGE_ADDITION_MULT_ADDITIVE

			if extraDamageMult > REDEEMER_HIT_DAMAGE_ADDITION_CAP_ADDITIVE then
				extraDamageMult = REDEEMER_HIT_DAMAGE_ADDITION_CAP_ADDITIVE
			end

			return false
		end)
	end)
end)

local SCAVENGER_DEFAULT_PROJECTILE_SPEED = 1.5
function ScavengerEquipped(_, activator)
	local handle = activator:GetHandleIndex()

	weaponTimers.Scavenger[handle] = {}
	callbacks.Scavenger[handle] = {}
	weaponsData.Scavenger[handle] = {}

	local timers = weaponTimers.Scavenger[handle]
	local data = weaponsData.Scavenger[handle]
	local scavengerCallbacks = weaponsData.Scavenger[handle]

	local primary = activator:GetPlayerItemBySlot(0)

	timers.ChargeCheck = timer.Create(0.1, function()
		data.ChargeMult = 1 + (primary.m_flChargedDamage / 150)
		primary:SetAttributeValue(
			"projectile speed increased",
			SCAVENGER_DEFAULT_PROJECTILE_SPEED * ((data.ChargeMult - 1) * 1.5 + 1)
		)
	end, 0)

	local function unequip()
		if not IsValid(activator) then
			activator = nil
		end

		ClearTimers("Scavenger", activator, handle)
		ClearCallbacks("Scavenger", activator, handle)
		ClearData("Scavenger", activator, handle)
	end

	scavengerCallbacks.onRemoved = activator:AddCallback(ON_REMOVE, function()
		unequip()
	end)

	scavengerCallbacks.onDeath = activator:AddCallback(ON_DEATH, function()
		unequip()
	end)

	scavengerCallbacks.onSpawn = activator:AddCallback(ON_SPAWN, function()
		unequip()
	end)
end

function SetScavengerMimicDamage(mimicName, projectile)
	if not IsValid(projectile) then
		return
	end

	local mimic = ents.FindByName(mimicName)

	local owner = mimic.m_hOwnerEntity
	local handle = owner:GetHandleIndex()

	local primary = owner:GetPlayerItemBySlot(0)

	local chargeMult = weaponsData.Scavenger[handle].ChargeMult

	local damageMult = (primary:GetAttributeValue("damage bonus") or 1) * chargeMult

	mimic.Damage = SCAVENGER_EXPLOSION_BASE_DAMAGE * damageMult
end
function SetScavengerMimicDamageBoss(mimicName, projectile)
	if not IsValid(projectile) then
		return
	end

	local mimic = ents.FindByName(mimicName)

	local owner = mimic.m_hOwnerEntity
	local primary = owner:GetPlayerItemBySlot(0)

	local damageMult = primary:GetAttributeValue("damage bonus") or 1

	mimic.Damage = SCAVENGER_EXPLOSION_BASE_DAMAGE_BOSS * damageMult
end

-- function ScavengerTeamCorrectionAttach(triggerName, activator)
-- 	local trigger = ents.FindByName(triggerName)

-- 	if activator.m_iTeamNum == 3 then
-- 		-- trigger["$SetKey$filtername"](trigger, "filter_is_red")
-- 		trigger.m_iFilterName = "filter_is_red"
-- 	end
-- end
function ScavengerTeamCorrectionAttachBlue(triggerName, activator)
	local trigger = ents.FindByName(triggerName)

	if activator.m_iTeamNum == 2 then
		trigger:Enable()
	end
end
function ScavengerTeamCorrectionAttachRed(triggerName, activator)
	local trigger = ents.FindByName(triggerName)

	if activator.m_iTeamNum == 3 then
		trigger:Enable()
	end
end
-- function ScavengerFired(detPosName, activator)
-- 	local detPos = ents.FindByName(detPosName)

-- 	detPos.ownerHolder = activator.m_hOwnerEntity
-- end
-- function ScavengerFlicker(detPosName)
-- 	local detPos = ents.FindByName(detPosName)

-- 	local owner = detPos.ownerHolder

-- 	local particle = Entity("info_particle_system", true)

-- 	local props = {
-- 		start_active = 1,
-- 		flag_as_weather = 0,
-- 		effect_name = owner.m_iTeamNum == 2 and "stickybomb_pulse_red" or "stickybomb_pulse_blue",
-- 	}

-- 	for propName, value in pairs(props) do
-- 		particle:AcceptInput("$SetKey$"..propName, value)
-- 	end

-- 	particle:Start()

-- 	timer.Simple(1, function ()
-- 		particle:Remove()
-- 	end)

-- 	-- if owner.m_iTeamNum == 2 then
-- 	-- 	util.ParticleEffect("stickybomb_pulse_red", detPos:GetAbsOrigin(), nil, detPos)
-- 	-- else
-- 	-- 	util.ParticleEffect("stickybomb_pulse_blue", detPos:GetAbsOrigin(), nil, detPos)
-- 	-- end
-- end
-- function ScavengerTeamCorrectionParticle(flickerName, activator)
-- 	local flicker = ents.FindByName(flickerName)

-- 	if activator.m_iTeamNum == 3 then
-- 		-- flicker["$SetKey$effect_name"](flicker, "stickybomb_pulse_blue")
-- 		flicker.m_iszEffectName = "stickybomb_pulse_blue"
-- 	end
-- end
function ScavengerTeamCorrectionSticky(_, sticky)
	timer.Simple(0, function()
		local owner = sticky.m_hOwnerEntity

		if owner.m_iTeamNum == 3 then
			sticky.m_iTeamNum = 3
		end
	end)
end

-- drone
function DroneFired(sentryName, projectile)
	local owner = projectile.m_hOwnerEntity

	local sentryEnt = ents.FindByName(sentryName)

	if owner.m_iTeamNum == 3 then
		timer.Simple(0, function()
			sentryEnt.m_nSkin = 1
		end)

		sentryEnt.m_iTeamNum = 3
	end

	timer.Simple(0.6, function()
		sentryEnt.m_hBuilder = owner
	end)

	local ownerHandle = owner:GetHandleIndex()

	local dronesData = weaponsData.Drone[ownerHandle]

	local dronesList = dronesData.DronesList

	if dictionaryLength(dronesList) >= dronesData.DronesCap then
		-- remove first drone
		-- automatically cleared from array
		dronesList[1]:Remove()
	end

	table.insert(dronesList, projectile)

	projectile:AddCallback(ON_REMOVE, function()
		if IsValid(sentryEnt) then
			util.ParticleEffect("ExplosionCore_buildings", sentryEnt:GetAbsOrigin(), Vector(0, 0, 0))
			sentryEnt:Remove()
		end

		table.remove(dronesList, findInTable(dronesList, projectile))

		local stationaryId = dronesData.DronesStationaryIds[projectile]

		if stationaryId then
			dronesData.DronesStationaryIds[projectile] = nil
			timer.Stop(stationaryId)
		end
	end)
end

local notificationsShown = {}

function DroneWalkerEquip(_, activator)
	-- fix weird quirk with template being spawned after you switch to a different class
	if classIndices_Internal[activator.m_iClass] ~= "Engineer" then
		return
	end

	print("drone walker equipped")
	local handle = activator:GetHandleIndex()

	if callbacks.Drone[handle] then
		DroneWalkerUnequip(activator, handle)
	end

	if not notificationsShown[handle] then
		notificationsShown[handle] = true
		activator["$DisplayTextCenter"](activator, "Press alt-fire to make drones stationary")
	end

	local meleeWeapon = activator:GetPlayerItemBySlot(2)
	local gunslingerEquipped = meleeWeapon.m_iClassname == "tf_weapon_robot_arm"

	local primary = activator:GetPlayerItemBySlot(0)

	if gunslingerEquipped then
		primary:SetAttributeValue("always crit", 1)
		-- primary:SetAttributeValue("engy sentry damage bonus", 1.25)
	else
		primary:SetAttributeValue("always crit", nil)
		-- primary:SetAttributeValue("engy sentry damage bonus", nil)
	end

	callbacks.Drone[handle] = {}
	weaponsData.Drone[handle] = {
		DronesList = {},

		DronesStationaryIds = {},

		DronesCap = not gunslingerEquipped and DRONES_CAP or DRONES_CAP + 1,

		Buffed = gunslingerEquipped,
	}

	local droneCallbacks = callbacks.Drone[handle]
	local dronesData = weaponsData.Drone[handle]

	-- on key press
	droneCallbacks.keyPress = activator:AddCallback(ON_KEY_PRESSED, function(_, key)
		if key ~= IN_ATTACK2 then
			return
		end

		if activator.m_hActiveWeapon.m_iClassname ~= "tf_weapon_shotgun_building_rescue" then
			return
		end

		if dictionaryLength(dronesData.DronesStationaryIds) > 0 then
			for projectile, id in pairs(dronesData.DronesStationaryIds) do
				timer.Stop(id)
				dronesData.DronesStationaryIds[projectile] = nil
			end

			return
		end

		for _, projectile in pairs(dronesData.DronesList) do
			local origin = projectile:GetAbsOrigin()

			projectile:SetLocalVelocity(Vector(0, 0, 0))

			dronesData.DronesStationaryIds[projectile] = timer.Create(0, function()
				projectile:SetAbsOrigin(origin)
			end, 0)
		end
	end)

	droneCallbacks.onRemoved = activator:AddCallback(ON_REMOVE, function()
		DroneWalkerUnequip(activator, handle)
	end)

	droneCallbacks.onDeath = activator:AddCallback(ON_DEATH, function()
		DroneWalkerUnequip(activator, handle)
	end)

	droneCallbacks.onSpawn = activator:AddCallback(ON_SPAWN, function()
		DroneWalkerUnequip(activator, handle)
	end)
end

function DroneWalkerUnequip(activator, handle)
	if not IsValid(activator) then
		activator = nil
	end

	local dronesData = weaponsData.Drone[handle]

	-- remove any existing drones
	for _, id in pairs(dronesData.DronesStationaryIds) do
		timer.Stop(id)
	end

	for _, projectile in pairs(dronesData.DronesList) do
		projectile:Remove()
	end

	ClearCallbacks("Drone", activator, handle)
	ClearData("Drone", activator, handle)
end

local function _parry(activator)
	local handle = activator:GetHandleIndex()

	weaponsData.Parry[handle] = true

	timer.Simple(PARRY_TIME, function()
		weaponsData.Parry[handle] = nil
	end)
end

function PHDEquip(_, activator)
	-- fix weird quirk with template being spawned after you switch to a different class
	if classIndices_Internal[activator.m_iClass] ~= "Soldier" then
		return
	end

	print("phd jumper equipped")
	local handle = activator:GetHandleIndex()

	if callbacks.PHD[handle] then
		PHDUnequip(activator, handle)
	end

	callbacks.PHD[handle] = {}
	weaponTimers.PHD[handle] = {}
	weaponsData.PHD[handle] = {
		JumpStartTime = false,
	}

	local phdCallbacks = callbacks.PHD[handle]
	local phdTimers = weaponTimers.PHD[handle]
	local phdData = weaponsData.PHD[handle]

	phdCallbacks.removed = activator:AddCallback(ON_REMOVE, function()
		PHDUnequip(activator, handle)
	end)

	phdCallbacks.died = activator:AddCallback(ON_DEATH, function()
		PHDUnequip(activator, handle)
	end)

	phdCallbacks.spawned = activator:AddCallback(ON_SPAWN, function()
		PHDUnequip(activator, handle)
	end)

	local timeSpentParachuting = 0

	local function getCurrentThreshold(timeDiff)
		local currentThreshold = { nil, -10000 }

		for thresHoldName, timeRequired in pairs(PHD_THRESHOLD) do
			if timeRequired > currentThreshold[2] and timeDiff > timeRequired then
				currentThreshold = { thresHoldName, timeRequired }
			end
		end

		local chosenThreshold = currentThreshold[1]

		return chosenThreshold
	end

	local primary = activator:GetPlayerItemBySlot(0)

	phdTimers.rocketJumpCheck = timer.Create(0.1, function()
		local jumping = activator:InCond(TF_COND_BLASTJUMPING)

		local timeDiff
		local chosenThreshold

		if phdData.JumpStartTime then
			timeDiff = CurTime() - phdData.JumpStartTime - timeSpentParachuting
			chosenThreshold = getCurrentThreshold(timeDiff)

			local parachuting = activator:InCond(TF_COND_PARACHUTE_ACTIVE)

			if parachuting then
				timeSpentParachuting = timeSpentParachuting + 0.1
			end

			if PHD_FEEDBACK_CONDS[chosenThreshold] then
				primary:SetAttributeValue("add cond when active", PHD_FEEDBACK_CONDS[chosenThreshold])
			end
		end

		if not jumping then
			if phdData.JumpStartTime then
				timeSpentParachuting = 0

				local activatorOrigin = activator:GetAbsOrigin()

				local explosionData = PHD_EXPLOSIONS[chosenThreshold]

				util.ParticleEffect(explosionData.Particle, activatorOrigin, Vector(0, 0, 0))
				local radius = explosionData.Radius
				local damage = explosionData.Damage

				local enemiesInRange = ents.FindInSphere(activatorOrigin, radius) --ents.GetAllPlayers()

				local damageMult = primary:GetAttributeValue("damage bonus") or 1

				for _, enemy in pairs(enemiesInRange) do
					if not enemy:IsCombatCharacter() then
						goto continue
					end

					if enemy.m_iTeamNum == activator.m_iTeamNum then
						goto continue
					end

					local damageInfo = {
						Attacker = activator,
						Inflictor = nil,
						Weapon = primary,
						Damage = damage * damageMult,
						DamageType = DMG_BLAST,
						DamageCustom = TF_DMG_CUSTOM_NONE,
						DamagePosition = enemy:GetAbsOrigin(), -- Where the target was hit at
						DamageForce = Vector(0, 0, 0), -- Knockback force of the attack
						ReportedPosition = activatorOrigin, -- Where the attacker attacked from
					}

					enemy:TakeDamage(damageInfo)

					::continue::
				end

				phdData.JumpStartTime = false
			end

			primary:SetAttributeValue("add cond when active", nil)

			return
		end

		if phdData.JumpStartTime then
			return
		end

		phdData.JumpStartTime = CurTime()
	end, 0)
end

function PHDUnequip(activator, handle)
	if not IsValid(activator) then
		activator = nil
	end

	ClearCallbacks("PHD", activator, handle)
	ClearData("PHD", activator, handle)
	ClearTimers("PHD", activator, handle)
end

function ParryAddictionEquip(_, activator)
	-- fix weird quirk with template being spawned after you switch to a different class
	if classIndices_Internal[activator.m_iClass] ~= "Demoman" then
		return
	end

	print("parry addiction equipped")
	local handle = activator:GetHandleIndex()

	if callbacks.Parry[handle] then
		ParryAddictionUnequip(activator, handle)
	end

	callbacks.Parry[handle] = {}

	local parryCallbacks = callbacks.Parry[handle]

	-- on key press
	parryCallbacks.keyPress = activator:AddCallback(7, function(_, key)
		if key ~= IN_ATTACK2 then
			return
		end

		if activator.m_flChargeMeter < 100 then
			return
		end

		if weaponsData.Parry[handle] then
			activator.m_flChargeMeter = 0
			-- activator:AcceptInput("$SetProp$m_flChargeMeter", "0")
			return
		end

		activator:AddCond(46, PARRY_TIME)

		activator.m_flChargeMeter = 0
		-- activator:AcceptInput("$SetProp$m_flChargeMeter", "0")

		_parry(activator)
	end)

	-- on damage
	parryCallbacks.onDamagePre = activator:AddCallback(3, function(_, damageInfo)
		if not weaponsData.Parry[handle] then
			return
		end

		if not damageInfo.Attacker then
			-- negate damage, don't try deflecting
			damageInfo.Damage = 0
			return true
		end

		if damageInfo.Attacker == activator then
			return
		end

		local deflectDmg = damageInfo.Damage * 2

		local deflectDmgInfo = {
			Attacker = activator,
			Inflictor = nil,
			Weapon = nil,
			Damage = deflectDmg,
			DamageType = 0,
			DamageCustom = 0,
			DamagePosition = Vector(0, 0, 0),
			DamageForce = Vector(0, 0, 0),
			ReportedPosition = Vector(0, 0, 0),
		}

		-- negate damage
		damageInfo.Damage = 0

		-- deflect
		damageInfo.Attacker:TakeDamage(deflectDmgInfo)

		return true
	end)

	parryCallbacks.onRemoved = activator:AddCallback(ON_REMOVE, function()
		ParryAddictionUnequip(activator, handle)
	end)

	parryCallbacks.onDeath = activator:AddCallback(9, function()
		ParryAddictionUnequip(activator, handle)
	end)

	parryCallbacks.onSpawn = activator:AddCallback(1, function()
		ParryAddictionUnequip(activator, handle)
	end)
end

function ParryAddictionUnequip(activator, handle)
	if not IsValid(activator) then
		activator = nil
	end

	ClearCallbacks("Parry", activator, handle)
	ClearData("Parry", activator, handle)
end
