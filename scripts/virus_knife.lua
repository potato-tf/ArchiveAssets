--Heavily modified version of build_ally_bot_old.lua by royal
local BOTS_ATTRIBUTES = {
	-- ["not solid to players"] = 1, -- prevents bot from taking teleporter
	["collect currency on kill"] = 1,
	["ammo regen"] = 10,
	["fire input on kill"] = "popscript^$virusKnifeKill^",
	["weapon always gib"] = 1,
	["health regen"] = 5,
	["health from packs increased"] = 5,
	["armor piercing"] = 45,
	["move speed bonus"] = 1.5,
	["model scale"] = 0.75,
	["voice pitch scale"] = 1.50,
	["ignored by enemy sentries"] = 1,
	["not solid to players"] = 1,
	["max health additive bonus"] = -55,
	["special item description"] = "IamASpy",
}
local BOTS_ATTRIBUTES_GIGA = {
	-- ["not solid to players"] = 1, -- prevents bot from taking teleporter
	["collect currency on kill"] = 1,
	["ammo regen"] = 10,
	["fire input on kill"] = "popscript^$virusKnifeKill^",
	["weapon always gib"] = 1,
	["health regen"] = 25,
	["health from packs increased"] = 20,
	["armor piercing"] = 80,
	["move speed bonus"] = 4.0,
	["voice pitch scale"] = 1,
	["add cloak on kill"] = 20,
	["ignored by enemy sentries"] = 1,
	["max health additive bonus"] = 175,
	["special item description"] = "IamASpy",
}
local BOTS_ATTRIBUTES_CLONE_BASE = {
	-- ["not solid to players"] = 1, -- prevents bot from taking teleporter
	["collect currency on kill"] = 1,
	["ammo regen"] = 10,
	["ignored by enemy sentries"] = 1,
	["cannot taunt"] = 1,
}
local BOTS_ATTRIBUTES_DECOY = {
	-- ["not solid to players"] = 1, -- prevents bot from taking teleporter
	["health regen"] = 1000,
	["move speed bonus"] = 0,
	["dmg taken increased"] = 0,
	["damage force reduction"] = 0,
	["airblast vulnerability multiplier"] = 0,
	["always gib"] = 1,
	["damage bonus"] = 0,
	["cannot be backstabbed"] = 1,
	["cannot taunt"] = 1,
	["use robot voice"] = 1,
	["always allow taunt"] = 1,
	["ignored by enemy sentries"] = 1,
}

-- we can't expect lua to do all the work - joshua graham
-- local BOT_SETUP_VSCRIPT = "activator.SetDifficulty(3); activator.SetMaxVisionRangeOverride(0.1)"
-- 16 -- disable dodge
local BOT_SETUP_VSCRIPT =
	"activator.SetDifficulty(0); activator.SetMaxVisionRangeOverride(100000); activator.AddBotAttribute(16)"
local BOT_CLEAR_RESTRICTIONS_VSCRIPT = "activator.ClearAllWeaponRestrictions()"

local activeBots = {} -- bots alive

local activeBuiltBots = {} -- bot built by player
local activeBuiltBotsOwner = {}

local lingeringBuiltBots = {}

local inWave = false

local PACK_ITEMS = {
	"item_currencypack_small",
	"item_currencypack_medium",
	"item_currencypack_large",
	"item_currencypack_custom",
}

local numActiveBots = 0

local botCheckCounter = 0

function OnWaveInit()
	inWave = false

	for _, bot in pairs(activeBuiltBots) do
		bot:Suicide()
		bot.m_iTeamNum = 1
	end
	
	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() == false and player.m_iTeamNum == 2 and player:IsAlive() == true then
			player:Suicide()
			player.m_iTeamNum = 1		
		end
	end	
	
	timer.Simple(0.1, function()
		numActiveBots = 0
	end)

	activeBuiltBots = {}
end

function OnWaveStart()
	inWave = true
end

local function checkOnHit(parent, damageinfo)
	local attacker = damageinfo.Attacker

	if not attacker then
		return
	end

	local handle = attacker:GetHandleIndex()

	local owner = activeBuiltBotsOwner[handle]

	if not owner then
		return
	end

	if parent == owner then
		return
	end

	damageinfo.Attacker = owner

	return true
end

ents.AddCreateCallback("tank_boss", function(tank)
	tank:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageinfo)
		return checkOnHit(tank, damageinfo)
	end)
end)

-- convert damage dealt by bots to owner
-- and nullify damage taken by built bot during prewave
local function addGlobalCallbacks(player)
	player:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageinfo)
		local isBot = activeBots[player:GetHandleIndex()]
		if isBot and not inWave then
			-- nullify attacks in prewave
			damageinfo.Damage = 0
			damageinfo.Inflictor = nil
			damageinfo.Weapon = nil
			return true
		end

		return checkOnHit(player, damageinfo)
	end)

	-- failsafe for spawning bot in setup
	player:AddCallback(ON_SPAWN, function()
		if player:IsRealPlayer() then
			return
		end

		timer.Simple(0.1, function()
			if inWave then
				return
			end

			local owner = activeBuiltBots[player:GetHandleIndex()]

			if not owner then
				return
			end

			if player.m_iTeamNum == owner.m_iTeamNum then
				player:Suicide()
			end
		end)
	end)
end

function OnPlayerConnected(player)
	addGlobalCallbacks(player)
end

local function removeCallbacks(player, callbacks)
	if not IsValid(player) then
		return
	end

	for _, callbackId in pairs(callbacks) do
		player:RemoveCallback(callbackId)
	end
end

local function applyName(bot, name, owner)
	local displayName = name .. " (" .. owner.m_szNetname .. ")"
	bot.m_szNetname = displayName

	bot:SetFakeClientConVar("name", displayName)
end


local function setupBot(bot, owner, handle, isDecoy)
	local callbacks = {}

	local botHandle = bot:GetHandleIndex()

	bot.m_iTeamNum = owner.m_iTeamNum

	bot.m_iszClassIcon = "" -- don't remove from wave on death

	if isDecoy == 1 then
		applyName(bot, "Spy", owner)
		for name, value in pairs(BOTS_ATTRIBUTES) do
			bot:SetAttributeValue(name, value)
		end
		elseif isDecoy == 2 then
		applyName(bot, "Spy", owner)
		for name, value in pairs(BOTS_ATTRIBUTES_GIGA) do
			bot:SetAttributeValue(name, value)
		end
		elseif isDecoy == 3 then
		applyName(bot, "Clone", owner)
		for name, value in pairs(BOTS_ATTRIBUTES_CLONE_BASE) do
			bot:SetAttributeValue(name, value)
		end
		else
		applyName(bot, "Decoy", owner)
		for name, value in pairs(BOTS_ATTRIBUTES_DECOY) do
			bot:SetAttributeValue(name, value)
		end		
	end

	owner.BuiltBotHandle = tostring(botHandle)

	activeBots[botHandle] = true
	activeBuiltBots[handle] = bot
	lingeringBuiltBots[botHandle] = true
	activeBuiltBotsOwner[botHandle] = owner

	callbacks.died = bot:AddCallback(ON_DEATH, function()
		-- attributes applied to bot spawned through script are not cleared automatically on death
		for name, _ in pairs(bot:GetAllAttributeValues()) do
			bot:SetAttributeValue(name, nil)
		end

		owner.BuiltBotHandle = false

		activeBots[botHandle] = nil
		activeBuiltBots[handle] = nil
		activeBuiltBotsOwner[botHandle] = nil

		bot:ResetFakeSendProp("m_iTeamNum")
		bot.m_iTeamNum = 1

		removeCallbacks(bot, callbacks)
	end)

	return callbacks
end

local function findFreeBot()
	local chosen

	for _, bot in pairs(ents.GetAllPlayers()) do
		if
			not bot:IsRealPlayer()
			and not bot:IsAlive()
			and (bot.m_iTeamNum == 1 or bot.m_iTeamNum == 0)
			and bot:GetPlayerName() ~= "Demo-Bot"
		then
			chosen = bot
			break
		end
	end

	return chosen
end

function virusKnifeKill(damage, activator, caller)
	
	
	local owner = activator
	local handle = owner:GetHandleIndex()

	local origin = caller:GetAbsOrigin()
	--print(origin)
	
	--local ownerSapper = owner:GetPlayerItemBySlot(4)
	
	--print(CurTime())
	
	--print(ownerSapper.m_flEffectBarRegenTime)
	
	--sapper has a 15 second cooldown, 30% of 15 is 2
	--ownerSapper.m_flEffectBarRegenTime = ownerSapper.m_flEffectBarRegenTime - 2

	--print(ownerSapper.m_flEffectBarRegenTime)
	
	local botSpawn = findFreeBot()

	if not botSpawn or numActiveBots >= 10 then
		owner:Print(PRINT_TARGET_CENTER, "GLOBAL BOT LIMIT REACHED")
		return
	end
	
	numActiveBots = numActiveBots + 1
	botCheckCounter = botCheckCounter + 1
	print(botCheckCounter)
	print(numActiveBots)
	
	if botCheckCounter >= 9 then
		botCheckCounter = 0
		print("Scanning for leaking spies")
		for _, player in pairs(ents.GetAllPlayers()) do
			if player:IsRealPlayer() == false and player.m_iTeamNum == 2 and player:IsAlive() == true and player:GetAttributeValue("special item description", false) == "IamNOTaSpy" and player.m_iClass == 8 then
				print("Found an invalid spy DIE")
				botSpawn:Suicide()
				botSpawn.m_iTeamNum = 1		
			end
		end			
	end
	
	local gigaSpyValue = 1
	
	if caller.m_bIsMiniBoss == 1 then
		gigaSpyValue = 2
	end

	local callbacks = setupBot(botSpawn, owner, handle, gigaSpyValue)

	timer.Simple(0, function()
		botSpawn:SetAbsOrigin(origin)
		botSpawn:SwitchClassInPlace("Spy")
		--25
		botSpawn:AddCond(51, 1, activator)
		botSpawn:AddCond(32, 10, activator)
		botSpawn:SetCustomModelWithClassAnimations("models/bots/spy/bot_spy.mdl")

		botSpawn:RunScriptCode(BOT_SETUP_VSCRIPT, botSpawn, botSpawn)

		-- botSpawn:RunScriptCode((BOT_SET_WEPRESTRICTION_VSCRIPT):format("0"), botSpawn, botSpawn)
		botSpawn:RunScriptCode(BOT_CLEAR_RESTRICTIONS_VSCRIPT, botSpawn, botSpawn)
			
		local teleParticle = ents.CreateWithKeys("info_particle_system", {
			effect_name = "teleportedin_red",
			start_active = 1,
			flag_as_weather = 0,
		}, true, true)	
		teleParticle:SetAbsOrigin(botSpawn:GetAbsOrigin())
		teleParticle:Start()
			
		timer.Simple(1, function ()
			teleParticle:Remove()
		end)

		local spawnedCallback
		spawnedCallback = botSpawn:AddCallback(ON_SPAWN, function()

			botSpawn:ResetFakeSendProp("m_iTeamNum")

			lingeringBuiltBots[handle] = nil
					
			botSpawn:RemoveCallback(spawnedCallback)
			spawnedCallback = nil
		end)


	end)
	
	--14
		local logicLoop
		local spyTerminated = false
		
		--checks every half second rather than every tick because this isn't code that needs to be updated constantly
	
		logicLoop = timer.Create(0.5, function()
			--print(timeLeft)
			--print(timeLeft)
			--name check is performed in case the spy was killed and respawned between the half second of the check
			if (botSpawn:IsAlive() == false or botSpawn.m_szNetname ~= "Spy (" .. owner.m_szNetname .. ")") and spyTerminated == false then
				timer.Stop(logicLoop)
				numActiveBots = numActiveBots - 1
				spyTerminated = true
				botSpawn.m_iTeamNum = 1
				print(numActiveBots)				
				print("we're done, we either died or aren't a spy")
				return
			end
			
			if owner:IsValid() == false and spyTerminated == false then
				timer.Stop(logicLoop)
				print("we're done, our owner isn't valid")
				botSpawn:Suicide()
				numActiveBots = numActiveBots - 1
				spyTerminated = true
				botSpawn.m_iTeamNum = 1
				print(numActiveBots)
				return
			end
		end, 27)
		
		--These motherfuckers keep living forever, this is the ultimate solution to that issue
		--No ambiguity with iteration times, no constant checks, no clause they can slip through
		--They. Will. FUCKING. DIE.
		timer.Simple(14, function()
			botSpawn:SetAttributeValue("special item description", "IamNOTaSpy")
			if botSpawn:IsAlive() == true and botSpawn.m_szNetname == "Spy (" .. owner.m_szNetname .. ")" and spyTerminated == false then
				botSpawn:Suicide()
				numActiveBots = numActiveBots - 1
				botSpawn.m_iTeamNum = 1
				botSpawn:SetAttributeValue("special item description", nil)
				print(numActiveBots)	
			end
			if numActiveBots < 0 then
				numActiveBots = 0
			end			
		end)
			
end

function cloneSpawn(activator)
	
	

	local owner = activator
	local handle = owner:GetHandleIndex()

	local origin = activator:GetAbsOrigin()
	
	local botSpawn = findFreeBot()

	if not botSpawn then
		owner:Print(PRINT_TARGET_CENTER, "GLOBAL BOT LIMIT REACHED")
		return
	end

	local callbacks = setupBot(botSpawn, owner, handle, 3)

	timer.Simple(0, function()
		botSpawn:SetAbsOrigin(origin)
		botSpawn:SwitchClassInPlace("Soldier")
		--25
		botSpawn:AddCond(51, 2, activator)
		
		local ownerPrimary = owner:GetPlayerItemBySlot(0)
		local ownerSecondary = owner:GetPlayerItemBySlot(1)
		local ownerMelee = owner:GetPlayerItemBySlot(2)
		
		print(ownerPrimary)
		print(ownerSecondary)
		print(ownerMelee)
		
			if ownerPrimary then
			print(botSpawn:GiveItem(ownerPrimary:GetItemName(), ownerPrimary:GetAllAttributeValues(true), false, true))
			end
			
			if ownerSecondary then
			print(botSpawn:GiveItem(ownerSecondary:GetItemName(), ownerSecondary:GetAllAttributeValues(true), false, true))
			end
			
			if ownerMelee then
			print(botSpawn:GiveItem(ownerMelee:GetItemName(), ownerMelee:GetAllAttributeValues(true), false, true))
			end		
			
			local ownerBodyUpgrades = owner:GetAllAttributeValues()
			for name, value in pairs(ownerBodyUpgrades) do
				botSpawn:SetAttributeValue(name, value)
			end
			
		botSpawn:SetCustomModelWithClassAnimations("models/bots/soldier/bot_soldier.mdl")

		botSpawn:RunScriptCode(BOT_SETUP_VSCRIPT, botSpawn, botSpawn)

		-- botSpawn:RunScriptCode((BOT_SET_WEPRESTRICTION_VSCRIPT):format("0"), botSpawn, botSpawn)
		botSpawn:RunScriptCode(BOT_CLEAR_RESTRICTIONS_VSCRIPT, botSpawn, botSpawn)
			
		local teleParticle = ents.CreateWithKeys("info_particle_system", {
			effect_name = "teleportedin_red",
			start_active = 1,
			flag_as_weather = 0,
		}, true, true)	
		teleParticle:SetAbsOrigin(botSpawn:GetAbsOrigin())
		teleParticle:Start()
			
		timer.Simple(1, function ()
			teleParticle:Remove()
		end)

		local spawnedCallback
		spawnedCallback = botSpawn:AddCallback(ON_SPAWN, function()

			botSpawn:ResetFakeSendProp("m_iTeamNum")

			lingeringBuiltBots[handle] = nil
					
			botSpawn:RemoveCallback(spawnedCallback)
			spawnedCallback = nil
		end)


	end)
	
		local logicLoop
	
		logicLoop = timer.Create(0.2, function()

			if botSpawn:IsAlive() == false or botSpawn.m_szNetname ~= "Clone (" .. owner.m_szNetname .. ")" or owner:IsValid() == false then
				timer.Stop(logicLoop)
				--print("we're done, we either died or aren't a clone anymore")
				owner.m_flHypeMeter = owner.m_flHypeMeter - 1
				if owner.m_flHypeMeter < 0 then
					owner.m_flHypeMeter = 0
				end
				return
			end
			
			if inWave == false then
				timer.Stop(logicLoop)
				--print("we're done, we either ran out of time or the wave ended")
				botSpawn:Suicide()	
				return
			end
			
			if owner:InCond(TF_COND_TAUNTING) then
				botSpawn:SetAttributeValue("cannot taunt", nil)
				botSpawn["$Taunt"](botSpawn)
				botSpawn:SetAttributeValue("cannot taunt", 1)
			end

			local pos = owner:GetAbsOrigin()
			local distance = pos:Distance(botSpawn:GetAbsOrigin())

			if distance >= 400 then
				botSpawn:AddCond(TF_COND_SPEED_BOOST, 1)
			end		

			local stringStart = "interrupt_action -switch_action Default"					

			-- don't move if already close, or if you are told to not move
			if distance <= 150 then
				botSpawn:BotCommand(stringStart .. " -duration 0.1")		
				return
			end

			local interruptAction = ("%s -pos %s %s %s -duration 0.1"):format(stringStart, pos[1], pos[2], pos[3])

			botSpawn:BotCommand(interruptAction)
			
			
		end, 0)	
			
end

function decoyWatchActivate(condition, activator)
	

	local owner = activator
	print(owner.m_flCloakMeter)
	
	if owner.m_flCloakMeter < 100 then
		owner:PlaySoundToSelf("Player.DenyWeaponSelection")
		owner:RemoveCond(4)
		return
	end	
	
	local handle = owner:GetHandleIndex()

	local origin = activator:GetAbsOrigin()
	
	local botSpawn = findFreeBot()

	if not botSpawn then
		owner:Print(PRINT_TARGET_CENTER, "GLOBAL BOT LIMIT REACHED, CLOAK REFUNDED")
		owner:PlaySoundToSelf("Player.DenyWeaponSelection")
		owner.m_flCloakMeter = 100
		owner:RemoveCond(4)
		return
	end
	
	if not inWave then
		owner:Print(PRINT_TARGET_CENTER, "WAIT UNTIL THE WAVE STARTS TO SPAWN DECOYS, CLOAK REFUNDED")
		owner:PlaySoundToSelf("Player.DenyWeaponSelection")
		owner.m_flCloakMeter = 100
		owner:RemoveCond(4)
		return
	end	

	local callbacks = setupBot(botSpawn, owner, handle, true)
	owner.m_flCloakMeter = 0

	timer.Simple(0, function()
		botSpawn:SetAbsOrigin(origin)
		botSpawn:SwitchClassInPlace("Sniper")
		botSpawn:SetCustomModelWithClassAnimations("models/bots/sniper/bot_sniper.mdl")

		botSpawn:RunScriptCode(BOT_SETUP_VSCRIPT, botSpawn, botSpawn)

		-- botSpawn:RunScriptCode((BOT_SET_WEPRESTRICTION_VSCRIPT):format("0"), botSpawn, botSpawn)
		botSpawn:RunScriptCode(BOT_CLEAR_RESTRICTIONS_VSCRIPT, botSpawn, botSpawn)
			
		local teleParticle = ents.CreateWithKeys("info_particle_system", {
			effect_name = "teleportedin_red",
			start_active = 1,
			flag_as_weather = 0,
		}, true, true)	
		teleParticle:SetAbsOrigin(botSpawn:GetAbsOrigin())
		botSpawn:AddCond(4, 0.25, botSpawn)
		teleParticle:Start()
			
		timer.Simple(1, function ()
			teleParticle:Remove()
		end)

		local spawnedCallback
		spawnedCallback = botSpawn:AddCallback(ON_SPAWN, function()

			botSpawn:ResetFakeSendProp("m_iTeamNum")

			lingeringBuiltBots[handle] = nil
					
			botSpawn:RemoveCallback(spawnedCallback)
			spawnedCallback = nil
		end)


	end)
	
	timer.Simple(10, function()
			botSpawn:SetAttributeValue("cannot taunt", 0)
			botSpawn["$Taunt"](botSpawn)
			timer.Simple(1, function()
				botSpawn:AddCond(4, 1, botSpawn)
				botSpawn:AddCond(66, 99, botSpawn)	
			end)			
			timer.Simple(2, function()
				botSpawn:Suicide()	
			end)
	end)		
end


