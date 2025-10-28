local AMMO_COST = 25
local COOLDOWN = 1
local RAGE_GAIN_PER_PROJECTILE = 10

local DEFLECT_PARTICLE = "ExplosionCore_sapperdestroyed"
local DEFLECT_AUDIO = "sound/weapons/barret_arm_zap.wav"
local AIRBLAST_AUDIO = "sound/weapons/barret_arm_zap.wav"

local AIRBLAST_RANGE = 100

local DEFLECTABLE_PROJECTILES = {"tf_projectile_pipe", "tf_projectile_pipe_remote", "tf_projectile_rocket"
, "tf_projectile_sentryrocket"}

local function getEyeAngles(player)
	local pitch = player["m_angEyeAngles[0]"]
	local yaw = player["m_angEyeAngles[1]"]

	return Vector(pitch, yaw, 0)
end

local DR_callbacks = {}
local cooldowns = {}

function DR_Refunded(_, activator)
	if not IsValid(activator) then
		return
	end

	local handle = activator:GetHandleIndex()

	local callbacks = DR_callbacks[handle]

	for _, id in pairs(callbacks) do
		activator:RemoveCallback(id)
	end

	DR_callbacks[handle] = nil
end

local _DEFLECTABLE_INDEX = {}
for _, classname in pairs(DEFLECTABLE_PROJECTILES) do
	_DEFLECTABLE_INDEX[classname] = true
end

local function DR_Blast(activator)
	local weapon = activator.m_hActiveWeapon

	if weapon.m_iClassname ~= "tf_weapon_flamethrower" then
		return
	end

	local awesomeMagicNumberToGetPrimaryClip = 2 -- I love magic numbers
	local clip = activator.m_iAmmo[awesomeMagicNumberToGetPrimaryClip]

	if clip < AMMO_COST then
		return
	end

	local handle = activator:GetHandleIndex()
	if cooldowns[handle] then
		if CurTime() < cooldowns[handle] then
			return
		end
	end

	activator:PlaySound(AIRBLAST_AUDIO)

	cooldowns[handle] = CurTime() + COOLDOWN

	-- disable attacking while airblast animation plays
	weapon:SetAttributeValue("no_attack", 1)

	timer.Simple(0.5, function()
		weapon:SetAttributeValue("no_attack", nil)
	end)

	-- play airblast sequence
	for _, viewmodel in pairs(ents.FindAllByClass("tf_viewmodel")) do
		if viewmodel.m_hOwner == activator then
			viewmodel.m_nSequence = 13
			break
		end
	end

	activator.m_iAmmo[awesomeMagicNumberToGetPrimaryClip] = clip - AMMO_COST

	local origin = activator:GetAbsOrigin() + Vector(0, 0, 50)
	local eyeAngles = getEyeAngles(activator)

	local DefaultTraceInfo = {
		start = origin,
		distance = 100,
		angles = eyeAngles,
		mask = MASK_SOLID,
		collisiongroup = COLLISION_GROUP_DEBRIS,
	}
	local trace = util.Trace(DefaultTraceInfo)

	-- util.ParticleEffect("ExplosionCore_buildings", trace.HitPos, nil)
	local bonusRage = 0
	for _, ent in pairs(ents.FindInSphere(trace.HitPos, AIRBLAST_RANGE)) do
		if _DEFLECTABLE_INDEX[ent.m_iClassname] then
			-- util.ParticleEffect(DEFLECT_PARTICLE, ent:GetAbsOrigin())
			local deflectParticle = ents.CreateWithKeys("info_particle_system", {
				effect_name = DEFLECT_PARTICLE,
				start_active = 1,
				flag_as_weather = 0,
			}, true, true)
			deflectParticle:SetAbsOrigin(ent:GetAbsOrigin())
			deflectParticle:Start()

			activator:PlaySound(DEFLECT_AUDIO)

			ent:Remove()

			bonusRage = bonusRage + RAGE_GAIN_PER_PROJECTILE

			timer.Simple(1, function()
				deflectParticle:Remove()
			end)
		end
	end

	return bonusRage
end

function DR_Purchased(_, activator)
	local handle = activator:GetHandleIndex()
	local callbacks = {}

	DR_callbacks[handle] = callbacks

	local primary = activator:GetPlayerItemBySlot(0)

	-- for i = 0, 2 do
	-- 	activator:GetPlayerItemBySlot(i):SetAttributeValue("mod rage on hit penalty", 0)
	-- end

	local rage = 0

	local held = false

	local function stopHeld()
		if not held then
			return
		end

		timer.Stop(held)

		held = false
	end

	local function removeCallbacks()
		stopHeld()

		if not IsValid(activator) then
			return
		end

		DR_Refunded(_, activator)

		if cooldowns[handle] then
			cooldowns[handle] = nil
		end
	end

	local function addRage(amount)
		if not amount then
			return
		end

		rage = rage + amount

		activator.m_flRageMeter = rage

		if rage > 100 then
			rage = 100
		end
	end

	timer.Create(0.01, function ()
		if not IsValid(activator) then
			return true
		end

		if not DR_callbacks[handle] then
			return true
		end

		if activator.m_bRageDraining == 1 then
			-- allow rage to be extended by deflecting during
			rage = activator.m_flRageMeter
			return
		end

		activator.m_flRageMeter = rage
	end, 0)

	callbacks.onPress = activator:AddCallback(ON_KEY_PRESSED, function(_, key)
		if held then
			return
		end

		if key ~= IN_ATTACK2 then
			return
		end

		if rage >= 100 then
			return
		end

		addRage(DR_Blast(activator))

		held = timer.Create(0.1, function ()
			if not IsValid(activator) then
				return true -- cancel
			end

			addRage(DR_Blast(activator))
		end, 0)
	end)

	callbacks.onRemove = activator:AddCallback(ON_REMOVE, function()
		stopHeld()

		if cooldowns[handle] then
			cooldowns[handle] = nil
		end
	end)

	callbacks.onRelease = activator:AddCallback(ON_KEY_RELEASED, function(_, key)
		if key ~= IN_ATTACK2 then
			return
		end

		stopHeld()
	end)

	callbacks.onDeath = activator:AddCallback(ON_DEATH, function()
		if activator:GetPlayerItemBySlot(0) == primary then
			return
		end

		removeCallbacks()
	end)
	callbacks.onSpawn = activator:AddCallback(ON_SPAWN, function()
		if activator:GetPlayerItemBySlot(0) == primary then
			return
		end

		removeCallbacks()
	end)
end