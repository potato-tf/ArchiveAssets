--Script is made to facilitate aiming the laser eyes of clone commander's grapid phase, because both the rafmod rotator and aimfollow modules are shit.
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

	return Vector(pitch - 2, yaw, 0)
end

function LaserEyesLogic(_, activator)

	local eyeLaserMimic = ents.FindByName("biden_blast")
	
	if eyeLaserMimic == nil then
		terminate()
		print("No laser mimic to touch, committing die")
		return
	end

	local callbacks = {}

	local check

	local terminated = false


	local function terminate()
		if terminated then
			return
		end
		timer.Stop(check)
		removeCallbacks(activator, callbacks)

		terminated = true
	end

	check = timer.Create(0.015, function()

		if not IsValid(activator) or not activator:IsAlive() then
			terminate()
			return
		end

	if eyeLaserMimic:IsValid() == false then
		terminate()
		print("No laser mimic to touch, committing die")
		return
	end		

		local eyeAngles = getEyeAngles(activator)		
		
		eyeLaserMimic:SetAbsAngles(eyeAngles)

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
	callbacks.waveReset = AddEventCallback("mvm_reset_stats", function ()
		terminate()	
	end)	
end