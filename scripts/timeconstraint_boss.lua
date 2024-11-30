--I am in your walls
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
		"Jumping won't save you, %s",
		"Unequip the Fan-o-War, %s",
		"Try upgrading your primary weapon, %s"
	},
	Soldier = {
		"Unbind your attack key, %s",
		"Don't buy rocket specialist next time, %s",
	},
	Pyro = {
		"Hey %s! Did you know that the airblast force upgrade makes you take 50%% more damage?",
		"Hey %s! Did you know that equipping the scorch shot makes you take 150%% more damage?",
		"Hey %s! Unbind your airblast key",
	},
	Demoman = {
		"Try using your movement keys next time, %s",
		"Are you actually drunk, %s? You're playing like you are",
		"Your incompetency is truly explosive, %s",
	},
	Heavyweapons = {
		"Consider playing a more interesting class, %s",
		"I hope that got you to leave a negative review on the end-of-operation survey, %s",
		"Keep standing directly infront me, %s, see how that goes next time",
	},
	Engineer = {
		"Build yourself better gamesense, %s",
		"Sentry blocking going well, aye %s?",
		"Unequip the wrangler, %s"
	},
	Medic = {
		"How's that canteen spam going for you, %s?",
		"Try idling more %s, maybe that will work",
		"Too bad you can't reanimate yourself, %s",
	},
	Sniper = {
		"Stop aiming for my head and start aiming to be better at the game, %s",
		"Thanks for standing still, %s!",
	},
	Spy = {
		"I hate the french",
		"Try running in circle harder, %s",
		"Couldn't dead ring that one, %s? Unfortunate",
	}
}

local timeconstraint_alive = false
local cur_constraint = false -- current time constraint bot

local pvpActive = false
local gamestateEnded = false

local specialLinePlaying = false

-- local PHASE3_SUBWAVES = 3
-- local finishedSubwaves = 0

local function chatMessage(string)
	local message = "{blue}"
	.. "Time-Constraint{reset} : "
	.. string

	local allPlayers = ents.GetAllPlayers()
	for _, player in pairs(allPlayers) do
		player:AcceptInput("$DisplayTextChat", message)
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

local rollbacks = {}

local CLASSES = {"player", "obj_*"}

local function storeRollback()
	rollbacks = {}

	for _, class in pairs(CLASSES) do
		for _, ent in pairs(ents.FindAllByClass(class)) do
			if not ent:IsCombatCharacter() then
				goto continue
			end

			if ent.m_iTeamNum ~= 2 then
				goto continue
			end

			rollbacks[ent] = {
				Origin = ent:GetAbsOrigin(), --+ Vector(0, 0, 0),
				Angles = ent:GetAbsAngles(),
				IsPlayer = class == "player" and true
			}

			::continue::
		end
	end
end

local function fade()
	-- local fadeEnt = Entity("env_fade", true)
	local fadeEnt = ents.CreateWithKeys("env_fade", {
		holdtime = 1,
		duration = 0.5,
		rendercolor = ("255, 255, 255"),
		renderamt = 255
	}, true, true)

	fadeEnt.Fade(fadeEnt)

	timer.Simple(1, function ()
		fadeEnt:Remove()
	end)
end

local function revertRollback()
	fade()

	timer.Simple(0.6, function ()
		for _, door in pairs(ents.FindAllByClass("func_door")) do
			door:Remove()
		end

		for _, player in pairs(ents.GetAllPlayers()) do
			if not player:IsRealPlayer() then
				goto continue
			end

			player:ForceRespawn()

			::continue::
		end

		for ent, data in pairs(rollbacks) do
			if not IsValid(ent) or not ent:IsAlive() then
				goto continue
			end

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

			::continue::
		end
	end)
end

ents.AddCreateCallback("entity_revive_marker", function(entity)
	if not pvpActive then
		return
	end

	timer.Simple(0, function ()
		entity:Remove()
	end)
end)

local activeShieldOwners = {}
ents.AddCreateCallback("entity_medigun_shield", function (shield)
	if not timeconstraint_alive then
		return
	end

	if specialLinePlaying then
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

		specialLinePlaying = true

		chatMessage("Projectile Shield?")

		-- aaaaaaaaaaa
		timer.Simple(0.8, function()
			local empText = "{blue}"
			.. "Time-Constraint"
			.. "{reset} has used their {9BBF4D}EMP{reset} Power Up Canteen!"

			shieldOwner.m_flRageMeter = 0

			local allPlayers = ents.GetAllPlayers()

			for _, player in pairs(allPlayers) do
				player:AcceptInput("$DisplayTextChat", empText)
				player:AcceptInput("$PlaySoundToSelf", "=35|mvm/mvm_used_powerup.wav")
			end

			activeShieldOwners[handle] = nil

			timer.Simple(0.8, function()
				chatMessage("I don't think so")

				specialLinePlaying = false
			end)
		end)
	end)
end)

local playersCallback = {}
local timers = {}

function OnWaveInit()
	gamestateEnded = false
	timeconstraint_alive = false
	pvpActive = false

	specialLinePlaying = false

	finishedSubwaves = 0

	removeTimers(timers)
	for player, plrCallbacks in pairs(playersCallback) do
		removeCallbacks(player, plrCallbacks)
	end
end

local function handlePlayerDeath(player)
	playersCallback[player] = {}

	playersCallback[player].died = player:AddCallback(ON_DEATH, function ()
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

	local allPlayers = ents.GetAllPlayers()

	for _, player in pairs(allPlayers) do
		if not player:IsRealPlayer() then
			goto continue
		end

		handlePlayerDeath(player)

		::continue::
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

		specialLinePlaying = true

		chatMessage("Are you seriously using mad milk?")

		timer.Simple(0.8, function ()
			chatMessage("Disgusting")
		end)
		timer.Simple(1.5, function ()
			chatMessage("Here, have a better weapon. You're welcome")
			milker:GiveItem("The Winger")
			milker:WeaponSwitchSlot(LOADOUT_POSITION_SECONDARY)

			milkers[handle] = nil

			specialLinePlaying = false
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

	callbacks.died = bot:AddCallback(ON_DEATH, function()
		specialLinePlaying = true

		timer.Simple(0.5, function ()
			chatMessage("That's not supposed to happen")
		end)

		timer.Simple(1.7, function ()
			chatMessage("Let's do that again")
		end)

		timer.Simple(3.5, function ()
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

	chatMessage("My chariot will carry me to victory")

	callbacks.died = bot:AddCallback(ON_DEATH, function()
		specialLinePlaying = true
		timer.Simple(0.5, function ()
			chatMessage("Fatal miscalculations were made")
		end)

		timer.Simple(1.7, function ()
			chatMessage("No matter, we can redo")
		end)

		timer.Simple(3.5, function ()
			specialLinePlaying = false
			revertRollback()
		end)

		removeCallbacks(bot, callbacks)
	end)
	callbacks.spawned = bot:AddCallback(ON_SPAWN, function()
		removeCallbacks(bot, callbacks)
	end)
end

-- function Phase3SubwaveDone()
-- 	finishedSubwaves = finishedSubwaves + 1

-- 	if finishedSubwaves >= PHASE3_SUBWAVES then
-- 		if not cur_constraint then
-- 			return
-- 		end

-- 		cur_constraint:Suicide()
-- 	end
-- end

local SUBWAVE_3_BOTS_COUNT = 6
local subwave3BotsDied = 0
local function HandleSubwave3Bot(bot)
	local callbacks = {}

	callbacks.died = bot:AddCallback(ON_DEATH, function()
		subwave3BotsDied = subwave3BotsDied + 1

		print("SUBWAVE3 BOTS: " .. subwave3BotsDied .. "/" .. SUBWAVE_3_BOTS_COUNT)

		if subwave3BotsDied >= SUBWAVE_3_BOTS_COUNT then
			if cur_constraint then
				cur_constraint:Suicide()
			else
				print("!!! NO TIME-CONSTRAINT FOUND !!!")
			end
		end

		removeCallbacks(bot, callbacks)
	end)
	callbacks.spawned = bot:AddCallback(ON_SPAWN, function()
		removeCallbacks(bot, callbacks)
	end)
end

local function Handle3(bot)
	local callbacks = {}

	storeRollback()

	chatMessage("You know what. I believe we need to have an equalizer")

	timer.Simple(1.5, function ()
		chatMessage("I'm taking away your money")

		for _, player in pairs(ents.GetAllPlayers()) do
			player:SetCurrency(-1000)
		end
	end)
	timer.Simple(3, function ()
		chatMessage("I'm taking away your canteens")
		for _, player in pairs(ents.GetAllPlayers()) do
			if not player:IsRealPlayer() then
				goto continue
			end

			local canteen = player:GetPlayerItemBySlot(LOADOUT_POSITION_ACTION)

			if not canteen then
				goto continue
			end

			canteen.m_usNumCharges = 0

			::continue::
		end
	end)
	timer.Simple(5, function ()
		chatMessage("Now I'm taking away your life. Go to hell")

		local britian = Vector(289.492859, 7267.859375, -10179.536133)

		fade()
		timer.Simple(1, function ()
			for _, player in pairs(ents.GetAllPlayers()) do
				if not player:IsRealPlayer() then
					goto continue
				end

				player:ForceRespawn()
				player:Teleport(britian)

				::continue::
			end

		end)
	end)

	timer.Simple(7.5, function ()
		chatMessage("Just so you know, I'm sending super scouts your way. Better finish that parkour section quick aye?")
	end)

	callbacks.died = bot:AddCallback(ON_DEATH, function()
		-- horrible hardcoded way to kill any remaining super scouts because I'm too lazy to implement something proper
		-- for _, player in pairs(ents.GetAllPlayers()) do
		-- 	if player.m_iTeamNum ~= 3 then
		-- 		goto continue
		-- 	end

		-- 	if not player:IsAlive() then
		-- 		goto continue
		-- 	end

		-- 	if player:GetPlayerName() ~= "Super Scout" then
		-- 		goto continue
		-- 	end

		-- 	player:Suicide()

		-- 	::continue::
		-- end

		specialLinePlaying = true

		timer.Simple(0.5, function ()
			chatMessage("This is getting tiresome")
		end)

		timer.Simple(1.7, function ()
			chatMessage("I have an idea")
		end)

		timer.Simple(3.5, function ()
			specialLinePlaying = false
			revertRollback()
		end)

		removeCallbacks(bot, callbacks)
	end)
	callbacks.spawned = bot:AddCallback(ON_SPAWN, function()
		removeCallbacks(bot, callbacks)
	end)
end

local function endWave()
	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() then
			-- player:ForceRespawn()
			player.m_bUseBossHealthBar = false
			player.m_bIsMiniBoss = false
			player.m_bGlowEnabled = 0

			goto continue
		end

		if player.m_iTeamNum ~= 3 then
			goto continue
		end

		if not player:IsAlive() then
			goto continue
		end

		player:Suicide()

		::continue::
	end
end

local function PvPBluWin()
	if gamestateEnded then
		return
	end

	gamestateEnded = true
	pvpActive = false

	specialLinePlaying = true

	timer.Simple(1, function ()
		chatMessage("Masterfully done my dear friend")
	end)

	timer.Simple(2, function ()
		chatMessage("Let us enjoy this victory together")
	end)
	timer.Simple(3, function ()
		chatMessage("I hope your buddies aren't too mad at you after that")
	end)

	endWave()
end
local function PvPRedWin()
	if gamestateEnded then
		return
	end

	gamestateEnded = true
	pvpActive = false

	specialLinePlaying = true

	timer.Simple(1, function ()
		chatMessage("How embarrassing")
	end)

	endWave()
end

local function checkPvPWinCond(dontSayCount)
	local redPlayersAlive = 0

	for _, player in pairs(ents.GetAllPlayers()) do
		if not player:IsRealPlayer() then
			goto continue
		end

		if player.m_iTeamNum ~= 2 then
			goto continue
		end

		if not player:IsAlive() then
			goto continue
		end

		redPlayersAlive = redPlayersAlive + 1

		::continue::
	end

	print(redPlayersAlive)

	if not dontSayCount and redPlayersAlive > 0 then
		local msg = redPlayersAlive > 1 and "%s players left" or "%s player remains!"
		chatMessage(string.format(msg, tostring(redPlayersAlive)))
	end

	if redPlayersAlive <= 0 then
		PvPBluWin()
	end
end

local function handlePvPLateJoin(player)
	-- player:ForceRespawn()
	player:SetAttributeValue("min respawn time", 999999)
	-- player:Suicide()

	chatMessage("A new challenger enters the field? Very well, I'll allow it")

	local plrCallbacks = {}
	-- just incase
	plrCallbacks.spawned = player:AddCallback(ON_SPAWN , function ()
		player:SetAttributeValue("min respawn time", 999999)
		checkPvPWinCond()
	end)
	plrCallbacks.died = player:AddCallback(ON_DEATH, function ()
		checkPvPWinCond()
		removeCallbacks(player, plrCallbacks)
	end)
end

local function handlePlayerPvPDeath(player)
	local plrCallbacks = {}
	plrCallbacks.died = player:AddCallback(ON_DEATH, function ()
		checkPvPWinCond()
		removeCallbacks(player, plrCallbacks)
	end)
end

function OnPlayerConnected(player)
	if not timeconstraint_alive then
		return
	end

	if pvpActive then
		handlePvPLateJoin(player)
		checkPvPWinCond(true)
		-- handlePlayerPvPDeath(player)
	end

	handlePlayerDeath(player)
end

function OnPlayerDisconnected(player)
	if not timeconstraint_alive then
		return
	end

	if player.m_iTeamNum == 3 then
		PvPRedWin()
		return
	end

	checkPvPWinCond()
end

local function HandleFinal(bot)
	local callbacks = {}

	storeRollback()

	specialLinePlaying = true

	chatMessage("Seeing as I myself am entirely unable to best you all")

	timer.Simple(1.5, function ()
		chatMessage("I have decided that, in order to create a fair matchup")
	end)
	timer.Simple(4, function ()
		chatMessage("You will be pitted against your best player")
	end)

	local chosenPlayer
	timer.Simple(6.5, function ()
		local text = "And that means you, %s"
		local bestPlayer = {nil, -100000}

		for _, player in pairs(ents.GetAllPlayers()) do
			if not player:IsRealPlayer() then
				goto continue
			end

			if player.m_iTeamNum ~= 2 then
				goto continue
			end

			local dmg = player.m_iDamageDone

			if dmg >= bestPlayer[2] then
				bestPlayer = {player, dmg}
			end

			::continue::
		end

		chosenPlayer = bestPlayer[1]

		chatMessage(string.format(text, chosenPlayer:GetPlayerName()))
	end)
	timer.Simple(8, function ()
		chatMessage("Step right on up fella, you're on my side now")

		-- cur_constraint.m_bUseBossHealthBar = false
		---@diagnostic disable-next-line: need-check-nil
		cur_constraint:SetAttributeValue("is suicide counter", 1)

		local spawn = ents.FindByName("timeconstraint_fast")
		local spawnPos = spawn:GetAbsOrigin() + Vector(0, 0, 10)

		chosenPlayer:ForceRespawn()

		chosenPlayer:Teleport(spawnPos)
		chosenPlayer:AddCond(TF_COND_REPROGRAMMED)

		-- no resistance
		chosenPlayer:SetAttributeValue("dmg taken from fire reduced", nil)
		chosenPlayer:SetAttributeValue("dmg taken from blast reduced", nil)
		chosenPlayer:SetAttributeValue("dmg taken from bullets reduced", nil)
		chosenPlayer:SetAttributeValue("dmg taken from crit reduced", nil)
		chosenPlayer:SetAttributeValue("health regen", nil)

		chosenPlayer:SetAttributeValue("max health additive bonus", 8000)
		chosenPlayer:SetAttributeValue("cannot pick up intelligence", 1)

		chosenPlayer.m_bUseBossHealthBar = true
		chosenPlayer.m_bIsMiniBoss = true

		local chosenPlrCallbacks = {}
		chosenPlrCallbacks.died = chosenPlayer:AddCallback(ON_DEATH, function ()
			PvPRedWin()

			removeCallbacks(chosenPlayer, chosenPlrCallbacks)
		end)
		-- chosenPlrCallbacks.removed = chosenPlayer:AddCallback(ON_REMOVE, function ()
		-- 	PvPRedWin()
		-- end)
	end)
	timer.Simple(10, function ()
		chatMessage("Now give me a show")

		specialLinePlaying = false

		for _, player in pairs(ents.GetAllPlayers()) do
			if not player:IsRealPlayer() then
				goto continue
			end

			player.m_bGlowEnabled = 1
			player:ForceRespawnDead()
			player:SetAttributeValue("min respawn time", 999999)

			local text = player ~= chosenPlayer and
				"ELIMINATE BLU PLAYER BEFORE TIME RUNS OUT" or
				"ELIMINATE ALL RED PLAYERS TO WIN"

			player:Print(PRINT_TARGET_CENTER, text)

			if player == chosenPlayer then
				goto continue
			end

			-- local plrCallbacks = {}
			-- plrCallbacks.died = player:AddCallback(ON_DEATH, function ()
			-- 	checkPvPWinCond()
			-- 	removeCallbacks(player, plrCallbacks)
			-- end)

			handlePlayerPvPDeath(player)

			-- plrCallbacks.removed = player:AddCallback(ON_REMOVE, function ()
			-- 	checkPvPWinCond()
			-- end)

			::continue::
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
		-- timeout
		PvPBluWin()
		removeCallbacks(bot, callbacks)
	end)
	callbacks.spawned = bot:AddCallback(ON_SPAWN, function()
		removeCallbacks(bot, callbacks)
	end)
end

local function checkBot(bot, tags)
	if hasTag(tags, "realcontraint") then
		Holder(bot)
		return false, false
	end
	if hasTag(tags, "timeconstraint1") then
		Handle1(bot)
		return true, true
	end
	if hasTag(tags, "timeconstraint2") then
		Handle2(bot)
		return true, true
	end
	if hasTag(tags, "timeconstraint3") then
		Handle3(bot)
		return true, true
	end
	if hasTag(tags, "timeconstraintFinal") then
		HandleFinal(bot)
		return true, true
	elseif hasTag(tags, "subwave3Bot") then
		HandleSubwave3Bot(bot)
		return true
	end
end

function SlayTimeConstraintDebug()
	if cur_constraint then
		cur_constraint:Suicide()
	end
end

function OnWaveSpawnBot(bot, _, tags)
	local _result, isTimeConstrant = checkBot(bot, tags)

	if isTimeConstrant then
		cur_constraint = bot
	end
end