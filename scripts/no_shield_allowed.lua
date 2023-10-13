local EMP_TAG = "use_emp"

local shieldCanteenBot = false
local shieldCanteenBotCallbacks = {}

local function removeCanteenBotCallbacks()
	if not shieldCanteenBot then
		return
	end

	for _, callback in pairs(shieldCanteenBotCallbacks) do
		shieldCanteenBot:RemoveCallback(callback)
	end

	shieldCanteenBotCallbacks = {}
end

local function noShieldCanteen(bot)
	if shieldCanteenBot then
		removeCanteenBotCallbacks()
	end

	shieldCanteenBot = bot

	shieldCanteenBotCallbacks[1] = bot:AddCallback(ON_DEATH, function()
		removeCanteenBotCallbacks()
		shieldCanteenBot = false
	end)
	shieldCanteenBotCallbacks[2] = bot:AddCallback(ON_SPAWN, function()
		removeCanteenBotCallbacks()
		shieldCanteenBot = false
	end)
end

function OnWaveSpawnBot(bot, _, tags)
	for _, tag in pairs(tags) do
		if tag == EMP_TAG then
			noShieldCanteen(bot)
			break
		end
	end
end

local activeShieldOwners = {}
ents.AddCreateCallback("entity_medigun_shield", function(shield)
	if not shieldCanteenBot then
		return
	end

	timer.Simple(0.1, function()
		if shield.Registered then
			return
		end

		if shield.m_iTeamNum ~= 2 then
			return
		end

		local shieldOwner = shield.m_hOwnerEntity

		if not IsValid(shieldOwner) then
			return
		end

		if shieldOwner.ShieldReplacementFlag then
			return
		end

		local handle = shieldOwner:GetHandleIndex()

		if activeShieldOwners[handle] then
			return
		end

		activeShieldOwners[handle] = true

		timer.Simple(0.8, function()
			local empText = "{blue}"
				.. shieldCanteenBot:GetPlayerName()
				.. "{reset} has used their {9BBF4D}EMP{reset} Power Up Canteen!"

			shieldOwner.m_flRageMeter = 0

			local allPlayers = ents.GetAllPlayers()

			for _, player in pairs(allPlayers) do
				player:AcceptInput("$DisplayTextChat", empText)
				player:AcceptInput("$PlaySoundToSelf", "=35|mvm/mvm_used_powerup.wav")
			end

			activeShieldOwners[handle] = nil
		end)
	end)
end)
