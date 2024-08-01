local function removeCallbacks(player, callbacks)
	if not IsValid(player) then
		return
	end

	for _, callbackId in pairs(callbacks) do
		player:RemoveCallback(callbackId)
	end
end

local function getEyeAngles(player)
	local pitch = player["m_angEyeAngles[0]"]
	local yaw = player["m_angEyeAngles[1]"]

	return Vector(pitch, yaw, 0)
end

-- might cause a client side memory leak because the laser isn't cleared when the laser entity itself is
-- who knows!
-- this is a bandaid to forcefully hide the lasers out of sight (and out of mind. don't think about it)
local function hideLaser(laser, pointer)
	if not IsValid(laser) then
		return
	end

	laser:Stop()
	laser:SetAbsOrigin(pointer:GetAbsOrigin())
end

function LaserOnAim(_, activator)
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

	color:SetAbsOrigin(Vector(255, 0, 0))

	laser.m_hControlPointEnts[1] = pointer
	laser.m_hControlPointEnts[2] = color

	for _, e in pairs({ laser, pointer, color }) do
		e["$SetOwner"](e, activator)
	end

	laser.m_iClassname = "env_sprite"
	pointer.m_iClassname = "env_sprite"

	local callbacks = {}

	local started = false

	local check

	local terminated = false

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
		if activator.m_iTeamNum == 0 or activator.m_iTeamNum == 1 then
			terminate()
			return
		end

		if not IsValid(activator) or not activator:IsAlive() then
			terminate()
			return
		end

		if not activator:InCond(0) then
			if started then
				hideLaser(laser, pointer)

				started = false
			end

			return
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

AddEventCallback("mvm_reset_stats", function ()
	print("cleaning up leftover lasers")

	for _, laser in pairs(ents.FindAllByName("le_laser*")) do
		local ownerId = tostring(string.match(laser:GetName(), "%d+"))

		local pointer = ents.FindByName("le_laserpointer" .. ownerId)

		print(ownerId, pointer)
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