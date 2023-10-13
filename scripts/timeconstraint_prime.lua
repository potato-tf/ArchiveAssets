-- powered by schizophrenia

local TIMECONSTRAINT_WAVE = 7
local realcontraint

local RED_PVP_SPAWN = Vector(1600, -556, 290)
local BLU_PVP_SPAWN = Vector(452.55, -3203, 500)

local classIndices_Internal = {
	[1] = "Scout",
	[3] = "Soldier",
	[7] = "Pyro",
	[4] = "Demoman",
	[6] = "Heavyweapons",
	[9] = "Engineer",
	[5] = "Medic",
	[2] = "Sniper",
	[8] = "Spy",
}

local DEATH_INSULTS = {
	Scout = {
		"Jumping won't save you, %s.",
		"Try not running straight to the robots, %s.",
		"Try upgrading your primary weapon, %s.",
	},
	Soldier = {
		"Try not missing your rockets, %s.",
		"Can't rocket jump out of that one, %s?",
	},
	Pyro = {
		--"Hey %s! Did you know that the airblast force upgrade makes you take 50%% more damage?",
		--"Hey %s! Did you know that equipping the scorch shot makes you take 150%% more damage?",
		"%s, have you considered not walking straight towards me?",
		"Burn in your own failure, %s.",
	},
	Demoman = {
		"Try using your movement keys next time, %s.",
		"Are you actually drunk, %s? You're playing like you are.",
		"Your incompetency is truly explosive, %s.",
	},
	Heavyweapons = {
		"Consider playing a more interesting class, %s.",
		"I hope that got you to leave a negative review on the end-of-operation survey, %s.",
		"Keep standing directly in front of me, %s, see how well that goes next time.",
	},
	Engineer = {
		"Build yourself better gamesense, %s.",
		"Sentry blocking going well, aye %s?",
		-- "Unequip the wrangler, %s.",
	},
	Medic = {
		"Nice healing, %s.",
		"Try idling more %s, maybe that will work.",
		"Too bad you can't reanimate yourself, %s.",
	},
	Sniper = {
		"Stop aiming for my body and start aiming to be better at the game, %s.",
		"You're supposed to shoot the head, %s.",
		"Thanks for standing still, %s!",
	},
	Spy = {
		"I hate the french.",
		"Try running in circles more, %s.",
		"Couldn't dead ring that one, %s? Unfortunate.",
	},
}

-- flags
-- 1: main wave
-- 2: support
-- 4: mission support
-- 8: giant
-- 16: crit

local WAVE_ICONS = {
    [1] = {
        [1] = {
            name = "timer_lite",
            flag = 8,
            count = 1,
        },
    },
    [2] = {
        [1] = {
            name = "timer_lite",
            flag = 8,
            count = 1,
        },
        [2] = {
            name = "heavy_chief",
            flag = 8,
            count = 1,
        },
        [3] = {
            name = "soldier_sergeant_crits",
            flag = 24,
            count = 1,
        },
    },
}

local wavebarLogic

local randomIcons = {
	"scout",
	"soldier",
	"heavy",
	"demo",
	"pyro",
	"soldier_spammer",
	"spy",
	"pyro_dragon_fury",
	"soldier_blackbox",
	"demoknight_charge",
	"soldier_bison",
	"demo_bow",
	"medic_giant",
	"timer_lite",
	"helicopter_blue_nys",
	"soldier_barrage",
	"heavy_chief",
	"demoknight_giant",
	"soldier_sergeant_crits",
	"demo_bomber",
	"heavy_shotgun",
}

local iconFlags = {
	soldier_sergeant_crits = 16,
}

local inWave = false
local curWave = nil

local timeconstraint_alive = false
local cur_constraint = false -- current time constraint bot

local pvpActive = false
local gamestateEnded = false
local specialLinePlaying = false

local chosenPlayers = {}
local chosenPlayersSet = {}

local function chatMessage(message)
	local outputMessage = "{blue}" .. "Time-Constraint Prime" .. "{reset} : " .. message

	local allPlayers = ents.GetAllPlayers()

	for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", outputMessage)
	end
end

local function hasTag(tags, tagToFind)
	for _, tag in pairs(tags) do
		if tag == tagToFind then
			return true
		end
	end
end

local function removeCallbacks(bot, callbacks)
	if not IsValid(bot) then
		return
	end

	for _, callbackId in pairs(callbacks) do
		bot:RemoveCallback(callbackId)
	end
end
local function removeTimers(timers)
	for _, timerId in pairs(timers) do
		print(timerId)
		timer.Stop(timerId)
	end
end

local function resetWavebar()
	if wavebarLogic then
		timer.Stop(wavebarLogic)
		wavebarLogic = nil
	end

	local objResource = ents.FindByClass("tf_objective_resource")

	objResource:ResetFakeSendProp("m_nMannVsMachineWaveCount")
	objResource:ResetFakeSendProp("m_nMannVsMachineMaxWaveCount")

	-- local objResource = ents.FindByClass("tf_objective_resource")

	-- objResource.m_nMannVsMachineWaveEnemyCount = 1

	-- objResource.m_nMannVsMachineWaveClassFlags[1] = 9
	-- objResource.m_iszMannVsMachineWaveClassNames[1] = "timer_lite"

	-- for i = 1, #objResource.m_nMannVsMachineWaveClassCounts do
	--     if i > 1 then
	--         objResource.m_nMannVsMachineWaveClassCounts[i] = 0
	--     end
	-- end
end

local function setWaveBar(subwave)
	if wavebarLogic then
		timer.Stop(wavebarLogic)
		wavebarLogic = nil
	end

	local objResource = ents.FindByClass("tf_objective_resource")

	objResource:SetFakeSendProp("m_nMannVsMachineWaveCount", subwave)

	local subwaveIcons = WAVE_ICONS[subwave]

	local totalCount = 0
	for _, iconData in pairs(subwaveIcons) do
		totalCount = totalCount + iconData.count
	end

	objResource.m_nMannVsMachineWaveEnemyCount = totalCount

	objResource.m_nMannVsMachineWaveClassFlags[1] = 9
	objResource.m_iszMannVsMachineWaveClassNames[1] = "timer_lite"

	for i = 1, #objResource.m_iszMannVsMachineWaveClassNames do
	    if subwaveIcons[i] then
	        objResource.m_iszMannVsMachineWaveClassNames[i] = subwaveIcons[i].name
	    end
	end
	for i = 1, #objResource.m_nMannVsMachineWaveClassFlags do
	    if subwaveIcons[i] then
	        objResource.m_nMannVsMachineWaveClassFlags[i] = subwaveIcons[i].flag
	    end
	end
	for i = 1, #objResource.m_nMannVsMachineWaveClassCounts do
	    if subwaveIcons[i] then
	        objResource.m_nMannVsMachineWaveClassCounts[i] = subwaveIcons[i].count
		else
	        objResource.m_nMannVsMachineWaveClassCounts[i] = 0
	    end
	end
end

local playersCallback = {}
local timers = {}

function _TimeConstraintOnWaveInit(wave)
	inWave = false
	curWave = wave

	gamestateEnded = false
	timeconstraint_alive = false
	pvpActive = false
    specialLinePlaying = false

	chosenPlayers = {}
	chosenPlayersSet = {}

	removeTimers(timers)
	for player, plrCallbacks in pairs(playersCallback) do
		removeCallbacks(player, plrCallbacks)
	end

	resetWavebar()

	if wave ~= TIMECONSTRAINT_WAVE then
		return
	end

	-- resetWavebar()

	local objResource = ents.FindByClass("tf_objective_resource")

	timer.Simple(1, function()
		if inWave then
			return
		end

		if curWave ~= TIMECONSTRAINT_WAVE then
			return
		end

		chatMessage("Back so soon?")

		objResource:SetFakeSendProp("m_iszMvMPopfileName", "DOVER 2: TIME-CONSTRAINT'S REVENGE")

		wavebarLogic = timer.Create(0.5, function()
			objResource:SetFakeSendProp("m_nMannVsMachineWaveCount", math.random(1, 100))
			objResource:SetFakeSendProp("m_nMannVsMachineMaxWaveCount", math.random(1, 100))

			for i = 1, #objResource.m_iszMannVsMachineWaveClassNames do
				objResource.m_iszMannVsMachineWaveClassNames[i] = randomIcons[math.random(#randomIcons)]
			end
			for i = 1, #objResource.m_nMannVsMachineWaveClassFlags do
				local random = math.random(1, 4)

				local flag = 1
				if random == 2 then
					flag = 9
				end

				local iconAtIndex = objResource.m_iszMannVsMachineWaveClassNames[i]

				if iconFlags[iconAtIndex] then
					flag = flag + iconFlags[iconAtIndex]
				end

				objResource.m_nMannVsMachineWaveClassFlags[i] = flag
			end

			local totalCount = 0

			for i = 1, #objResource.m_nMannVsMachineWaveClassCounts do
				local count = math.random(0, 999)
				objResource.m_nMannVsMachineWaveClassCounts[i] = count

				totalCount = totalCount + count
			end

			objResource.m_nMannVsMachineWaveEnemyCount = math.floor(totalCount * (math.random(1, 50) / 10))
		end, 0)
	end)
end

function OnWaveStart(wave)
	inWave = true
	resetWavebar()

	if wave ~= TIMECONSTRAINT_WAVE then
		return
	end

	setWaveBar(1)

	-- resetWavebar()
end

local rollbacks = {}

local CLASSES = { "player", "obj_*" }

local function addEntToRollback(ent, class)
	if not ent:IsCombatCharacter() then
		return
	end

	if ent.m_iTeamNum ~= 2 then
		return
	end

	rollbacks[ent] = {
		Origin = ent:GetAbsOrigin(), --+ Vector(0, 0, 0),
		Angles = ent:GetAbsAngles(),
		IsPlayer = class == "player" and true,
	}
end

local function storeRollback()
	rollbacks = {}

	for _, class in pairs(CLASSES) do
		for _, ent in pairs(ents.FindAllByClass(class)) do
			addEntToRollback(ent, class)
		end
	end
end

local function fade()
	local fadeEnt = ents.CreateWithKeys("env_fade", {
		holdtime = 1,
		duration = 0.5,
		rendercolor = "255, 255, 255",
		renderamt = 255,
	}, true, true)

	fadeEnt.Fade(fadeEnt)

	timer.Simple(1, function()
		fadeEnt:Remove()
	end)
end

local function revertRollback()
	fade()

	timer.Simple(0.6, function()
		for _, door in pairs(ents.FindAllByClass("func_door")) do
			door:Remove()
		end

		for _, player in pairs(ents.GetAllPlayers()) do
			if player:IsRealPlayer() then
				player:ForceRespawn()
			elseif player ~= realcontraint then
				player:Suicide()
			end
		end

		for ent, data in pairs(rollbacks) do
			if IsValid(ent) and ent:IsAlive() then
				-- ent:SetAbsOrigin(data.Origin)
				-- ent:SetAbsAngles(data.Angles)

				if data.IsPlayer then
					ent:SetAbsOrigin(data.Origin)
					ent:SnapEyeAngles(data.Angles)

					-- local pitch = ent["m_angEyeAngles[0]"]
					-- local yaw = ent["m_angEyeAngles[1]"]
					-- ent:SnapEyeAngles(Vector(-pitch, yaw, 0))
				else
					ent:Teleport(data.Origin, data.Angles)
				end
			end
		end
	end)
end

-- reanimators are disabled during pvp
-- when outside of pvp (during timeconstraint wave), reanimator flies away after 5 seconds
ents.AddCreateCallback("entity_revive_marker", function(entity)
	if not timeconstraint_alive then
		return
	end

	if not pvpActive then
		timer.Simple(1, function()
			for i = 1, 100 do
				timer.Simple(0.03 * i, function()
					if not IsValid(entity) then
						return
					end

					entity:SetAbsOrigin(entity:GetAbsOrigin() + Vector(0, 0, 5))

					if i == 100 then
						entity:Remove()
					end
				end)
			end
		end)

		return
	end

	timer.Simple(0, function()
		entity:Remove()
	end)
end)

local function handlePlayerDeath(player)
	playersCallback[player] = {}

	playersCallback[player].died = player:AddCallback(ON_DEATH, function()
		if pvpActive then
			return
		end

		if specialLinePlaying then
			return
		end

		if player.m_iTeamNum ~= 2 then
			return
		end

		local allInsults = DEATH_INSULTS[classIndices_Internal[player.m_iClass]]
		local chosenInsult = allInsults[math.random(#allInsults)]

		local name = player:GetPlayerName()

		chatMessage(string.format(chosenInsult, name))
	end)
end

local function Holder(bot)
	timeconstraint_alive = true
	realcontraint = bot

	local allPlayers = ents.GetAllPlayers()

	for _, player in pairs(allPlayers) do
		if player:IsRealPlayer() then
			handlePlayerDeath(player)
		end
	end

	local callbacks = {}

	storeRollback()

	local milkers = {}

	timers.milkCheck = timer.Create(0.1, function()
		if not timeconstraint_alive then
			removeCallbacks(bot, callbacks)
			removeTimers(timers)
		end

		if not cur_constraint or not cur_constraint:IsAlive() then
			return
		end

		local milker = cur_constraint:GetConditionProvider(TF_COND_MAD_MILK)

		if not milker then
			return
		end

		local secondary = milker:GetPlayerItemBySlot(LOADOUT_POSITION_SECONDARY)

		-- prevents mistaking mad milk syringes from mad milk
		if secondary.m_iClassname ~= "tf_weapon_jar_milk" then
			return
		end

		local handle = milker:GetHandleIndex()

		if milkers[handle] then
			return
		end

		milkers[handle] = true

		timer.Simple(1.5, function()
			-- chatMessage("Here, have a better weapon. You're welcome")
			milker:GiveItem("The Winger")
			milker:WeaponSwitchSlot(LOADOUT_POSITION_SECONDARY)
		end)
	end, 0)

	callbacks.died = bot:AddCallback(ON_DEATH, function()
		timeconstraint_alive = false

		removeCallbacks(bot, callbacks)
		removeTimers(timers)

		for player, plrCallbacks in pairs(playersCallback) do
			removeCallbacks(player, plrCallbacks)
			-- removeTimers(timers)
		end
	end)
	callbacks.spawned = bot:AddCallback(ON_SPAWN, function()
		removeCallbacks(bot, callbacks)
		removeTimers(timers)

		for player, plrCallbacks in pairs(playersCallback) do
			removeCallbacks(player, plrCallbacks)
			-- removeTimers(timers)
		end
	end)
end

local function Handle1(bot)
	local callbacks = {}

	storeRollback()

	-- specialLinePlaying = true

	-- timer.Simple(1, function()
	-- 	chatMessage("I've been thinking...")
	-- end)

	-- timer.Simple(4, function()
	-- 	chatMessage("If I simply do not leave spawn, I am invincible.")
	-- end)

	-- timer.Simple(8, function()
	-- 	specialLinePlaying = false
	-- 	chatMessage("You cannot defeat me. Give up while you can.")
	-- end)

	callbacks.died = bot:AddCallback(ON_DEATH, function()
		specialLinePlaying = true

		timer.Simple(0.5, function()
			chatMessage("This has never happened and will not occur again.")
		end)

		timer.Simple(1.7, function()
			chatMessage("Let's do that again.")
		end)

		timer.Simple(3.5, function()
			setWaveBar(1)
			specialLinePlaying = false
			revertRollback()
		end)

		removeCallbacks(bot, callbacks)
	end)
	callbacks.spawned = bot:AddCallback(ON_SPAWN, function()
		removeCallbacks(bot, callbacks)
	end)
end

local function Handle2(bot)
	local callbacks = {}

	storeRollback()

	specialLinePlaying = true

	timer.Simple(1, function()
		chatMessage("That Engineer bot had a couple of his drones rotting in the back.")
	end)

	timer.Simple(5, function()
		specialLinePlaying = false
		chatMessage("What a waste. I have granted them a better purpose.")
	end)

	-- timer.Simple(10, function()
	-- 	chatMessage("Remember this? Say hello to it again.")
	-- end)

	callbacks.died = bot:AddCallback(ON_DEATH, function()
		specialLinePlaying = true

		timer.Simple(0.5, function()
			chatMessage("I knew learning from bosses that just died was not the right choice.")
		end)

		timer.Simple(1.7, function()
			chatMessage("Let's do that again.")
		end)

		timer.Simple(3.5, function()
			setWaveBar(1)
			specialLinePlaying = false
			revertRollback()
		end)

		removeCallbacks(bot, callbacks)
	end)
	callbacks.spawned = bot:AddCallback(ON_SPAWN, function()
		removeCallbacks(bot, callbacks)
	end)
end

local function HandleFinal(bot)
	local callbacks = {}

	storeRollback()

	timer.Simple(2, function()
		chatMessage("What I couldn't do myself,  I could with five of me.")
	end)

	callbacks.died = bot:AddCallback(ON_DEATH, function()
		specialLinePlaying = true

		timer.Simple(0.5, function()
			-- chatMessage("This is getting boring. I'm leaving.")
			chatMessage("This is getting boring. I have an idea.")
		end)

		-- timer.Simple(3.5, function()
		-- 	realcontraint:Suicide()
		-- end)

		timer.Simple(3.5, function()
			setWaveBar(1)
			specialLinePlaying = false
			revertRollback()
		end)

		removeCallbacks(bot, callbacks)
	end)
	callbacks.spawned = bot:AddCallback(ON_SPAWN, function()
		removeCallbacks(bot, callbacks)
	end)
end


local function PvPBluWin()
	if gamestateEnded then
		return
	end

	gamestateEnded = true
	pvpActive = false

	timer.Simple(1, function ()
		chatMessage("Masterfully done my dear friend")
	end)

	timer.Simple(2, function ()
		chatMessage("Let us enjoy this victory together")
	end)
	timer.Simple(3, function ()
		chatMessage("I hope your buddies aren't too mad at you after that")
	end)

	realcontraint:Suicide()
end
local function PvPRedWin()
	if gamestateEnded then
		return
	end

	gamestateEnded = true
	pvpActive = false

	timer.Simple(1, function ()
		chatMessage("How embarrassing")
	end)

	realcontraint:Suicide()
end

local function checkPvPWinCond(dontSayCount)
	local redPlayersAlive = 0
	local bluPlayersAlive = 0

	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() and player:IsAlive() then
			-- if player.m_iTeamNum == TEAM_RED then
			-- 	redPlayersAlive = redPlayersAlive + 1
			-- elseif player.m_iTeamNum == TEAM_BLUE then
			-- 	bluPlayersAlive = bluPlayersAlive + 1
			-- end

			if chosenPlayersSet[player:GetHandleIndex()] then
				bluPlayersAlive = bluPlayersAlive + 1
			else
				redPlayersAlive = redPlayersAlive + 1
			end
		end
	end

	print(redPlayersAlive, bluPlayersAlive)

	if pvpActive and not dontSayCount then
		-- if redPlayersAlive > 0 then
		-- 	local msg = redPlayersAlive > 1 and "%s red players left" or "%s red  player remains!"
		-- 	chatMessage(string.format(msg, tostring(redPlayersAlive)))
		-- end
		local msg = bluPlayersAlive .. " Blu players left. " .. redPlayersAlive .. " Red players remain."
		chatMessage(msg)
	end

	if redPlayersAlive <= 0 then
		PvPBluWin()
	end

	if bluPlayersAlive <= 0 then
		PvPRedWin()
	end
end

function OnPlayerConnected(player)
	if not pvpActive then
		return
	end

	-- prevent spawning during pvp 
	local callback
	callback = player:AddCallback(ON_SPAWN, function()
		player:SetAttributeValue("min respawn time", 999999)

		player:Suicide()
		player:RemoveCallback(callback)
	end)
end

function OnPlayerDisconnected(player)
	if not timeconstraint_alive then
		return
	end

	-- if player.m_iTeamNum == 3 then
	-- 	PvPRedWin()
	-- 	return
	-- end

	checkPvPWinCond()
end

local function getHalfPlayers()
	local allPlayers = ents.GetAllPlayers()
	local allPlayersCount = 0

	local players = {}
	local playersSet = {}

	local playersCount = 0

	for _, player in pairs(allPlayers) do
		if player:IsRealPlayer() and player.m_iTeamNum == 2 then
			-- print("found someone")
			allPlayersCount = allPlayersCount + 1
		end
	end

	for _, player in pairs(allPlayers) do
		if player:IsRealPlayer() and player.m_iTeamNum == 2 then
			-- print("found someone again")
			table.insert(players, player)
			playersSet[player:GetHandleIndex()] = true

			playersCount = playersCount + 1

			if playersCount >= allPlayersCount / 2 then
				break
			end
		end
	end

	return players, playersSet
end

local function HandlePvP(bot)
	local callbacks = {}

	storeRollback()

	-- dialogue reused from dover 1 for now. change later!
	chatMessage("Seeing as I myself am entirely unable to best you all")

	timer.Simple(1.5, function ()
		chatMessage("I have decided that, in order to create a fair matchup")
	end)
	timer.Simple(4, function ()
		chatMessage("You will be pitted against your best players")
	end)

	chosenPlayers = {}
	chosenPlayersSet = {}

	timer.Simple(6.5, function ()
		chosenPlayers, chosenPlayersSet = getHalfPlayers()
		-- PrintTable(chosenPlayers)
		-- PrintTable(chosenPlayersSet)
		-- print("TEST TEST TEST TEST TEST")
		local text = "And that means you"

		for _, player in pairs(chosenPlayers) do
			text = text .. ", " .. player:GetPlayerName()
		end

		chatMessage(text)
	end)

	timer.Simple(8, function ()
		chatMessage("Step right on up fellas, you're on my side now")

		-- cur_constraint.m_bUseBossHealthBar = false
		cur_constraint:SetAttributeValue("is suicide counter", 1)

		for _, chosenPlayer in pairs(chosenPlayers) do
			chosenPlayer:ForceRespawn()

			chosenPlayer:AddCond(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED, 5)

			chosenPlayer:Teleport(BLU_PVP_SPAWN)
			chosenPlayer:AddCond(TF_COND_REPROGRAMMED)
	
			-- no resistance
			-- chosenPlayer:SetAttributeValue("dmg taken from fire reduced", nil)
			-- chosenPlayer:SetAttributeValue("dmg taken from blast reduced", nil)
			-- chosenPlayer:SetAttributeValue("dmg taken from bullets reduced", nil)
			-- chosenPlayer:SetAttributeValue("dmg taken from crit reduced", nil)
			-- chosenPlayer:SetAttributeValue("health regen", nil)
	
			-- chosenPlayer:SetAttributeValue("max health additive bonus", 8000)
			chosenPlayer:SetAttributeValue("cannot pick up intelligence", 1)
	
			chosenPlayer.m_bUseBossHealthBar = true
			-- chosenPlayer.m_bIsMiniBoss = true
	
			-- local chosenPlrCallbacks = {}
			-- chosenPlrCallbacks.died = chosenPlayer:AddCallback(ON_DEATH, function ()
			-- 	PvPRedWin()
	
			-- 	removeCallbacks(chosenPlayer, chosenPlrCallbacks)
			-- end)
			-- chosenPlrCallbacks.removed = chosenPlayer:AddCallback(ON_REMOVE, function ()
			-- 	PvPRedWin()
			-- end)
		end

		for _, redPlayer in pairs(ents.GetAllPlayers()) do
			if redPlayer.m_iTeamNum == 2 then
				redPlayer:ForceRespawn()

				redPlayer:AddCond(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED, 5)
				redPlayer:Teleport(RED_PVP_SPAWN)
			end
		end
	end)
	timer.Simple(10, function ()
		chatMessage("Now give me a show")

		for _, player in pairs(ents.GetAllPlayers()) do
			if player:IsRealPlayer() then
				player.m_bGlowEnabled = 1
				player:ForceRespawnDead()
				player:SetAttributeValue("min respawn time", 999999)
	
				local isChosen = chosenPlayersSet[player:GetHandleIndex()]
	
				local text = not isChosen and
					"ELIMINATE BLU PLAYERS" or
					"ELIMINATE RED PLAYERS"
	
				player:Print(PRINT_TARGET_CENTER, text)
	
				-- if isChosen then
				-- 	goto continue
				-- end
	
				local plrCallbacks = {}
				plrCallbacks.died = player:AddCallback(ON_DEATH, function ()
					checkPvPWinCond()
					removeCallbacks(player, plrCallbacks)
				end)
				-- plrCallbacks.removed = player:AddCallback(ON_REMOVE, function ()
				-- 	checkPvPWinCond()
				-- end)
			end
		end

		pvpActive = true

		-- incase somehow 1 manned
		checkPvPWinCond(true)
	end)

	timer.Simple(15, function ()
		if gamestateEnded then
			return
		end

		chatMessage("Spawn protection for both teams have been disabled")

		-- for _, door in pairs(ents.FindAllByClass("func_door")) do
		-- 	door:Remove()
		-- end
		for _, kit in pairs(ents.FindAllByClass("item_healthkit*")) do
			kit:Remove()
		end
		for _, room in pairs(ents.FindAllByClass("func_respawnroom")) do
			room:Remove()
		end
		for _, room in pairs(ents.FindAllByClass("func_respawnroomvisualizer")) do
			room:Remove()
		end

		if cur_constraint then
			cur_constraint:AddCond(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED)
		end
	end)

	callbacks.died = bot:AddCallback(ON_DEATH, function()
		removeCallbacks(bot, callbacks)
	end)
	callbacks.spawned = bot:AddCallback(ON_SPAWN, function()
		removeCallbacks(bot, callbacks)
	end)
end

local function checkBot(bot, tags)
	if hasTag(tags, "realcontraint") then
		Holder(bot)
		return
	end
	if hasTag(tags, "timeconstraint1") then
		Handle1(bot)
		return true
	end
	if hasTag(tags, "timeconstraint2") then
		Handle2(bot)
		return true
	end
	-- if hasTag(tags, "timeconstraint3") then
	-- 	Handle3(bot)
	-- 	return true
	-- end
	if hasTag(tags, "timeconstraintFinal") then
		HandleFinal(bot)
		return true
	end

	if hasTag(tags, "timeconstraintPvP") then
		HandlePvP(bot)
		return true
	end
end

function _OnWaveSpawnBot_TimeConstraint(bot, _, tags)
	local result = checkBot(bot, tags)

	if result then
		cur_constraint = bot
	end
end

