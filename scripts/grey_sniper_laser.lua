--Originally made by Royall, a few values were swapped to get it to work for greys and to change the laser color
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

function LaserOnAim(_, activator)
	local laser = ents.CreateWithKeys("info_particle_system", {
		effect_name = "laser_sight_beam",
		start_active = 0,
		flag_as_weather = 0,
	}, false)

	laser:SetName("le_laser")

	local pointer = Entity("info_particle_system", true)
	local color = Entity("info_particle_system", true)

	pointer:SetName("le_laserpointer")
	color:SetName("le_lasercolor")

	color:SetAbsOrigin(Vector(65, 65, 65))

	laser.m_hControlPointEnts[1] = pointer
	laser.m_hControlPointEnts[2] = color

	local callbacks = {}

	local started = false

	local check

	-- might cause a client side memory leak because the laser isn't cleared when the laser entity itself is
	-- who knows!
	-- this is a bandaid to forcefully hide the lasers out of sight (and out of mind. don't think about it)
	local function hideLaser()
		if not IsValid(laser) then
			-- print("nah")
			return
		end

		laser:Stop()

		laser:SetAbsOrigin(pointer:GetAbsOrigin())
	end

	local terminated = false

	local function terminate()
		if terminated then
			return
		end

		terminated = true

		timer.Stop(check)
		removeCallbacks(activator, callbacks)

		hideLaser()

		timer.Simple(0.1, function()
			for _, e in pairs({ laser, pointer, color }) do
				if IsValid(e) then
					e:Remove()
				end
			end
		end)
	end

	check = timer.Create(0.015, function()
		if activator.m_iTeamNum == 2 or activator.m_iTeamNum == 3 then
			terminate()
			return
		end

		if not IsValid(activator) or not activator:IsAlive() then
			terminate()
			return
		end

		if not activator:InCond(0) then
			if started then
				hideLaser()

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