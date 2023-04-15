local holdfirePlayers = {}

local BASE_CLIP = 4

function EnableHoldFire(_, activator)
	local handleIndex = activator:GetHandleIndex()

	local primary = activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY)

	local lastClip = primary.m_iClip1
	local canAttack = true

	local logic
	logic = timer.Create(0.1, function()
		if not IsValid(activator) then
			timer.Stop(logic)
			holdfirePlayers[handleIndex] = nil
			return
		end

		if activator.m_hActiveWeapon ~= primary then
			primary:SetAttributeValue("no_attack", nil)
			return
		end

		local clipBonusMult = primary:GetAttributeValueByClass("mult_clipsize", 1)
		local clipBonusAtomic = primary:GetAttributeValueByClass("mult_clipsize_upgrade_atomic", 0)

		local maxClip = (BASE_CLIP * clipBonusMult) + clipBonusAtomic

		local curClip = primary.m_iClip1

		-- print(curClip, maxClip)
		if curClip == maxClip then
			canAttack = true
		elseif curClip == 0 then
			canAttack = false
		end

		if not canAttack then
			primary:SetAttributeValue("no_attack", 1)
		else
			primary:SetAttributeValue("no_attack", nil)
		end

		lastClip = curClip
	end, 0)

	local callbacks = {}
	local data = {
		LastClip = lastClip,

		Callbacks = callbacks,
		LogicTimer = logic
	}

	callbacks.Release = activator:AddCallback(ON_KEY_RELEASED, function(_, key)
		if key ~= IN_ATTACK then
			return
		end

		canAttack = false
	end)
	callbacks.Spawned = activator:AddCallback(ON_SPAWN, function()
		if activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY) == primary then
			return
		end
		DisableHoldFire(_, activator)
	end)

	holdfirePlayers[handleIndex] = data
end

function DisableHoldFire(_, activator)
	local index = activator:GetHandleIndex()

	local data = holdfirePlayers[index]
	activator:GetPlayerItemBySlot(LOADOUT_POSITION_PRIMARY):SetAttributeValue("no_attack", nil)

	timer.Stop(holdfirePlayers[index].LogicTimer)
	for _, callbackId in pairs(data.Callbacks) do
		activator:RemoveCallback(callbackId)
	end

	holdfirePlayers[index] = nil
end

-- function OnPlayerDisconnected(player)
-- 	DisableHoldFire(nil, player)
-- end