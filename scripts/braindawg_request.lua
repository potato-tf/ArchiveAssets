local playersCount = 0
local playersHandle = {}

local playersAlive = 0

local deadPlayersHandle = {}

local inWave = false

local lastSpellsDistributeID = false
local currentLastManCritPlayer

function OnWaveStart(wave)
	inWave = TickCount()
	SpecificPlayersCountCheck()
end

function OnWaveReset(wave)
	onNotInWave()
end

function OnWaveSuccess(wave)
	onNotInWave()
end

function OnWaveFail(wave)
	onNotInWave()
end

function onNotInWave()
	inWave = false

	--remove crit on wave end if last man is still alive on transition
	if currentLastManCritPlayer then
		currentLastManCritPlayer:RemoveCond(34)
		currentLastManCritPlayer = nil
	end
end

function OnPlayerConnected(player)
	if not player:IsRealPlayer() then
	--	player:AddCallback(ON_SPAWN, onBotSpawn)
		return
	end
		--prevent callbacks from stacking if wave restarting
	if playersHandle[player:GetHandleIndex()] then
		return
	end

	-- dumb half fix
	if playersCount < 6 and playersAlive < 6 then 
		playersCount = playersCount + 1
		playersAlive = playersAlive + 1
		playersHandle[player:GetHandleIndex()] = true
		onPlayerCountChange(player)
	end

	player:AddCallback(ON_DEATH, onPlayerDeath)
	player:AddCallback(ON_SPAWN, onPlayerSpawn)

	if inWave then
		player:SetAttributeValue("min respawn time", 999999)
		player:SetAttributeValue("is suicide counter", -1000) --just incase late joiners spawn in
	end
end

function OnPlayerDisconnected(player)
    -- just in case
    if not player:IsRealPlayer() then
        return
    end

    local handle = player:GetHandleIndex()

    if not deadPlayersHandle[handle] then
        playersAlive = playersAlive - 1
    end

    playersHandle[handle] = nil
    deadPlayersHandle[handle] = nil

    playersCount = playersCount - 1

    onPlayerCountChange(player)
end

function onPlayerSpawn(player)
	--didn't die before respawning due to wave restarting class switching etc or just spawned in for the first time
	if not deadPlayersHandle[player:GetHandleIndex()] then
		return
	end

--	print("a bloke lived")
--	print(player)

	deadPlayersHandle[player:GetHandleIndex()] = nil

	playersAlive = playersAlive + 1
	onPlayerCountChange(player)
end

-- function onBotSpawn(player) 
--	player:AcceptInput( "$SetProp$m_bIsMiniBoss" , "1" )
--	player:SetAttributeValue("override footstep sound set" , "9" )
--end

function onPlayerDeath(player)
	if not playersHandle[player:GetHandleIndex()] then
		return
	end

--	print("a bloke died")
--	print(player)

	deadPlayersHandle[player:GetHandleIndex()] = true

	playersAlive = playersAlive - 1
	onPlayerCountChange(player)

	--insta respawn in setup
	if not inWave then
		player:SetAttributeValue("is suicide counter", 0)
		timer.Simple(
			0.1,
			function()
				player:ForceRespawnDead()
			end
		)
	else
		player:SetAttributeValue("min respawn time", 999999)
	end
end

-- give rare spells if at or under 3 players and give crit to last player alive

function SpecificPlayersCountCheck()
	if not inWave then
		return
	end

	if playersAlive > 3 then
		return
	end

 	--set speed if < 3 players die after tank is spawned
	local tank = ents.FindByName("tankboss_ghost")
	if tank then 
		tank:AcceptInput( "SetSpeed" , "55" ) 
	end

--	local bossalive = ents.FindByName("bossbot")
--	local chalices = ents.FindByName("spawners*")
--	local spawnedchalices = ents.FindByClass("func_breakable")

	--REMOVED force spawn the boss chalices early if only 3 players are alive
--	if bossalive and chalices and wave == 5 then 
--		chalices:AcceptInput( "ForceSpawn" )
--	end

	local allPlayers = ents.GetAllPlayers()


	--give crit/minicrit
	if playersAlive == 2 then
		for _, player in pairs(allPlayers) do
			if player:IsRealPlayer() and player:IsAlive() then
				player:AddCond(16)
				player:AddCond(19)
			end
		end
	end
	
	if playersAlive == 1 then
		for _, player in pairs(allPlayers) do
			if player:IsRealPlayer() and player:IsAlive() then
				player:AddCond(34)
				player:RemoveCond(16)
				player:RemoveCond(19)
				currentLastManCritPlayer = player
				break
			end
		end
	else
		--remove crit from last man if someone becomes yesalive again midwave as they are no longer the last man
		if currentLastManCritPlayer then
			currentLastManCritPlayer:RemoveCond(34)
			currentLastManCritPlayer = nil
		end
	end

	--give spells
	if lastSpellsDistributeID and lastSpellsDistributeID == inWave then
		return
	end

	lastSpellsDistributeID = inWave

	for _, player in pairs(allPlayers) do
		if player:IsRealPlayer() and player:IsAlive() then
			player:RollRareSpell()
		end
	end
end

function onPlayerCountChange(player)
	print("players alive: " .. tostring(playersAlive))
	SpecificPlayersCountCheck()
end

function OnWaveSpawnTank(tank , wave) --reduce speed if 3+ players die before tank is spawned
	if tank and wave == 2 and playersAlive < 4 then
		tank:AcceptInput( "SetSpeed" , "55" )
	end
end