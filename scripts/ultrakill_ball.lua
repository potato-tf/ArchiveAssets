local COOLDOWN = 1

local function getEyeAngles(player)
	local pitch = player["m_angEyeAngles[0]"]
	local yaw = player["m_angEyeAngles[1]"]

	return Vector(pitch, yaw, 0)
end

local ballCallbacks = {}
local cooldowns = {}

local function getClosestTarget(owner)
	local closest = { math.huge, nil }

	local origin = owner:GetAbsOrigin()

	for _, player in pairs(ents.GetAllPlayers()) do
		local distance = origin:Distance(player:GetAbsOrigin())

		if player:IsAlive() and player.m_iTeamNum ~= owner.m_iTeamNum and distance <= closest[1] then
			closest = { distance, player }
		end
	end

	return closest[2]
end

ents.AddCreateCallback("tf_projectile_arrow", function(entity)
	local touch = entity:AddCallback(ON_TOUCH, function(_, other)
		if other:IsWorld() then
			entity:Remove()
			return
		end
	end)

	timer.Simple(0, function()
		local owner = entity.m_hOwnerEntity

		if not owner then
			entity:RemoveCallback(touch)
			return
		end

		if owner.m_hActiveWeapon ~= owner:GetPlayerItemBySlot(LOADOUT_POSITION_SECONDARY) then
			entity:RemoveCallback(touch)
			return
		end

		entity:SetModel("models/player/items/crafting/coin_summer2015_gold.mdl")

		-- ultrakill ball spawned
		-- now give it a hurtbox
		timer.Simple(0.1, function()
			if not entity then
				return
			end

			local hurtbox = ents.CreateWithKeys("obj_sentrygun", {
				TeamNum = (owner.m_iTeamNum == 2 and 3 or 2) or 3,

				["$positiononly"] = 1,
			})

			local hurtboxName = tostring(owner:GetHandleIndex()) .. "_CoinHurtbox"

			hurtbox:SetName(hurtboxName)
			hurtbox:Disable()
			hurtbox.effects = EF_NODRAW

			hurtbox:AddCallback(ON_SHOULD_COLLIDE, function(_, other, cause)
				if other:IsPlayer() and cause == ON_SHOULD_COLLIDE_CAUSE_FIRE_WEAPON then
					return true
				end

				return false

				-- if other == entity then
				-- 	return false
				-- end

				-- if not other:IsPlayer() then
				-- 	return false
				-- end

				-- -- prevent collision
				-- -- without letting bullets pass through
				-- if hurtbox:GetAbsOrigin():Distance(other:GetAbsOrigin()) <= 50 then
				-- 	return false
				-- end
			end)

			entity:AddCallback(ON_REMOVE, function()
				hurtbox:Remove()

				-- if owner:IsBot() then
					-- owner["$StopRotateTowards"](owner, hurtbox)
					-- owner:RemoveModule("rotator")
				-- end
			end)

			hurtbox["$fakeparentoffset"] = Vector(0, 0, -15)

			hurtbox.m_flModelScale = 2.5
			hurtbox:SetAbsOrigin(entity:GetAbsOrigin())
			hurtbox:SetFakeParent(entity)
			hurtbox:SetHealth(100000)

			hurtbox:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageinfo)
				-- damaged, redirect ball

				damageinfo.Damage = 0

				local target = getClosestTarget(owner)

				if not target then
					entity:Remove()
					return true
				end

				local mimic = ents.CreateWithKeys("tf_point_weapon_mimic", {
					["$preventshootparent"] = 1,

					TeamNum = owner.m_iTeamNum,
					["$weaponname"] = "BALL_REDIRECTED_SHOOTER",
				}, true, true)

				mimic:SetAbsOrigin(entity:GetAbsOrigin())

				mimic["$SetOwner"](mimic, owner)

				entity:Remove()

				timer.Simple(0, function()
					mimic:FaceEntity(target)
					mimic:FireOnce()
					mimic:Remove()
				end)

				return true
			end)

			if owner:IsBot() then
				timer.Simple(0.2, function()
					if not IsValid(hurtbox) then
						return
					end

					owner:FaceEntity(hurtbox)
					owner:RunScriptCode("activator.PressFireButton(0.1)", owner)
				end)

				-- local logic
				-- logic = timer.Create(0, function ()
				-- 	if not IsValid(hurtbox) then
				-- 		timer.Stop(logic)
				-- 		return
				-- 	end

				-- 	owner:FaceEntity(hurtbox)
				-- 	owner:RunScriptCode("activator.PressFireButton(0.1)", owner)
				-- end, 0)
			end
		end)
	end)
end)

local function ball(owner)
	if owner.m_hActiveWeapon ~= owner:GetPlayerItemBySlot(LOADOUT_POSITION_SECONDARY) then
		return
	end

	local handle = owner:GetHandleIndex()

	if cooldowns[handle] then
		if CurTime() < cooldowns[handle] then
			return
		end
	end

	cooldowns[handle] = CurTime() + COOLDOWN

	local primary = owner:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY)

	-- disable attacking while animation plays
	primary:SetAttributeValue("no_attack", 1)

	timer.Simple(0.1, function()
		primary:SetAttributeValue("no_attack", nil)
	end)

	-- play shortstop shove sequence
	for _, viewmodel in pairs(ents.FindAllByClass("tf_viewmodel")) do
		if viewmodel.m_hOwner == owner then
			viewmodel.m_nSequence = 50
			break
		end
	end

	local mimic = ents.CreateWithKeys("tf_point_weapon_mimic", {
		["$preventshootparent"] = 1,

		TeamNum = owner.m_iTeamNum,
		["$weaponname"] = "BALL_SHOOTER",
	}, true, true)

	local eyeAngles = getEyeAngles(owner)

	if owner:IsBot() then
		eyeAngles = Vector(eyeAngles.x - 15, eyeAngles.y, eyeAngles.z)
	end

	local scale = owner.m_flModelScale

	mimic:SetAbsOrigin(owner:GetAbsOrigin() + Vector(0, 0, 50 * scale))
	mimic:SetAbsAngles(eyeAngles)

	mimic["$SetOwner"](mimic, owner)

	mimic:FireOnce()
	mimic:Remove()
end

function UltrakillDied(_, activator)
	if not IsValid(activator) then
		return
	end

	local handle = activator:GetHandleIndex()

	local callbacks = ballCallbacks[handle]

	for _, id in pairs(callbacks) do
		activator:RemoveCallback(id)
	end

	ballCallbacks[handle] = nil
end

function UltrakillSpawned(_, activator)
	local handle = activator:GetHandleIndex()
	local callbacks = {}

	ballCallbacks[handle] = callbacks

	local primary = activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY)

	local held = nil

	local function stopHeld()
		if not held then
			return
		end

		timer.Stop(held)

		held = nil
	end

	local function removeCallbacks()
		stopHeld()

		if not IsValid(activator) then
			return
		end

		UltrakillDied(_, activator)

		ballCallbacks[handle] = nil
		cooldowns[handle] = nil
	end

	callbacks.onPress = activator:AddCallback(ON_KEY_PRESSED, function(_, key)
		if held then
			return
		end

		if key ~= IN_ATTACK2 then
			return
		end

		ball(activator)

		held = timer.Create(0.1, function()
			if not IsValid(activator) then
				return true -- cancel
			end

			ball(activator)
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
