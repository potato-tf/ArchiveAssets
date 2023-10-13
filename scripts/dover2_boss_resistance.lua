local shieldCanteenBot = false
local function noShieldCanteen(bot)
    local callbacks = {}
    local function removeCallbacks()
        for _, callback in pairs(callbacks) do
            bot:RemoveCallback(callback)
        end
    end

    shieldCanteenBot = bot

    callbacks[1] = bot:AddCallback(ON_DEATH, function ()
        shieldCanteenBot = false
        removeCallbacks()
    end)
    callbacks[2] = bot:AddCallback(ON_SPAWN, function ()
        shieldCanteenBot = false
        removeCallbacks()
    end)
end

-- max amount of damage that can receive before applying dynamic resistance
-- also used as the base for calculation, the further recent damage goes from this base
-- the higher the damage reduction
local MAXIMUM_BASE_RECENT_DAMAGE = 1000
-- reduce this much every 0.1 second
-- if you need to reduce the overall resistance, increase this
local RECENT_DAMAGE_DECAY = 15

local function minigunDynamicResistance(bot)
    local callbacks = {}
    local loop
    local function removeCallbacks()
        for _, callback in pairs(callbacks) do
            bot:RemoveCallback(callback)
        end

        if loop then
            timer.Stop(loop)
        end
    end

    local recentDamage = 0

    callbacks[1] = bot:AddCallback(ON_DEATH, function()
        shieldCanteenBot = false
        removeCallbacks()
    end)
    callbacks[2] = bot:AddCallback(ON_SPAWN, function()
        shieldCanteenBot = false
        removeCallbacks()
    end)
    callbacks[3] = bot:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageInfo)
        if not damageInfo.Weapon then
            return
        end

        if damageInfo.Weapon.m_iClassname ~= "tf_weapon_minigun" then
            return
        end

        if recentDamage < MAXIMUM_BASE_RECENT_DAMAGE then
            return
        end

        local diff = recentDamage / MAXIMUM_BASE_RECENT_DAMAGE
        local reductionMult =  1 / diff

        damageInfo.Damage = damageInfo.Damage * reductionMult

        return true
    end)
    callbacks[4] = bot:AddCallback(ON_DAMAGE_RECEIVED_POST, function(_, damageInfo)
        if not damageInfo.Weapon then
            return
        end

        if damageInfo.Weapon.m_iClassname ~= "tf_weapon_minigun" then
            return
        end

        recentDamage = recentDamage + damageInfo.Damage
    end)

    loop = timer.Create(0.1, function()
        if not IsValid(bot) then
            timer.Stop(loop)
            return
        end

        if not bot:IsAlive() then
            removeCallbacks()
            return
        end

        -- print("Recent minigun damage: "..tostring(recentDamage))
        recentDamage = math.max(recentDamage - RECENT_DAMAGE_DECAY, 0)
    end, 0)
end

local resistanceTags = {
    boss_resistance = function(bot)
        noShieldCanteen(bot)
        minigunDynamicResistance(bot)
    end
}

function _OnWaveSpawnBot_BossResistance(bot, wave, tags)
    for _, tag in pairs(tags) do
        if resistanceTags[tag] then
            print(tag)
            resistanceTags[tag](bot)
        end
    end
end

local activeShieldOwners = {}
ents.AddCreateCallback("entity_medigun_shield", function (shield)
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