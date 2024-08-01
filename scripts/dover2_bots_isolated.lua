-- handles cancelling ambulance follower behavior
local ambulanceFollowers = {}
local ambulanceIsDead = false

-- collective health bar 
local collectiveBots = {}
local collectiveHealthBarBot = false

-- function GetMaxHealth(player)
-- 	local net = player:GetNetIndex() + 1

-- 	local playerResource = ents.FindByClass("tf_player_manager")

-- 	local props = playerResource:DumpProperties()

-- 	for playerNetIndex, maxHealth in pairs(props.m_iMaxBuffedHealth) do
-- 		if playerNetIndex == net then
-- 			return maxHealth + player:GetAttributeValueByClass("add_maxhealth_nonbuffed", 0)
-- 		end
-- 	end
-- end

-- COLLECTIVE CONSCIOUSNESS CONTROLLED AS YOU WILL SEEEEEEEEEE
local function updateCollective()
    local playerResource = ents.FindByClass("tf_player_manager")

    local props = playerResource:DumpProperties()

    local function getMaxHealth(player)
        local net = player:GetNetIndex() + 1

        for playerNetIndex, maxHealth in pairs(props.m_iMaxBuffedHealth) do
            if playerNetIndex == net then
                return maxHealth + player:GetAttributeValueByClass("add_maxhealth_nonbuffed", 0)
            end
        end
    end

    local totalHealth = 0
    local totalMaxHealth = 0
    for bot, _ in pairs(collectiveBots) do
        local health = bot:IsAlive() and bot.m_iHealth or 0

        totalHealth = totalHealth + health
        totalMaxHealth = totalMaxHealth + getMaxHealth(bot)
    end

    collectiveHealthBarBot.m_iHealth = totalHealth
    if totalMaxHealth > getMaxHealth(collectiveHealthBarBot) then
        collectiveHealthBarBot:SetAttributeValue("hidden maxhealth non buffed", totalMaxHealth - 1)
    end

    if totalHealth <= 0 then
        collectiveHealthBarBot:Suicide()
    end
end

local function handleCollectiveTagCheck(bot, tag)
    if tag == "collective_healthbar" then
        bot.m_bIsMiniBoss = 0
        collectiveHealthBarBot = bot

        local callbacks = {}
        callbacks[1] = bot:AddCallback(ON_DEATH, function()
            for _, id in pairs(callbacks) do
                bot:RemoveCallback(id)
            end
            collectiveHealthBarBot = false
        end)
        callbacks[2] = bot:AddCallback(ON_SPAWN, function()
            for _, id in pairs(callbacks) do
                bot:RemoveCallback(id)
            end
            collectiveHealthBarBot = false
        end)
        return true
    end

    if tag == "collective_bot" then
        local callbacks = {}

        collectiveBots[bot] = true

        callbacks[1] = bot:AddCallback(ON_DAMAGE_RECEIVED_POST, function()
            updateCollective()
        end)

        callbacks[2] = bot:AddCallback(ON_DEATH, function()
            for _, id in pairs(callbacks) do
                bot:RemoveCallback(id)
            end
            updateCollective()
            collectiveBots[bot] = nil
        end)
        callbacks[3] = bot:AddCallback(ON_SPAWN, function()
            for _, id in pairs(callbacks) do
                bot:RemoveCallback(id)
            end
            collectiveBots[bot] = nil
        end)

        updateCollective()
        return true
    end
end

-- pair/totem bots
-- tag format: pair_<PAIR GROUP NAME>_[carrier/carried]
local BASE_HEIGHT = 80

local waiting = {
    Carriers = {},
    Carried = {},
}

function OnWaveReset(wave) --Cleans list of ambulance followers
    for index, bot in pairs(ambulanceFollowers) do
        ambulanceFollowers[index] = nil
    end
    ambulanceFollowers = {}
    ambulanceIsDead = false
    waiting = {
        Carriers = {},
        Carried = {},
    }
end

function OnWaveSpawnBot(bot, wave, tags)
    -- _OnWaveSpawnBot_CustomWeapon(bot, wave ,tags)
    -- _OnWaveSpawnBot_BossResistance(bot, wave ,tags)
    -- _OnWaveSpawnBot_TimeConstraint(bot, wave ,tags)

    for _, tag in pairs(tags) do

        if tag == "ambulance_follower" then
			if ambulanceIsDead == true then
				print("Ambulance follower spawned but ambulance is dead lol")
				bot:BotCommand("stop interrupt action")
				bot:BotCommand("switch_action FetchFlag")
				bot:SetAttributeValue("cannot pick up intelligence", 0)
			else
				print("An mbulance follower spawned!")
				ambulanceFollowers[bot:GetHandleIndex()] = bot
                timer.Simple(1, function() 
                    bot:BotCommand("switch_action Mobber")
                    bot:BotCommand("interrupt_action -posent ambulancetank -duration 9999")
                end)
                
                bot:SetAttributeValue("cannot pick up intelligence", 1)
			end
		end

        if handleCollectiveTagCheck(bot, tag) then
            goto continue
        end

        

        local split = {}

        for k, _ in string.gmatch(tag, '([^_]+)') do
            table.insert(split, k)
        end

        if split[1]:lower() == "pair" then
            local pairName = split[2]
            local pairPlacement = split[3]:lower()

            local waitTable
            local otherWaitTable

            if pairPlacement == "carried" then
                waitTable = waiting.Carried
                otherWaitTable = waiting.Carriers

                timer.Simple(1, function ()
                    bot:SetAttributeValue("no_attack", 1)
                end)
                bot:AddCond(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED)
            elseif pairPlacement == "carrier" then
                waitTable = waiting.Carriers
                otherWaitTable = waiting.Carried
            else
                print("invalid carrier placement tag")
            end

            if not waitTable[pairName] then
                waitTable[pairName] = {}
            end

            table.insert(waitTable[pairName], bot)
            if otherWaitTable[pairName] and otherWaitTable[pairName][1] then
                PairBots(waiting.Carriers[pairName][1], waiting.Carried[pairName][1])

                waiting.Carriers[pairName] = nil
                waiting.Carried[pairName] = nil
            end
        end

        ::continue::
    end
end

function cancelAmbulanceFollowers()
	ambulanceIsDead = true
	for _, bot in pairs(ambulanceFollowers) do
		print("Cancelled a bot's ambulance follow")
		bot:BotCommand("stop interrupt action")
		bot:BotCommand("switch_action FetchFlag")
		bot:SetAttributeValue("cannot pick up intelligence", 0)
	end
end

AddEventCallback('player_death', function(event) 
	local deadPlayer = ents.GetPlayerByUserId(event.userid)
	ambulanceFollowers[deadPlayer:GetHandleIndex()] = nil
end)

function OnWaveInit(wave)
    -- _TimeConstraintOnWaveInit(wave)
    waiting = {
        Carriers = {},
        Carried = {},
    }
    ambulanceIsDead = false
    collectiveBots = {}
    collectiveHealthBarBot = false
end

function PairBots(carrier, carried)
	local height = BASE_HEIGHT * (carrier.m_flModelScale)

	local carrierCallbacks = {}
	local carrierTimer

	local lastOrigin
	local function teleport()
		if not IsValid(carrier) then
			if not lastOrigin then
				return
			end

            if not IsValid(carried) or not carried:IsAlive() then
                return
            end

			-- prevents carried briefly disappearing after carrier death
			carried:SetAbsOrigin(lastOrigin + Vector(0, 0, height))

			return
		end

		local origin = carrier:GetAbsOrigin()
		carried:SetAbsOrigin(origin + Vector(0, 0, height))

		lastOrigin = origin
	end

	carrierTimer = timer.Create(0, function()
		teleport()
	end, 0)

	teleport()

    local function endPairLogic()
        for _, id in pairs(carrierCallbacks) do
            carrier:RemoveCallback(id)
        end
        timer.Stop(carrierTimer)
    end

	carrierCallbacks.died = carrier:AddCallback(ON_DEATH, function()
		carried:RemoveCond(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED)
		timer.Simple(2, function ()
			carried:SetAttributeValue("no_attack", nil)
		end)

		-- carried:ClearFakeParent()
		endPairLogic()

		if not lastOrigin then
			return
		end

		-- suspend in place to prevent source jank from teleporting it back to spawn
		local iterated = 1
		for _ = 0, 1, 0.1 do
			timer.Simple(0.07 * iterated, function()
				carried:SetAbsOrigin(lastOrigin)
			end)

			iterated = iterated + 1
		end
	end)
	carrierCallbacks.spawn = carrier:AddCallback(ON_SPAWN, function()
		endPairLogic()
	end)
end

