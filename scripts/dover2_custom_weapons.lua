local REDEEMER_HIT_DEBOUNCE = 10
local REDEEMER_HIT_DAMAGE = 25
-- local REDEEMER_HIT_DAMAGE_ADDITION = 10 -- increased each hit
-- local REDEEMER_HIT_DAMAGE_ADDITION_CAP = 50

local REDEEMER_HIT_DAMAGE_ADDITION_MULT_ADDITIVE = 1 -- increased each hit
local REDEEMER_HIT_DAMAGE_ADDITION_CAP_ADDITIVE = 5

local WINGER_COOLDOWN = 3

local DRONES_CAP = 2

--This number * 100 is the damage required to fully charge, not counting natural recharge rate
local BUSTER_TRANSFORMER_CHARGE_DIVISOR = 50
local BUSTER_TRANSFORMER_GIANT_DAMAGE = 2000
local BUSTER_TRANSFORMER_TANK_DAMAGE = 2000
local BUSTER_TRANSFORMER_BLAST_RADIUS = 256

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

-- local SCAVENGER_EXPLOSION_BASE_DAMAGE = 85
-- local SCAVENGER_EXPLOSION_BASE_DAMAGE_BOSS = 175

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

local CUSTOM_WEAPONS_INDICES = { "Parry", "Drone", "PHD", "SmolShield", "WingerDash", "Scavenger", "Diver", "bt" }
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

    if not exEnt then
        return
    end

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

--Used by Buster Transformer, copied from Collateral Damage
local function fireTraceBetweenTwoEntities(pos1, pos2)
    DefaultTraceInfo = {
        start = pos1, -- Start position vector. Can also be set to entity, in this case the trace will start from entity eyes position
        endpos = pos2, -- End position vector. If nil, the trace will be fired in `angles` direction with `distance` length
        mask = MASK_SOLID, -- Solid type mask, see MASK_* globals
        collisiongroup = COLLISION_GROUP_PLAYER, -- Pretend the trace to be fired by an entity belonging to this group. See COLLISION_GROUP_* globals
        filter = nil -- Entity to ignore. If nil, filters start entity. Can be a single entity, table of entities, or a function with a single entity parameter that returns true if trace should hit the entity, false otherwise.
    }
    trace = util.Trace(DefaultTraceInfo)
    return trace.Entity
end

--Also copied from Collateral Damage holy
local function getAllPlayersInBusterExplosion(blastCenter, blastRadius)

    local entsInBlastRadius = ents.FindInSphere(blastCenter, blastRadius)
    local playersCaughtInBlast = {}

    for _, blastVictim in pairs(entsInBlastRadius) do

        if blastVictim:IsPlayer() == false then
            goto continue
        end
        
        if blastVictim:IsAlive() == false then
            goto continue
        end

		if blastVictim.m_iTeamNum ~= 3 then
			goto continue
		end
        
        -- Jank af, didnt use

        -- local hitEntityFromBlast = fireTraceBetweenTwoEntities(blastCenter, blastVictim)
        -- -- -- print("Hit a: " .. hitEntityFromBlast:GetClassname())
        -- if hitEntityFromBlast:GetClassname() ~= "player" then
        --     -- print("Blast victim was behind cover!")
        --     goto continue
        -- end

        playersCaughtInBlast[#playersCaughtInBlast+1] = blastVictim

        ::continue::
    end

    return playersCaughtInBlast
end

local function getAllSentriesInBusterExplosion(blastCenter, blastRadius)

    local entsInBlastRadius = ents.FindInSphere(blastCenter, blastRadius)
    local sentriesCaughtInBlast = {}

    for _, blastVictim in pairs(entsInBlastRadius) do

        if blastVictim:GetClassname() ~= "obj_sentrygun" then
            goto continue
        end

		if blastVictim.m_iTeamNum ~= 3 then
			goto continue
		end

        sentriesCaughtInBlast[#sentriesCaughtInBlast+1] = blastVictim

        ::continue::
    end

    return sentriesCaughtInBlast
end

--I'm sure these can be bundled into one function but I cba for now
local function getAllTanksInBusterExplosion(blastCenter, blastRadius)

    local entsInBlastRadius = ents.FindInSphere(blastCenter, blastRadius)
    local tanksCaughtInBlast = {}

    for _, blastVictim in pairs(entsInBlastRadius) do

        if blastVictim:GetClassname() ~= "tank_boss" and blastVictim:GetClassname() ~= "base_boss" then
            goto continue
        end

        tanksCaughtInBlast[#tanksCaughtInBlast+1] = blastVictim

        ::continue::
    end

    return tanksCaughtInBlast
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

local function _parry(activator)
	local handle = activator:GetHandleIndex()

	weaponsData.Parry[handle] = true

	timer.Simple(PARRY_TIME, function()
		weaponsData.Parry[handle] = nil
	end)
end

function ParryAddictionEquip(_, activator)
	-- fix weird quirk with template being spawned after you switch to a different class
	if classIndices_Internal[activator:DumpProperties().m_iClass] ~= "Demoman" then
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


local noReprogram = {}
function _OnWaveSpawnBot_CustomWeapon(bot, _, tags)
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

	local firerateUpgrade = owner:GetPlayerItemBySlot(LOADOUT_POSITION_PDA):GetAttributeValue("engy sentry fire rate increased") or 1

	local primary = owner:GetPlayerItemBySlot(0)
	local mothershipUpgrade = primary:GetAttributeValue("throwable damage")

	if mothershipUpgrade then
		sentryEnt.m_flModelScale = 2.5
		timer.Simple(0.1, function()
			sentryEnt:SetHealth(250)
		end)
		sentryEnt["$attributeoverride"] = 1
		sentryEnt["$damagemult"] = 0.8
		sentryEnt["$fireratemult"] = firerateUpgrade + 1
		-- sentryEnt["$rangemult"] = 0.5
		sentryEnt["$bulletweapon"] = "Upgradeable TF_WEAPON_ROCKETLAUNCHER"
	end

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
		if sentryEnt and IsValid(sentryEnt) then
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

function UpdateDroneCap(_, activator)
	local handle = activator:GetHandleIndex()

	local dronesData = weaponsData.Drone[handle]

	-- remove any existing drones
	for _, id in pairs(dronesData.DronesStationaryIds) do
		timer.Stop(id)
	end

	for _, projectile in pairs(dronesData.DronesList) do
		projectile:Remove()
	end

	local droneCount = DRONES_CAP

	local primary = activator:GetPlayerItemBySlot(0)
	local mothershipUpgrade = primary:GetAttributeValue("throwable damage")
	local droneCountUpgrade = primary:GetAttributeValue("throwable fire speed")

	if mothershipUpgrade then
		droneCount = 1
	elseif droneCountUpgrade then
		droneCount = droneCount + 1
	end

	local melee = activator:GetPlayerItemBySlot(LOADOUT_POSITION_MELEE)
	if droneCountUpgrade then
		melee:SetAttributeValue("mod wrench builds minisentry", 1)
	else
		melee:SetAttributeValue("mod wrench builds minisentry", nil)
	end

	dronesData.DronesCap = droneCount
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

	-- local meleeWeapon = activator:GetPlayerItemBySlot(2)
	-- local gunslingerEquipped = meleeWeapon.m_iClassname == "tf_weapon_robot_arm"

	-- if gunslingerEquipped then
	-- 	primary:SetAttributeValue("always crit", 1)
	-- 	-- primary:SetAttributeValue("engy sentry damage bonus", 1.25)
	-- else
	-- 	primary:SetAttributeValue("always crit", nil)
	-- 	-- primary:SetAttributeValue("engy sentry damage bonus", nil)
	-- end

	callbacks.Drone[handle] = {}
	weaponsData.Drone[handle] = {
		DronesList = {},

		DronesStationaryIds = {},

		-- DronesCap = not gunslingerEquipped and DRONES_CAP or DRONES_CAP + 1,
		DronesCap = DRONES_CAP,

		-- Buffed = gunslingerEquipped,
	}

	UpdateDroneCap(_, activator)

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

function BTEquip(_, activator)
	-- fix weird quirk with template being spawned after you switch to a different class
	if classIndices_Internal[activator.m_iClass] ~= "Demoman" then
		return
	end

	print("buster transformer equipped")
	activator.m_flChargeMeter = 0
	local handle = activator:GetHandleIndex()

	timer.Simple(1, function()
		--Persian and Booties are not allowed to charge this
		local primaryWeapon = activator:GetPlayerItemBySlot(0)
		local meleeWeapon = activator:GetPlayerItemBySlot(2)

		--No booties passive with this weapon sori
		primaryWeapon:SetAttributeValue("kill refills meter", "0")

		--No persian passive either, unless... yknow i might consider it it's such a garbage weapon
		meleeWeapon:SetAttributeValue("charge meter on hit", "0")
		meleeWeapon:SetAttributeValue("ammo gives charge", "0")

		--Failsafe
		activator:SetAttributeValue("max health additive bonus", "0")
		activator:SetAttributeValue("no_attack", "0")
		activator:SetAttributeValue("move speed penalty", "1")
		activator:SetAttributeValue("damage force reduction", "1")
		activator:SetAttributeValue("always allow taunt", "0")
		activator:SetAttributeValue("cannot be backstabbed", "0")
		activator:SetAttributeValue("not solid to players", "0")

		activator:AcceptInput("AddOutput", "modelscale 1")
		activator:AcceptInput("SetForcedTauntCam", "0")
		activator:RemoveCond(7)
		activator:RemoveCond(32)
		activator:RemoveCond(41)
		--Reset model
		activator:SetCustomModel("")
	end)
	

	if callbacks.bt[handle] then
		BTUnequip(activator, handle)
	end

	callbacks.bt[handle] = {}
	weaponTimers.bt[handle] = {}
	weaponsData.bt[handle] = {}

	local btCallbacks = callbacks.bt[handle]
	local btTimers = weaponTimers.bt[handle]
	local btData = weaponsData.bt[handle]

	btCallbacks.removed = activator:AddCallback(ON_REMOVE, function()
		BTUnequip(activator, handle)
	end)

	btCallbacks.died = activator:AddCallback(ON_DEATH, function()
		BTUnequip(activator, handle)
		timer.Stop(btTimers.detonatorLogicParticle)
		timer.Stop(btTimers.detonatorLogicMain)
		ClearTimers("bt", activator, handle)
	end)

	btCallbacks.spawned = activator:AddCallback(ON_SPAWN, function()
		BTUnequip(activator, handle)
	end)

	btCallbacks.onmouse2 = activator:AddCallback(ON_KEY_PRESSED, function(ent, key)
		
		--mouse2 is 2048
		if key ~= 2048 or activator.m_flChargeMeter < 100 then
			return
		end

		activator.m_flChargeMeter = 0
		--Locked to melee
		activator:AddCond(41)
		--Speed boost
		activator:AddCond(32)
		--Force switch to melee? idk this was in the original caber buster template
		activator:AddCond(85)
		timer.Simple(0.015, function()
			activator:RemoveCond(85)
		end)
		timer.Simple(0.11, function()
			util.ParticleEffect("drg_wrenchmotron_teleport", activator:GetAbsOrigin(), Vector(0,0,0), activator)
			activator:PlaySound("misc/halloween/merasmus_spell.wav")
			activator:AcceptInput("$DisplayTextCenter", "TAUNT to explode!")

			--Surely there's a better way to do this
			activator:AcceptInput("AddOutput", "modelscale 1.75")
			activator:AcceptInput("SetForcedTauntCam", "1")
			activator:SetAttributeValue("max health additive bonus", "225")
			activator:SetAttributeValue("no_attack", "1")
			activator:SetAttributeValue("move speed penalty", "2")
			--activator:SetAttributeValue("no resupply", "1") --Buying smth from the upgrade station refills charge grahhh
			activator:SetAttributeValue("damage force reduction", "0.01") --Not fun getting knocked back around
			activator:SetAttributeValue("always allow taunt", "1")
			activator:SetAttributeValue("cannot be backstabbed", "1")
			activator:SetAttributeValue("not solid to players", "1") --Not fun being solid to players fr
		end)
		timer.Simple(0.2, function()
			activator:SetCustomModel("models/bots/demo/red_sentry_buster.mdl")
		end)
		timer.Simple(0.3, function()
			activator:AddHealth(400, false)
		end)

		btTimers.tauntChecker = timer.Create(0.1, function()
			
			if not activator:InCond(TF_COND_TAUNTING) then
				goto noTaunt
			end

			timer.Stop(btTimers.tauntChecker)
			activator:SetAttributeValue("move speed penalty", "0.0001")
			activator:PlaySound("mvm/sentrybuster/mvm_sentrybuster_spin.wav")

			btTimers.detonatorLogicParticle = timer.Create(1.97, function()
				util.ParticleEffect("asplode_hoodoo", activator:GetAbsOrigin(), Vector(0,0,0), activator)
			end)

			btTimers.detonatorLogicMain = timer.Create(1.95, function()
				
				activator:PlaySound("mvm/sentrybuster/mvm_sentrybuster_explode.wav")

				--Is there no remove attribute?
				activator:SetAttributeValue("max health additive bonus", "0")
				activator:SetAttributeValue("no_attack", "0")
				activator:SetAttributeValue("move speed penalty", "1")
				--activator:SetAttributeValue("no resupply", "0")
				activator:SetAttributeValue("damage force reduction", "1")
				activator:SetAttributeValue("always allow taunt", "0")
				activator:SetAttributeValue("cannot be backstabbed", "0")
				activator:SetAttributeValue("not solid to players", "0")

				activator:AcceptInput("AddOutput", "modelscale 1")
				activator:AcceptInput("SetForcedTauntCam", "0")
				--Get out of taunting! No more speed boost and melee lock as well.
				activator:RemoveCond(7)
				activator:RemoveCond(32)
				activator:RemoveCond(41)
				--Temporary uber after exploding so that you dont instantly die
				activator:AddCond(52,2)
				--Reset model
				activator:SetCustomModel("")

				--Borrowed from collateral damage whatadeal
				--I'm sure this can be bundled into one function but I cba for now
				for _, blastVictim in pairs(getAllPlayersInBusterExplosion(activator:GetAbsOrigin(), BUSTER_TRANSFORMER_BLAST_RADIUS)) do
					BusterTakeDamage = {
						Attacker = activator, -- Attacker
						Inflictor = activator:GetPlayerItemBySlot(2), -- Direct cause of damage, usually a projectile
						Weapon = activator:GetPlayerItemBySlot(2),
						Damage = 9999,
						DamageType = DMG_BLAST, -- Damage type, see DMG_* globals. Can be combined with | operator
						DamageCustom = TF_DMG_CUSTOM_AIR_STICKY_BURST, -- Custom damage type, see TF_DMG_* globals
						DamagePosition = activator:GetAbsOrigin(), -- Where the target was hit at
						DamageForce = Vector(0,0,0), -- Knockback force of the attack
						ReportedPosition = activator:GetAbsOrigin() -- Where the attacker attacked from
					}
			
					if blastVictim.m_bIsMiniBoss == 1 then
						BusterTakeDamage.Damage = BUSTER_TRANSFORMER_GIANT_DAMAGE
						blastVictim:TakeDamage(BusterTakeDamage)
						goto continue
					end
					
					blastVictim:TakeDamage(BusterTakeDamage)
			
					::continue::
				end
			
				for _, blastVictim in pairs(getAllSentriesInBusterExplosion(activator:GetAbsOrigin(), BUSTER_TRANSFORMER_BLAST_RADIUS)) do
					BusterTakeDamage = {
						Attacker = activator, -- Attacker
						Inflictor = activator:GetPlayerItemBySlot(2), -- Direct cause of damage, usually a projectile
						Weapon = activator:GetPlayerItemBySlot(2),
						Damage = 9999,
						DamageType = DMG_BLAST, -- Damage type, see DMG_* globals. Can be combined with | operator
						DamageCustom = TF_DMG_CUSTOM_AIR_STICKY_BURST, -- Custom damage type, see TF_DMG_* globals
						DamagePosition = activator:GetAbsOrigin(), -- Where the target was hit at
						DamageForce = Vector(0,0,0), -- Knockback force of the attack
						ReportedPosition = activator:GetAbsOrigin() -- Where the attacker attacked from
					}
					blastVictim:TakeDamage(BusterTakeDamage)
			
					::continue::
				end

				for _, blastVictim in pairs(getAllTanksInBusterExplosion(activator:GetAbsOrigin(), BUSTER_TRANSFORMER_BLAST_RADIUS)) do
					BusterTakeDamage = {
						Attacker = activator, -- Attacker
						Inflictor = activator:GetPlayerItemBySlot(2), -- Direct cause of damage, usually a projectile
						Weapon = activator:GetPlayerItemBySlot(2),
						Damage = BUSTER_TRANSFORMER_TANK_DAMAGE,
						DamageType = DMG_BLAST, -- Damage type, see DMG_* globals. Can be combined with | operator
						DamageCustom = TF_DMG_CUSTOM_AIR_STICKY_BURST, -- Custom damage type, see TF_DMG_* globals
						DamagePosition = activator:GetAbsOrigin(), -- Where the target was hit at
						DamageForce = Vector(0,0,0), -- Knockback force of the attack
						ReportedPosition = activator:GetAbsOrigin() -- Where the attacker attacked from
					}
					blastVictim:TakeDamage(BusterTakeDamage)
			
					::continue::
				end

				activator.m_flChargeMeter = 0
			end)
			::noTaunt::
		end, 0)
		
	end)
end

AddEventCallback('player_hurt', function(event)

	if event.attacker == 0 then
		return
	end

	local playerAttacker = ents.GetPlayerByUserId(event.attacker)

	--With the current guard clauses you actually build up charge by damaging yourself
	--But seeing as it is 1% charge per 50 damage dealt, I decided it doesn't matter
	if playerAttacker.m_iTeamNum == 3 then
		return
	end

	-- print("Attacker was red!")

	local weaponUsed = playerAttacker:GetPlayerItemBySlot(1)

	if not weaponUsed:GetAttributeValue("dmg taken from blast reduced") then
		return
	end

	--The weapon's base 0.95 is turned into some dumb number like 0.94999... thanks float! This workaround is needed
	if weaponUsed:GetAttributeValue("dmg taken from blast reduced") > 0.94 and weaponUsed:GetAttributeValue("dmg taken from blast reduced") < 0.96 then
		-- print("And BT was equipped!")

		--+0.01 hack job for floats
		playerAttacker.m_flChargeMeter = playerAttacker.m_flChargeMeter + ((event.damageamount + 0.01) / BUSTER_TRANSFORMER_CHARGE_DIVISOR)
	end
end)


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

function BTUnequip(activator, handle)
	if not IsValid(activator) then
		activator = nil
	end

	ClearCallbacks("bt", activator, handle)
	ClearData("bt", activator, handle)
	ClearTimers("bt", activator, handle)

	--Is there no remove attribute?
	--We need to reset all of these in the event the player dies as a sentry buster
	activator:SetAttributeValue("max health additive bonus", "0")
	activator:SetAttributeValue("no_attack", "0")
	activator:SetAttributeValue("move speed penalty", "1")
	--activator:SetAttributeValue("no resupply", "0")
	activator:SetAttributeValue("damage force reduction", "1")
	activator:SetAttributeValue("always allow taunt", "0")
	activator:SetAttributeValue("cannot be backstabbed", "0")
	activator:SetAttributeValue("not solid to players", "0")

	activator:AcceptInput("AddOutput", "modelscale 1")
	activator:AcceptInput("SetForcedTauntCam", "0")
	activator:RemoveCond(7)
	activator:RemoveCond(32)
	activator:RemoveCond(41)
	--Reset model
	activator:SetCustomModel("")
end

function PHDUnequip(activator, handle)
	if not IsValid(activator) then
		activator = nil
	end

	ClearCallbacks("PHD", activator, handle)
	ClearData("PHD", activator, handle)
	ClearTimers("PHD", activator, handle)
end

local function weaponMimic(properties, positional)
	local mimic = ents.CreateWithKeys("tf_point_weapon_mimic", properties)
	mimic:SetAbsOrigin(positional.Origin)
	mimic:SetAbsAngles(positional.Angles)

	return mimic
end

local function getEyeAngles(player)
	local pitch = player["m_angEyeAngles[0]"]
	local yaw = player["m_angEyeAngles[1]"]

	return Vector(pitch, yaw, 0)
end

-- thunderdome
function ThunderdomeEquipped(_, activator)
	local hasRedSun = activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):GetAttributeValue("throwable damage")
	local hasCommunist = activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):GetAttributeValue("throwable fire speed")

	local spawnflags = 65
	if hasRedSun or hasCommunist then
		spawnflags = 64
	end

	local namePrefix = "thunderdome"..tostring(activator:GetHandleIndex())

	local allEntities = {}

	for i = 1, 2 do
		local rotate = ents.CreateWithKeys("func_rotating", {
			mins = Vector(-0.1, -0.1, -0.1),
			maxs = Vector(0.1, 0.1, 0.1),
			dmg = 0,
			fanfriction = 100,
			maxspeed = 60,
			spawnflags = spawnflags,
			volume = 0,
			solid = 0,
		})

		rotate:SetName(namePrefix..tostring(rotate:GetHandleIndex()))
		if not hasCommunist and not hasRedSun then
			rotate["$positiononly"] = 1
		end
		rotate:SetFakeParent(activator)

		if (hasRedSun or hasCommunist) and i == 2 then
			break
		end

		local shieldOffset = i == 1 and Vector(100, 0, 0) or Vector(-100, 0, 0)
		local shieldAngles = i == 1 and Vector(0, 0, 0) or Vector(-180, 0, -180)

		if hasRedSun then
			shieldOffset = Vector(100, 0, 0)
			shieldAngles = Vector(0, 0, 0)
		elseif hasCommunist then
			shieldOffset = Vector(-50, 0, 0)
			shieldAngles = Vector(-180, 0, -180)
		end

		local shield = ents.CreateWithKeys("entity_medigun_shield", {
			angles = shieldAngles,
			spawnflags = 1,
			teamnum = activator.m_iTeamNum,
		}, true, true)


		shield["$fakeparentoffset"] = shieldOffset
		shield["$fakeparentrotation"] = shieldAngles

		shield:SetModel("models/props_mvm/mvm_comically_small_player_shield.mdl")
		shield:SetFakeParent(rotate)
		local shieldName = namePrefix..tostring(shield:GetHandleIndex().."Shield")
		shield:SetName(shieldName)

		RegisterShieldThunderdome(shieldName, activator)

		table.insert(allEntities, rotate)
		table.insert(allEntities, shield)
	end

	local thunderdomeCallbacks = {}
	thunderdomeCallbacks[1] = activator:AddCallback(ON_REMOVE, function()
		for _, ent in pairs(thunderdomeCallbacks) do
			ent:Remove()
		end
	end)
	thunderdomeCallbacks[2] = activator:AddCallback(ON_SPAWN, function()
		for _, callback in pairs(thunderdomeCallbacks) do
			activator:RemoveCallback(callback)
		end
	end)
end

function ThunderdomeUnequipped(_, activator)
	local namePrefix = "thunderdome"..tostring(activator:GetHandleIndex())

	for _, ent in pairs(ents.FindAllByName(namePrefix.."*")) do
		ent:Remove()
	end
end

function ThunderdomeRefresh(_, activator)
	ThunderdomeUnequipped(nil, activator)
	ThunderdomeEquipped(nil, activator)
end

-- explosive arrow
local function spawnArrowTip(owner, arrowOrigin, attachEnt)
	local detonatePosition = Entity("info_target")
	local detonatePositionName = "detonatePosition"..tostring(detonatePosition:GetHandleIndex())
	detonatePosition:SetName(detonatePositionName)
	detonatePosition:SetAbsOrigin(arrowOrigin)

	local flickerParticle = owner.m_iTeamNum == 2 and "stickybomb_pulse_red" or "stickybomb_pulse_blue"
	local flicker = ents.CreateWithKeys("info_particle_system", {
		effect_name = flickerParticle,
		start_active = 0,
		flag_as_weather = 0,
	}, true, true)
	flicker:SetAbsOrigin(arrowOrigin)
	flicker:SetFakeParent(detonatePosition)


	local sound = ents.CreateWithKeys("ambient_generic", {
		message = "weapons/stickybomblauncher_det.wav",
		radius = 4000,
		health = 5,
		spawnflags = 48,
	})
	sound:SetAbsOrigin(arrowOrigin)
	sound:SetFakeParent(detonatePosition)

	timer.Simple(1, function ()
		flicker:Start()
		sound:PlaySound()

		timer.Simple(1, function ()
			if IsValid(flicker) then
				flicker:Remove()
			end
			if IsValid(sound) then
				sound:Remove()
			end
		end)
	end)

	local damageMult = owner:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):GetAttributeValue("damage bonus") or 1

	local mimic = weaponMimic({
		TeamNum = owner.m_iTeamNum,
		WeaponType = 3,

		SpeedMax = 0,
		SpeedMin = 0,

		spawnflags = 3,
		SplashRadius = 144,
		Damage = 100 * damageMult,
	},
	{
		Origin = owner:GetAbsOrigin() + Vector(0, 0, 50),
		Angles = getEyeAngles(owner),
	})

	mimic["$SetOwner"](mimic, owner)

	mimic:SetAbsOrigin(arrowOrigin)
	mimic:SetFakeParent(detonatePosition)

	timer.Simple(2, function()
		mimic:FireOnce()
		timer.Simple(0.015, function()
			mimic:DetonateStickies()
		end)
		timer.Simple(1, function()
			mimic:Remove()
		end)
	end)

	for _, ent in pairs({mimic, flicker, sound}) do
		local entName = "detonateComponent"..tostring(ent:GetHandleIndex())
		ent:SetName(entName)
	end

	if attachEnt then
		local offset = arrowOrigin - attachEnt:GetAbsOrigin()
		detonatePosition["$fakeparentoffset"] = offset
		detonatePosition:SetFakeParent(attachEnt)
	end

	timer.Simple(5, function ()
		detonatePosition:Remove()
	end)
end

ents.AddCreateCallback("tf_projectile_arrow", function(arrow)
    timer.Simple(0, function()
		local owner = arrow.m_hOwnerEntity
        local primary = owner:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY)

		if classIndices_Internal[owner.m_iClass] ~= "Sniper" then
			return
		end

        if not primary:GetAttributeValue("throwable healing") then
            return
        end

		local shouldPenetrate = primary:GetAttributeValue("projectile penetration")

        -- print("explosive arrow fired")

		local collided = false
		local touchedEnts = {}

        arrow:AddCallback(ON_TOUCH, function(_, other)
			if touchedEnts[other:GetHandleIndex()] then
				return
			end

            if not other:IsPlayer() and not other:IsNPC() and other.m_iClassname ~= "entity_medigun_shield" then
                return
            end

			if not shouldPenetrate then
				collided = true
			end

			touchedEnts[other:GetHandleIndex()] = true

            -- print("collided with attachable entity")
			local origin = arrow:GetAbsOrigin()
			spawnArrowTip(owner, origin, other)
        end)

        arrow:AddCallback(ON_REMOVE, function()
			if collided then
				return
			end

            -- print("collided with surface")
			local origin = arrow:GetAbsOrigin()
			spawnArrowTip(owner, origin)
        end)
    end)
end)

-- wormhole Diver

-- disable collision with func_respawnroomvisualizer
for _, visualizer in pairs(ents.FindAllByClass("func_respawnroomvisualizer")) do
	visualizer:AddCallback(ON_SHOULD_COLLIDE, function(_, other)
		if other.IsWormHole then
			other:Remove()
		end
	end)
end

function WormholeDiverShot(_, projectile)
	if not projectile then
		return
	end
	projectile.IsWormHole = true
end

local diverCallbacks = {}
function WormholeDiverEquip(_, activator)
	-- fix weird quirk with template being spawned after you switch to a different class
	if classIndices_Internal[activator:DumpProperties().m_iClass] ~= "Pyro" then
		return
	end

	local handle = activator:GetHandleIndex()

	diverCallbacks[handle] = {}
	local playerCallbacks = diverCallbacks[handle]

	-- on key press
	playerCallbacks.keyPress = activator:AddCallback(ON_KEY_PRESSED, function(_, key)
		if key ~= IN_ATTACK2 then
			return
		end

		if activator.m_hActiveWeapon ~= activator:GetPlayerItemBySlot(LOADOUT_POSITION_SECONDARY) then
			return
		end

		for _, flare in pairs(ents.FindAllByClass("tf_projectile_flare")) do
			if flare.m_hOwnerEntity == activator then
				local flareOrigin = flare:GetAbsOrigin()
				local activatorOrigin = activator:GetAbsOrigin()

				-- too short, don't bother
				-- prevents clipping
				if flareOrigin:Distance(activatorOrigin) <= 120 then
					break
				end

				local DefaultTraceInfo = {
					start = activator:GetAbsOrigin(),
					endpos = flareOrigin,
					mask = (CONTENTS_PLAYERCLIP),
					collisiongroup = COLLISION_GROUP_PLAYER,
					-- mins = Vector(-150, -150, -0),
					-- maxs = Vector(150, 150, 0),
				}

				-- trace for player clip
				local trace = util.Trace(DefaultTraceInfo)

				if not trace.Entity then
					activator:SetAbsOrigin(flareOrigin)
				end
				-- activator:SetAbsOrigin(trace.HitPos or flareOrigin)
				flare:Remove()

				break
			end
		end
	end)
end

function WormholeDiverUnequip(_, activator)
	for _, id in pairs(diverCallbacks[activator:GetHandleIndex()]) do
		activator:RemoveCallback(id)
	end
end