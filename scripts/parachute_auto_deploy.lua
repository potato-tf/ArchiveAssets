--almost all of the code here was "borrowed" from Royall's sniper laser script, knowing when you're dead
--and properly cleaning up is quite important for any script applied directly to bots.
--Trace is from a sample script written by Bazooks
local function removeCallbacks(player, callbacks)
	if not IsValid(player) then
		return
	end

	for _, callbackId in pairs(callbacks) do
		player:RemoveCallback(callbackId)
	end
end

function Parachute(_, activator)

	local callbacks = {}

	local check

	local terminated = false
	
	local Zvalue

	local function terminate()
		if terminated then
			return
		end

		terminated = true

		timer.Stop(check)
		removeCallbacks(activator, callbacks)

	end

	check = timer.Create(0.015, function()

		if not IsValid(activator) or not activator:IsAlive() then
			terminate()
			return
		end

			local TraceDownwards = {
				start = activator, -- Start position vector. Can also be set to entity, in this case the trace will start from entity eyes position
				endpos = nil, -- End position vector. If nil, the trace will be fired in `angles` direction with `distance` length
				distance = 8192, -- Used if endpos is nil
				angles = Vector(90,0,0), -- Used if endpos is nil
				mask = MASK_SOLID, -- Solid type mask, see MASK_* globals
				collisiongroup = COLLISION_GROUP_DEBRIS, -- Pretend the trace to be fired by an entity belonging to this group. See COLLISION_GROUP_* globals
				mins = Vector(0,0,0), -- Extends the size of the trace in negative direction
				maxs = Vector(0,0,0), -- Extends the size of the trace in positive direction
				filter = nil -- Entity to ignore. Can be a single entity, table of entities, or a function with a single entity parameter
			}
		local downTraceTable = util.Trace(TraceDownwards) --the two values down here affect the maximum deploy height and the disengage height
		Zvalue = downTraceTable["StartPos"] - downTraceTable["HitPos"] - 68
			if Zvalue[3] >= 200 then --increase this to make the parachute deploy when the bot is higher
			--print ("deploy parachute")
			activator:AddCond(80)
		end
			if Zvalue[3] < 150 then --increase this to make the parachute disengage when the bot is higher
			--print ("no more parachute")
			activator:RemoveCond(80)
		end
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

--this is split off into a separate function so I don't bog down the already somewhat heavy original one with a weapon check
function ParachuteAirstrike(_, activator)

	local callbacks = {}

	local check

	local terminated = false
	
	local Zvalue

	local function terminate()
		if terminated then
			return
		end

		terminated = true

		timer.Stop(check)
		removeCallbacks(activator, callbacks)

	end

	check = timer.Create(0.015, function()

		if not IsValid(activator) or not activator:IsAlive() then
			terminate()
			return
		end

			local TraceDownwards = {
				start = activator, -- Start position vector. Can also be set to entity, in this case the trace will start from entity eyes position
				endpos = nil, -- End position vector. If nil, the trace will be fired in `angles` direction with `distance` length
				distance = 8192, -- Used if endpos is nil
				angles = Vector(90,0,0), -- Used if endpos is nil
				mask = MASK_SOLID, -- Solid type mask, see MASK_* globals
				collisiongroup = COLLISION_GROUP_DEBRIS, -- Pretend the trace to be fired by an entity belonging to this group. See COLLISION_GROUP_* globals
				mins = Vector(0,0,0), -- Extends the size of the trace in negative direction
				maxs = Vector(0,0,0), -- Extends the size of the trace in positive direction
				filter = nil -- Entity to ignore. Can be a single entity, table of entities, or a function with a single entity parameter
			}
		local downTraceTable = util.Trace(TraceDownwards) --the two values down here affect the maximum deploy height and the disengage height
		Zvalue = downTraceTable["StartPos"] - downTraceTable["HitPos"] - 68
			if Zvalue[3] >= 200 then --increase this to make the parachute deploy when the bot is higher
			--print ("deploy parachute")
			activator:AddCond(80)
			activator:SetAttributeValue("fire rate bonus HIDDEN", 0.5)
		end
			if Zvalue[3] < 150 then --increase this to make the parachute disengage when the bot is higher
			--print ("no more parachute")
			activator:RemoveCond(80)
			activator:SetAttributeValue("fire rate bonus HIDDEN", nil)
		end
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