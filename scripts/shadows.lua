-- the stuff below is made by Royal
-- they deserve a LOT of kudos for everything here

local deathCounts = {}
local waveActive = false

function OnPlayerDisconnected(player)
	deathCounts[player:GetHandleIndex()] = nil
end

function OnWaveInit()
	waveActive = false
	DoublePointsText = ""
	FireSaleText = ""
	InstakillText = ""
	DoublePointsDuration = 0
	FireSaleDuration = 0
	InstakillDuration = 0
	DumpsterCost = 950
end

function OnWaveStart()
	waveActive = true
end

function rejuvenatorHit(damage, activator, caller)
	local damageThreshold = 1

	if damage < damageThreshold then
		return
	end

	caller:AddCond(43, 5, activator)

	timer.Simple(5, function()
		caller:Suicide()
	end)
end

function chargerLogic(_, activator)
	local callbacks = {}

	local function removeCallbacks() 
		for _, callbackData in pairs(callbacks) do
			activator:RemoveCallback(callbackData.Type, callbackData.ID)
		end
	end

	callbacks.keypress = { -- Apply animation when bot pushes M2
		Type = 7,
		ID = activator:AddCallback(7, function(_, key)
			if key ~= IN_ATTACK2 then
				return
			end
			
			if activator.m_flChargeMeter < 100 then
                return
            end

			activator:PlaySequence("Charger_Charge") 
		end),
	}

	callbacks.spawned = {
		Type = 1,
		ID = activator:AddCallback(1, function()
			removeCallbacks()
		end),
	}

	callbacks.died = {
		Type = 9,
		ID = activator:AddCallback(9, function()
			removeCallbacks()
		end),
	}
end

local function cashforhits(activator)
	local callbacks = {}

	local function removeCallbacks()
		for _, callbackId in pairs(callbacks) do
			activator:RemoveCallback(callbackId)
		end
	end

	
	callbacks.damagetype = activator:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageInfo)
		-- PrintTable(damageInfo)
		local mult = (DoublePointsDuration > 0) and 2 or 1

		local damage = damageInfo.Damage
		if damage <= 0 then
			return
		end

		local damageType = damageInfo.DamageType
		local hitter = damageInfo.Attacker

		if (damageType & DMG_BURN) ~= 0 then
			return
		end

		local isCrit = (damageType & DMG_CRITICAL) ~= 0

		if isCrit then
			damage = damage * 3
		end

		local curHealth = activator.m_iHealth

		if InstakillDuration > 0 and activator.m_szNetname == "Zombie" and hitter:InCond(56) == 1 then --instakill functionality -washy
			damage = curHealth
			activator.m_iHealth = 0
		end

		--local isLethal = curHealth - (damage + 1) <= 0

		local function addCurrency(amount)
			hitter:AddCurrency(amount * mult)
		end

--[[ 		if not isLethal then ]]
			addCurrency(10)
--[[ 			return
		end

		if IsLethal then
			addCurrency(75)
			return
		end

		if (damageType & DMG_BLAST) ~= 0 then
            addCurrency(75) -- used to be 50
        --    print("explosive?")
		elseif (damageType & DMG_MELEE) ~= 0 then
			addCurrency(150)
		--    print("melee?")
        elseif (damageType & DMG_MELEE) == 0 and (damageType & DMG_CRITICAL) ~= 0 then -- this is used for headshots, may overlap with Instakill
            addCurrency(100)
        --    print("crit?")
        elseif (damageType & DMG_BULLET) ~= 0 then
            addCurrency(75)
        --    print("bullet?")
		elseif (damageType & DMG_USE_HITLOCATIONS) ~= 0 then
            addCurrency(75)
        --    print("fancier bullet?")
        else
            addCurrency(75)
        --    print("hell if I know")
        end ]]
	end)

	callbacks.killed = activator:AddCallback(ON_DEATH, function(_, damageInfo)
		-- PrintTable(damageInfo)
		local mult = (DoublePointsDuration > 0) and 2 or 1

		local damage = damageInfo.Damage
		if damage <= 0 then
			return
		end

		local damageType = damageInfo.DamageType
		local hitter = damageInfo.Attacker

		if (damageType & DMG_BURN) ~= 0 then
			return
		end

		local isCrit = (damageType & DMG_CRITICAL) ~= 0

		if isCrit then
			damage = damage * 3
		end

		local curHealth = activator.m_iHealth

		if InstakillDuration > 0 and activator.m_szNetname == "Zombie" and hitter:InCond(56) == 1 then --instakill functionality -washy
			damage = curHealth
			activator.m_iHealth = 0
		end

		local function addCurrency(amount)
			hitter:AddCurrency(amount * mult)
		end

		if (damageType & DMG_BLAST) ~= 0 then
            addCurrency(65) -- used to be 50
        --    print("explosive?")
		elseif (damageType & DMG_MELEE) ~= 0 then
			addCurrency(140)
		--    print("melee?")
        elseif (damageType & DMG_MELEE) == 0 and (damageType & DMG_CRITICAL) ~= 0 then -- this is used for headshots, may overlap with Instakill
            addCurrency(90)
        --    print("crit?")
        elseif (damageType & DMG_BULLET) ~= 0 then
            addCurrency(65)
        --    print("bullet?")
		elseif (damageType & DMG_USE_HITLOCATIONS) ~= 0 then
            addCurrency(65)
        --    print("fancier bullet?")
        else
            addCurrency(65)
        --    print("hell if I know")
        end
	end)

	callbacks.spawned = activator:AddCallback(1, function()
		removeCallbacks()
	end)

	callbacks.died = activator:AddCallback(9, function()
		removeCallbacks()
	end)
end

function OnWaveSpawnBot(bot)
	timer.Simple(1, function()
		cashforhits(bot)
	end)
end

function playertracker(_, activator) -- the only thing here made by Sntr
	local callbacks = {}
	
	local function removeCallbacks()
		for _, callbackId in pairs(callbacks) do
			activator:RemoveCallback(callbackId)
		end
	end
	
	local function DeathCounter()
		if not waveActive then
			return
		end

		local deathcount = 	deathCounts[activator:GetHandleIndex()]
	
		if deathcount >= 3 and deathcount < 4
		then
			util.PrintToChat(activator,"You have received a $750 comeback bonus.")
			activator:AddCurrency(750)
		end
		if deathcount >= 5 and deathcount < 6
		then
			util.PrintToChat(activator,"You have received a $1500 comeback bonus.")
			activator:AddCurrency(1500)
		end
		if deathcount > 7 and deathcount < 8
		then
			util.PrintToChat(activator,"You have received a $3000 comeback bonus.")
			activator:AddCurrency(3000)
		end
	end
	
	callbacks.damagetype = activator:AddCallback(ON_DAMAGE_RECEIVED_PRE, function(_, damageInfo)
		if activator:InCond(5) == 1 then
			return
		end

		-- disallow friendly fire, allow self damage
		if damageInfo.Attacker:GetHandleIndex() ~= activator:GetHandleIndex() then
			if damageInfo.Attacker.m_iTeamNum == activator.m_iTeamNum then
				return
			end
		end

		local damage = damageInfo.Damage
		local curHealth = activator.m_iHealth
				
		if damage > curHealth and activator:InCond(129) == 1 then --  give full heal + uber when condition 70 is removed
			activator:AddCond(5,2.5)
			activator:AddHealth(300,1)
			activator:PlaySoundToSelf("misc/halloween/merasmus_stun.wav")
			activator:RemoveCond(129)
			activator:RemoveCond(70) -- so people can't be undying forever
			activator.vm_quickrev = false -- added this for compatibility -washy
		end
	end)
	
--	callbacks.output = activator:AddCallback(ON_INPUT, function(_, medicbonus_relay)
--
--		local playerclass = activator.m_iClass
--		local playercount = math_counter.m_OutValue
--	
--		if playerclass == 5
--		then
--			activator:AddCurrency( playercount * 75 )
--		end
--	end)
		
	callbacks.spawned = activator:AddCallback(1, function()
		removeCallbacks()
	end)

	callbacks.died = activator:AddCallback(9, function()
		removeCallbacks()
		DeathCounter()
	end)
	
end

-- and here's the stuff made by Washy
-- likewise, plenty of kudos

function OnWaveReset()
	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() then
			for weapon = 0, 3, 1 do
				player.loadout[weapon] = "Default"
			end
		end
	end
	if TextDisplay ~= nil then
		timer.Stop(TextDisplay)
		TextDisplay = nil
	end
end

function OnGameTick()
	local currencyCollected = ents.FindByClass("tf_player_manager").m_iCurrencyCollected
	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() then
			if player.m_bUsingActionSlot == 1 and player.InteractCooldown ~= true then
				player.HoldTime = player.HoldTime + 1
				if player.HoldTime > 13 and player.InteractWith ~= "nothing" then
					Interact(player)
					player.InteractCooldown = true
					player.HoldTime = 0
					timer.Simple(1, function() player.InteractCooldown = false end)
				end
			else
				player.holdTime = 0
			end
			player:GetUserId()
			currencyCollected[player:GetNetIndex()+1] = player.m_nCurrency
			if player.m_nCurrencyDiff ~= player.m_nCurrency then
				if player.m_nCurrency - player.m_nCurrencyDiff > 0 then
					player.CashText = 132
					player:ShowHudText({channel = 4, x = 0.04, y = 0.91, b1 = 0, b2 = 0}, "+"..player.m_nCurrency - player.m_nCurrencyDiff)
				else
					player.CashText = 132
					player:ShowHudText({channel = 4, x = 0.04, y = 0.91, g1 = 25, g2 = 25, b1 = 0, b2 = 0,}, player.m_nCurrency - player.m_nCurrencyDiff)
				end
			end
			player.m_nCurrencyDiff = player.m_nCurrency
			player.CashText = player.CashText - 1
			if player.CashText == 0 then player:ShowHudText({channel = 4}, "") end
		end
	end
	if DoublePointsDuration > 0 then
		DoublePointsDuration = DoublePointsDuration - 1
		DoublePointsText = "Double Points: ".. math.floor(DoublePointsDuration/66+1)
	else
		DoublePointsText = ""
	end
	if FireSaleDuration > 0 then
		FireSaleDuration = FireSaleDuration - 1
		FireSaleText = "Fire Sale: ".. math.floor(FireSaleDuration/66+1)
	else
		FireSaleText = ""
	end
	if InstakillDuration > 0 then
		InstakillDuration = InstakillDuration - 1
		InstakillText = "Instakill: ".. math.floor(InstakillDuration/66+1)
	else
		InstakillText = ""
	end
end

function OnPlayerConnected(player)
	if player:IsRealPlayer() then
		player.HoldTime = 0
		player.InteractWith = "nothing"
		player.InteractCooldown = false
		player.loadout = {[0] = "Default", [1] = "Default", [2] = "Default"}
		player.m_nCurrencyDiff = 0

		local handle = player:GetHandleIndex()

		deathCounts[handle] = 0
	
		player:AddCallback(ON_DEATH, function()
			deathCounts[handle] = deathCounts[handle] + 1
		end)

		player:AddCallback(ON_SPAWN, function()
			for weapon = 0, 3, 1 do
				if player.loadout[weapon] ~= "Default" then
					player:GiveItem(player.loadout[weapon])
				end
			end
		end)
		
	else
		player:AddCallback(ON_DEATH, function()
			local number = math.random(1,100)
			if number <= 3 then -- 3% chance 
				DropPowerup(player)
			end
		end);
	end
end

function ShuffleInPlace(t) --copied from stack overflow
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

function OnWaveStart()
	BoxTable = {}
	waveActive = true
	ThunderGunTaken = false
	DumpsterRoulette = {1,2,3,4,5}
	DumpsterRouletteIndex = 1
	PowerupTable = {[1] = "DoublePoints", [2] = "FireSale", [3] = "Instakill", [4] = "Nuke", [5] = "MaxAmmo", [6] = "BonusPoints"}
	PowerupTableIndex = 1
	ShuffleInPlace(DumpsterRoulette)
	ShuffleInPlace(PowerupTable)
	for box = 1, 5, 1 do
		ents.FindByName("dumpster_spawner"..box):Teleport(ents.FindByName("dumpster_tele_out"):GetAbsOrigin())
		ents.FindByName("dumpster_spawner"..box):AcceptInput("ForceSpawn")
		BoxTable[box] = {message = 0, weapon = "", text = "", slot = "", response = "", firesale = false, dud = true, timer = 0, count = 0, spawned = false, opened = false}
	end
	SpawnDumpsterBox(DumpsterRoulette[DumpsterRouletteIndex])
	timer.Simple(0.5,function()
		ents.FindByName("vm_jugmsg"):AddCallback(ON_START_TOUCH,
			function(_, player)
				if player:IsRealPlayer() and player.m_nCurrency >= 2500 then
					player.InteractWith = "vm_jugbutton"
				end
			end)
		ents.FindByName("vm_jugmsg"):AddCallback(ON_END_TOUCH,
			function(_, player)
				if player:IsRealPlayer() then
					player.InteractWith = "nothing"
					player:Print(2,"")
				end
			end)
		ents.FindByName("vm_quickrevmsg"):AddCallback(ON_START_TOUCH,
			function(_, player)
				if player:IsRealPlayer() and player.m_nCurrency >= 1500 then
					player.InteractWith = "vm_quickrevbutton"
				end
			end)
		ents.FindByName("vm_quickrevmsg"):AddCallback(ON_END_TOUCH,
			function(_, player)
				if player:IsRealPlayer() then
					player.InteractWith = "nothing"
					player:Print(2,"")
				end
			end)
		ents.FindByName("vm_speedmsg"):AddCallback(ON_START_TOUCH,
			function(_, player)
				if player:IsRealPlayer() and player.m_nCurrency >= 3000 then
					player.InteractWith = "vm_speedbutton"

				end
			end)
		ents.FindByName("vm_speedmsg"):AddCallback(ON_END_TOUCH,
			function(_, player)
				if player:IsRealPlayer() then
					player.InteractWith = "nothing"
					player:Print(2,"")
				end
			end)
		ents.FindByName("vm_blastermsg"):AddCallback(ON_START_TOUCH,
			function(_, player)
				if player:IsRealPlayer() and player.m_nCurrency >= 1500 then
					player.InteractWith = "vm_blasterbutton"
				end
			end)
		ents.FindByName("vm_blastermsg"):AddCallback(ON_END_TOUCH,
			function(_, player)
				if player:IsRealPlayer() then
					player.InteractWith = "nothing"
					player:Print(2,"")
				end
			end)
		ents.FindByName("vm_dtmsg"):AddCallback(ON_START_TOUCH,
			function(_, player)
				if player:IsRealPlayer() and player.m_nCurrency >= 2000 then
					player.InteractWith = "vm_dtbutton"
				end
			end)
		ents.FindByName("vm_dtmsg"):AddCallback(ON_END_TOUCH,
			function(_, player)
				if player:IsRealPlayer() then
					player.InteractWith = "nothing"
					player:Print(2,"")
				end
			end)
	--	ents.FindByName("vm_flopmsg"):AddCallback(ON_START_TOUCH,
	--		function(_, player)
	--			if player:IsRealPlayer() and player.m_nCurrency >= 1000 then
	--				player.InteractWith = "vm_flopbutton"
	--			end
	--		end)
	--	ents.FindByName("vm_flopmsg"):AddCallback(ON_END_TOUCH,
	--		function(_, player)
	--			if player:IsRealPlayer() then
	--				player.InteractWith = "nothing"
	--			end
	--		end)
	end)
	TextDisplay = timer.Create(1, function()
		ents.FindByName("poweruptext"):AcceptInput("$SetKey$message",FireSaleText .. "\n" ..InstakillText .. "\n" ..DoublePointsText)
		ents.FindByName("poweruptext"):AcceptInput("Display")
		ents.FindByName("enemytext"):AcceptInput("Display")
		ents.FindByName("roundtext"):AcceptInput("Display") end, 0)
end

function Interact(player)
	if player.InteractWith == "dumpsterbutton1" and player.m_nCurrency >= DumpsterCost and ents.FindByName("dumpster_light1").m_On == false then
		OpenDumpsterBox(player, 1)
		player.m_nCurrency = player.m_nCurrency - DumpsterCost
	elseif player.InteractWith == "tradeweapon1" then
		DumpsterBoxTakeWeapon(player, 1)
	elseif player.InteractWith == "dumpsterbutton2" and player.m_nCurrency >= DumpsterCost and ents.FindByName("dumpster_light2").m_On == false then
		OpenDumpsterBox(player, 2)
		player.m_nCurrency = player.m_nCurrency - DumpsterCost
	elseif player.InteractWith == "tradeweapon2" then
		DumpsterBoxTakeWeapon(player, 2)
	elseif player.InteractWith == "dumpsterbutton3" and player.m_nCurrency >= DumpsterCost and ents.FindByName("dumpster_light3").m_On == false then
		OpenDumpsterBox(player, 3)
		player.m_nCurrency = player.m_nCurrency - DumpsterCost
	elseif player.InteractWith == "tradeweapon3" then
		DumpsterBoxTakeWeapon(player, 3)
	elseif player.InteractWith == "dumpsterbutton4" and player.m_nCurrency >= DumpsterCost and ents.FindByName("dumpster_light4").m_On == false then
		OpenDumpsterBox(player, 4)
		player.m_nCurrency = player.m_nCurrency - DumpsterCost
	elseif player.InteractWith == "tradeweapon4" then
		DumpsterBoxTakeWeapon(player, 4)
	elseif player.InteractWith == "dumpsterbutton5" and player.m_nCurrency >= DumpsterCost and ents.FindByName("dumpster_light5").m_On == false then
		OpenDumpsterBox(player, 5)
		player.m_nCurrency = player.m_nCurrency - DumpsterCost
	elseif player.InteractWith == "tradeweapon5" then
		DumpsterBoxTakeWeapon(player, 5)
	elseif player.InteractWith == "vm_jugbutton" and player.m_nCurrency >= 2500 then
		if player:GetAttributeValue("max health additive bonus") == nil then
			ents.FindByName("vm_jugbutton"):AcceptInput("Press",_,player)
			if player:GetPlayerItemBySlot(1):GetClassname() ~= "tf_weapon_pipebomblauncher" then PlayViewmodelSequence(player) end
			timer.Simple(1, function() player.InteractCooldown = true end)
			timer.Simple(2.3, function() player.InteractCooldown = false end)
		else
			player:Print(2,"You already have this perk!")
		end
	elseif player.InteractWith == "vm_quickrevbutton" and player.m_nCurrency >= 1500 then
		if player:InCond(70) == 0 then
			ents.FindByName("vm_quickrevbutton"):AcceptInput("Press",_,player)
			if player:GetPlayerItemBySlot(1):GetClassname() ~= "tf_weapon_pipebomblauncher" then PlayViewmodelSequence(player) end
			timer.Simple(1, function() player.InteractCooldown = true end)
			timer.Simple(2.3, function() player.InteractCooldown = false end)
		elseif player:InCond(70) == 1 then
			player:Print(2,"You already have this perk!")
		end
	elseif player.InteractWith == "vm_speedbutton" and player.m_nCurrency >= 3000 then
		if player:GetAttributeValue("move speed bonus") == nil then
			ents.FindByName("vm_speedbutton"):AcceptInput("Press",_,player)
			if player:GetPlayerItemBySlot(1):GetClassname() ~= "tf_weapon_pipebomblauncher" then PlayViewmodelSequence(player) end
			timer.Simple(1, function() player.InteractCooldown = true end)
			timer.Simple(2.3, function() player.InteractCooldown = false end)
		else
			player:Print(2,"You already have this perk!")
		end
	elseif player.InteractWith == "vm_blasterbutton" and player.m_nCurrency >= 1500 then
		if player:GetAttributeValue("explosive sniper shot") == nil then
			ents.FindByName("vm_blasterbutton"):AcceptInput("Press",_,player)
			if player:GetPlayerItemBySlot(1):GetClassname() ~= "tf_weapon_pipebomblauncher" then PlayViewmodelSequence(player) end
			timer.Simple(1, function() player.InteractCooldown = true end)
			timer.Simple(2.3, function() player.InteractCooldown = false end)
		else
			player:Print(2,"You already have this perk!")
		end
	elseif player.InteractWith == "vm_dtbutton" and player.m_nCurrency >= 2000 then
		if player:GetAttributeValue("fire rate bonus") == nil then
			ents.FindByName("vm_dtbutton"):AcceptInput("Press",_,player)
			if player:GetPlayerItemBySlot(1):GetClassname() ~= "tf_weapon_pipebomblauncher" then PlayViewmodelSequence(player) end
			timer.Simple(1, function() player.InteractCooldown = true end)
			timer.Simple(2.3, function() player.InteractCooldown = false end)
		else
			player:Print(2,"You already have this perk!")
		end
	end
end

function PlayViewmodelSequence(player)
	for k,v in pairs(ents.FindAllByClass("tf_viewmodel")) do
		if v.m_hOwner == player then
			local PreviousPrimary = player:GetPlayerItemBySlot(0)
			local PreviousSecondary = player:GetPlayerItemBySlot(1)
			if player:GetPlayerItemBySlot(0) ~= nil then
				PreviousPrimary = player:GetPlayerItemBySlot(0):GetItemName()
			end
			if player:GetPlayerItemBySlot(1) ~= nil then
				PreviousSecondary = player:GetPlayerItemBySlot(1):GetItemName()
				if player:GetPlayerItemBySlot(1).m_flChargeLevel ~= nil then
					PreviousUbercharge = player:GetPlayerItemBySlot(1).m_flChargeLevel
				end
			end
			local PreviousMelee = player:GetPlayerItemBySlot(2):GetItemName()
			player:WeaponStripSlot(0)
			player:WeaponStripSlot(2)
			player:GiveItem("Bonk! Atomic Punch")
			player:WeaponSwitchSlot(1)
			v.m_flPlaybackRate = 0.8
			if player.m_iClass == 1 then
				v.m_nSequence = 41
			elseif player.m_iClass == 2 then
				v.m_nSequence = 34
			elseif player.m_iClass == 3 then
				v.m_nSequence = 52
			elseif player.m_iClass == 4 then
				v.m_nSequence = 34
			elseif player.m_iClass == 5 then
				v.m_nSequence = 23
			elseif player.m_iClass == 6 then
				v.m_nSequence = 32
			elseif player.m_iClass == 7 then
				v.m_nSequence = 29
			elseif player.m_iClass == 9 then --spy skipped
				v.m_nSequence = 52
			end
			timer.Simple(2.2, function()
				player:WeaponStripSlot(1)
				if PreviousPrimary ~= nil then player:GiveItem(PreviousPrimary) end
				if PreviousSecondary ~= nil then player:GiveItem(PreviousSecondary)
					if player:GetPlayerItemBySlot(1).m_flChargeLevel ~= nil then
						player:GetPlayerItemBySlot(1).m_flChargeLevel = PreviousUbercharge
					end
				end
				player:GiveItem(PreviousMelee)
			end)
		end
	end
end

function DropPowerup(player)
	ents.FindByName(PowerupTable[PowerupTableIndex] .. "_spawner"):Teleport(player:GetAbsOrigin())
	ents.FindByName(PowerupTable[PowerupTableIndex] .. "_spawner"):AcceptInput("ForceSpawn")
	if PowerupTableIndex == 6 then
		ShuffleInPlace(PowerupTable)
		PowerupTableIndex = 0
	end
	PowerupTableIndex = PowerupTableIndex + 1
end

function ActivateDoublePoints()
	DoublePointsDuration = 1980 -- 1980 ticks divided by 66 tick rate = 30 seconds
	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() then
			player:Print(2,"Double Points!")
			player:PlaySoundToSelf("shadows/powerup_doublepoints.mp3")
			player:PlaySoundToSelf("ui/quest_status_tick_advanced.wav")
		end
	end
end

function ActivateFireSale()
	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() then
			player:Print(2,"Fire Sale!")
			player:PlaySoundToSelf("shadows/powerup_firesale01.mp3")
			player:PlaySoundToSelf("mvm/mvm_bought_upgrade.wav")
			if FireSaleDuration <= 0 then
				timer.Simple(1,function() ents.FindByName("firesale_music"):AcceptInput("PlaySound") end)
			end
		end
	end
	FireSaleDuration = FireSaleDuration + 1980 -- 1980 ticks divided by 66 tick rate = 30 seconds
	DumpsterCost = 10
	for box = 1, 5, 1 do
		if BoxTable[box].spawned == false then
			SpawnDumpsterBox(box)
		end
		BoxTable[box].firesale = true
		BoxTable[box].dud = false
	end
	BoxTable[DumpsterRouletteIndex].firesale = false
	timer.Create(1,
	function() if FireSaleDuration <= 0 then
		DumpsterCost = 950
		for box = 1, 5, 1 do
			if BoxTable[box].firesale == true and BoxTable[box].opened == false then
				ents.FindByName("dumpster_warp_eff"..box):AcceptInput("Start")
				ents.FindByName("dumpster_warp_beam"..box):AcceptInput("Stop")
				ents.FindByName("dumpster_disappear"..box):AcceptInput("PlaySound")
				timer.Simple(1, function() ents.FindByName("dumpster_prop"..box):AcceptInput("$TeleportToEntity","dumpster_tele_out") end)
				timer.Simple(1, function() ents.FindByName("dumpster_msg"..box):AcceptInput("Disable") end)
				BoxTable[box].spawned = false
				BoxTable[DumpsterRouletteIndex].dud = true
			end
		end
		return false
	end end, 0)
end

function ActivateInstakill(_,player)
	InstakillDuration = 1980 -- 1980 ticks divided by 66 tick rate = 30 seconds
		player:Print(2,"Instakill!")
		player:PlaySoundToSelf("items/powerup_pickup_crits.wav")
		player:PlaySoundToSelf("shadows/powerup_instagib.mp3")
		player:AddCond(56,30)
end

function ActivateNuke()
	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() then
			timer.Simple(1,function() player:PlaySoundToSelf("shadows/powerup_nuke_01.mp3") end)
		elseif player.m_iTeamNum == 3 then
			player:TakeDamage({Attacker = player, Damage = 4500})
		end
	end
end

function ActivateMaxAmmo()
	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() then
			player:Print(2,"Max Ammo!")
			player:PlaySoundToSelf("items/powerup_pickup_agility.wav")
			player:PlaySoundToSelf("shadows/powerup_resupply_01.mp3")
			player:PlaySoundToSelf("weapons/dispenser_generate_metal.wav")
			player:RefillAmmo()
		end
	end
end

function ActivateBonusPoints()
	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() then
			player:Print(2,"Bonus Points!")
			player:AcceptInput("$AddCurrency",1000)
			player:PlaySoundToSelf("shadows/powerup_money_01.mp3")
			player:PlaySoundToSelf("mvm/mvm_money_pickup.wav")
		end
	end
end

BoxRoulette =
{
	[1] =
	{
 		{text = "The Shortstop", itemname = "The Shortstop", model = "models/weapons/c_models/c_shortstop/c_shortstop.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
 		{text = "The Shortstop", itemname = "The Shortstop", model = "models/weapons/c_models/c_shortstop/c_shortstop.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "TF_WEAPON_SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "TF_WEAPON_SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Stickybomb Launcher", itemname = "TF_WEAPON_PIPEBOMBLAUNCHER", model = "models/weapons/w_models/w_stickybomb_launcher.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Stickybomb Launcher", itemname = "TF_WEAPON_PIPEBOMBLAUNCHER", model = "models/weapons/w_models/w_stickybomb_launcher.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Force-A-Nature", itemname = "The Force-a-Nature", model = "models/weapons/c_models/c_double_barrel.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Force-A-Nature", itemname = "The Force-a-Nature", model = "models/weapons/c_models/c_double_barrel.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Scattergun", itemname = "TF_WEAPON_SCATTERGUN", model = "models/weapons/w_models/w_scattergun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Scattergun", itemname = "TF_WEAPON_SCATTERGUN", model = "models/weapons/w_models/w_scattergun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Punch Packer", itemname = "The Punch Packer", model = "models/weapons/c_models/c_packer.mdl", slot = "primary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Punch Packer", itemname = "The Punch Packer", model = "models/weapons/c_models/c_packer.mdl", slot = "primary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Ray Gun", itemname = "The Ray Gun", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "a dud", itemname = "Dud", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl"},
	},
	[2] =
	{
		{text = "The Shotgun", itemname = "TF_WEAPON_SHOTGUN_PYRO", model = "models/weapons/w_models/w_shotgun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Shotgun", itemname = "TF_WEAPON_SHOTGUN_PYRO", model = "models/weapons/w_models/w_shotgun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Scattergun", itemname = "TF_WEAPON_SCATTERGUN", model = "models/weapons/w_models/w_scattergun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Scattergun", itemname = "TF_WEAPON_SCATTERGUN", model = "models/weapons/w_models/w_scattergun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Double Barrel", itemname = "Double Barrel", model = "models/weapons/c_models/c_shotfun/c_shotfun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Double Barrel", itemname = "Double Barrel", model = "models/weapons/c_models/c_shotfun/c_shotfun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Stickybomb Launcher", itemname = "TF_WEAPON_PIPEBOMBLAUNCHER", model = "models/weapons/w_models/w_stickybomb_launcher.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Stickybomb Launcher", itemname = "TF_WEAPON_PIPEBOMBLAUNCHER", model = "models/weapons/w_models/w_stickybomb_launcher.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Crusader's Crossbow", itemname = "The Crusader's Crossbow", model = "models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Crusader's Crossbow", itemname = "The Crusader's Crossbow", model = "models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Beam Rifle", itemname = "Beam Rifle", model = "models/workshop/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Punch Packer", itemname = "The Punch Packer", model = "models/weapons/c_models/c_packer.mdl", slot = "primary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Ray Gun", itemname = "The Ray Gun", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Cleaner's Carbine", itemname = "The Cleaner's Carbine", model = "models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "a dud", itemname = "Dud", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl"},
	},
	[3] =
	{
		{text = "The Double Barrel", itemname = "Double Barrel", model = "models/weapons/c_models/c_shotfun/c_shotfun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Double Barrel", itemname = "Double Barrel", model = "models/weapons/c_models/c_shotfun/c_shotfun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "TF_WEAPON_SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "TF_WEAPON_SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Rocket Launcher", itemname = "TF_WEAPON_ROCKETLAUNCHER", model = "models/weapons/w_models/w_rocketlauncher.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Rocket Launcher", itemname = "TF_WEAPON_ROCKETLAUNCHER", model = "models/weapons/w_models/w_rocketlauncher.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Beam Rifle", itemname = "Beam Rifle", model = "models/workshop/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Tactigatling", itemname = "Tactigatling", model = "models/weapons/c_models/c_tgat/c_tgat.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Ray Gun", itemname = "The Ray Gun", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Cleaner's Carbine", itemname = "The Cleaner's Carbine", model = "models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Cleaner's Carbine", itemname = "The Cleaner's Carbine", model = "models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Thunder Gun", itemname = "Thunder Gun", model = "models/weapons/c_models/c_drg_phlogistinator/c_drg_phlogistinator.mdl", slot = "secondary", response = "TLK_MVM_LOOT_ULTRARARE"},
		{text = "a dud", itemname = "Dud", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl"},
	},
	[4] =
	{
		{text = "The Shotgun", itemname = "TF_WEAPON_SHOTGUN_PYRO", model = "models/weapons/w_models/w_shotgun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Shotgun", itemname = "TF_WEAPON_SHOTGUN_PYRO", model = "models/weapons/w_models/w_shotgun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Double Barrel", itemname = "Double Barrel", model = "models/weapons/c_models/c_shotfun/c_shotfun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Double Barrel", itemname = "Double Barrel", model = "models/weapons/c_models/c_shotfun/c_shotfun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "TF_WEAPON_SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "TF_WEAPON_SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Stickybomb Launcher", itemname = "TF_WEAPON_PIPEBOMBLAUNCHER", model = "models/weapons/w_models/w_stickybomb_launcher.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Stickybomb Launcher", itemname = "TF_WEAPON_PIPEBOMBLAUNCHER", model = "models/weapons/w_models/w_stickybomb_launcher.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Beam Rifle", itemname = "Beam Rifle", model = "models/workshop/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Tactigatling", itemname = "Tactigatling", model = "models/weapons/c_models/c_tgat/c_tgat.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Ray Gun", itemname = "The Ray Gun", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "a dud", itemname = "Dud", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl"},
	},
	[5] =
	{
		{text = "The Scattergun", itemname = "TF_WEAPON_SCATTERGUN", model = "models/weapons/w_models/w_scattergun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Scattergun", itemname = "TF_WEAPON_SCATTERGUN", model = "models/weapons/w_models/w_scattergun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Flamethrower", itemname = "TF_WEAPON_FLAMETHROWER", model = "models/weapons/c_models/c_flamethrower/c_flamethrower.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Flamethrower", itemname = "TF_WEAPON_FLAMETHROWER", model = "models/weapons/c_models/c_flamethrower/c_flamethrower.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Punch Packer", itemname = "The Punch Packer", model = "models/weapons/c_models/c_packer.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Punch Packer", itemname = "The Punch Packer", model = "models/weapons/c_models/c_packer.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "Primary SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "Primary SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Crusader's Crossbow", itemname = "The Crusader's Crossbow", model = "models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Crusader's Crossbow", itemname = "The Crusader's Crossbow", model = "models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Black Box", itemname = "The Black Box", model = "models/workshop/weapons/c_models/c_blackbox/c_blackbox.mdl", slot = "primary", response = "TLK_MVM_LOOT_RARE"},
		{text = "Das Maschinenpistole", itemname = "Das Maschinenpistole", model = "models/weapons/c_models/c_mp40/c_mp40.mdl", slot = "primary", response = "TLK_MVM_LOOT_RARE"},
		{text = "a dud", itemname = "Dud", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl"},
	},
	[6] =
	{
		{text = "The Double Barrel", itemname = "Double Barrel", model = "models/weapons/c_models/c_shotfun/c_shotfun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Double Barrel", itemname = "Double Barrel", model = "models/weapons/c_models/c_shotfun/c_shotfun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Flamethrower", itemname = "TF_WEAPON_FLAMETHROWER", model = "models/weapons/c_models/c_flamethrower/c_flamethrower.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Flamethrower", itemname = "TF_WEAPON_FLAMETHROWER", model = "models/weapons/c_models/c_flamethrower/c_flamethrower.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Minigun", itemname = "TF_WEAPON_MINIGUN", model = "models/weapons/w_models/w_minigun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Minigun", itemname = "TF_WEAPON_MINIGUN", model = "models/weapons/w_models/w_minigun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "TF_WEAPON_SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "TF_WEAPON_SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Beam Rifle", itemname = "Beam Rifle", model = "models/workshop/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Tactigatling", itemname = "Tactigatling", model = "models/weapons/c_models/c_tgat/c_tgat.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Ray Gun", itemname = "The Ray Gun", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Thunder Gun", itemname = "Thunder Gun", model = "models/weapons/c_models/c_drg_phlogistinator/c_drg_phlogistinator.mdl", slot = "secondary", response = "TLK_MVM_LOOT_ULTRARARE"},
		{text = "a dud", itemname = "Dud", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl"},
	},
	[7] =
	{
		{text = "The Dragon's Fury", itemname = "The Dragon's Fury", model = "models/weapons/c_models/c_flameball/c_flameball.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Dragon's Fury", itemname = "The Dragon's Fury", model = "models/weapons/c_models/c_flameball/c_flameball.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Double Barrel", itemname = "Double Barrel", model = "models/weapons/c_models/c_shotfun/c_shotfun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Double Barrel", itemname = "Double Barrel", model = "models/weapons/c_models/c_shotfun/c_shotfun.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Flamethrower", itemname = "TF_WEAPON_FLAMETHROWER", model = "models/weapons/c_models/c_flamethrower/c_flamethrower.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Flamethrower", itemname = "TF_WEAPON_FLAMETHROWER", model = "models/weapons/c_models/c_flamethrower/c_flamethrower.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Minigun", itemname = "TF_WEAPON_MINIGUN", model = "models/weapons/w_models/w_minigun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Minigun", itemname = "TF_WEAPON_MINIGUN", model = "models/weapons/w_models/w_minigun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "TF_WEAPON_SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "TF_WEAPON_SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Tactigatling", itemname = "Tactigatling", model = "models/weapons/c_models/c_tgat/c_tgat.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Ray Gun", itemname = "The Ray Gun", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Thunder Gun", itemname = "Thunder Gun", model = "models/weapons/c_models/c_drg_phlogistinator/c_drg_phlogistinator.mdl", slot = "secondary", response = "TLK_MVM_LOOT_ULTRARARE"},
		{text = "a dud", itemname = "Dud", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl"},
	},
	--[8]spy excluded because he is unplayable
	[9] =
	{
		{text = "The Shotgun", itemname = "TF_WEAPON_SHOTGUN_PRIMARY", model = "models/weapons/w_models/w_shotgun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Shotgun", itemname = "TF_WEAPON_SHOTGUN_PRIMARY", model = "models/weapons/w_models/w_shotgun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Scattergun", itemname = "TF_WEAPON_SCATTERGUN", model = "models/weapons/w_models/w_scattergun.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "TF_WEAPON_SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The SMG", itemname = "TF_WEAPON_SMG", model = "models/weapons/w_models/w_smg.mdl", slot = "secondary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The B.M.M.H", itemname = "The B.M.M.H", model = "models/weapons/c_models/c_bmmh/c_bmmh.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The B.M.M.H", itemname = "The B.M.M.H", model = "models/weapons/c_models/c_bmmh/c_bmmh.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Nostromo Napalmer", itemname = "The Nostromo Napalmer", model = "models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Nostromo Napalmer", itemname = "The Nostromo Napalmer", model = "models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl", slot = "primary", response = "TLK_MVM_LOOT_COMMON"},
		{text = "The Punch Packer", itemname = "The Punch Packer", model = "models/weapons/c_models/c_packer.mdl", slot = "primary", response = "TLK_MVM_LOOT_RARE"},
		{text = "The Ray Gun", itemname = "The Ray Gun", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl", slot = "secondary", response = "TLK_MVM_LOOT_RARE"},
		{text = "a dud", itemname = "Dud", model = "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl"},
	}
}

function SpawnDumpsterBox(box)
	if BoxTable[box].spawned == false then
		BoxTable[box].spawned = true
		ents.FindByName("dumpster_push"..box):AcceptInput("$TeleportToEntity","dumpster_tele_"..box)
		ents.FindByName("dumpster_push"..box):AcceptInput("Enable")
		ents.FindByName("dumpster_lid"..box):AcceptInput("TurnOff")
		ents.FindByName("dumpster_weapon"..box):AcceptInput("TurnOff")
		ents.FindByName("dumpster_prop"..box):AcceptInput("TurnOff")
		ents.FindByName("dumpster_light"..box):AcceptInput("TurnOff")
		ents.FindByName("dumpster_msg"..box):AcceptInput("Disable")
		ents.FindByName("dumpster_weapon"..box):AcceptInput("SetParent","dumpster_train"..box)
		timer.Simple(1, function() ents.FindByName("dumpster_prop"..box):AcceptInput("$TeleportToEntity","dumpster_tele_"..box) end)
		timer.Simple(1, function() ents.FindByName("dumpster_warp_eff"..box):AcceptInput("Start") end)
		timer.Simple(1, function() ents.FindByName("dumpster_warp_beam"..box):AcceptInput("Start") end)
		timer.Simple(1.5, function() ents.FindByName("dumpster_appear"..box):AcceptInput("PlaySound") end)
		timer.Simple(2, function() ents.FindByName("dumpster_lid"..box):AcceptInput("TurnOn") end)
		timer.Simple(2, function() ents.FindByName("dumpster_prop"..box):AcceptInput("TurnOn") end)
		timer.Simple(2, function() ents.FindByName("dumpster_msg"..box):AcceptInput("Enable") end)
		timer.Simple(2, function() ents.FindByName("dumpster_push"..box):AcceptInput("Disable") end)
		timer.Simple(3.2, function() ents.FindByName("dumpster_warp_eff"..box):AcceptInput("Stop") end)
		BoxTable[box].message = ents.FindByName("dumpster_msg"..box):AddCallback(ON_START_TOUCH,
		function(_, player)
			if player:IsRealPlayer() then
				player.InteractWith = "dumpsterbutton"..box
				player:Print(2,"Hold Action key to receive a weapon for $"..DumpsterCost)
			end
		end)
		ents.FindByName("dumpster_msg"..box):AddCallback(ON_END_TOUCH,
		function(_, player)
			if player:IsRealPlayer() then
				player.InteractWith = "nothing"
				player:Print(2,"")
			end
		end)
	end
end

function OpenDumpsterBox(player, box)
		local owner = player
		BoxTable[box].count = BoxTable[box].count + 1
		BoxTable[box].opened = true
		ents.FindByName("dumpster_rotdoor"..box):AcceptInput("Open")
		ents.FindByName("dumpster_light"..box):AcceptInput("TurnOn")
		ents.FindByName("dumpster_msg"..box):AcceptInput("Disable")
		ents.FindByName("dumpster_train"..box):AcceptInput("SetSpeed", "0.2")
		ents.FindByName("dumpster_jingle"..box):AcceptInput("PlaySound")
		ents.FindByName("dumpster_weapon"..box):AcceptInput("Enable")
		ents.FindByName("dumpster_particles"..box):AcceptInput("Start")
		ents.FindByName("dumpster_train"..box):AcceptInput("TeleportToPathTrack", "dumpster_track1"..box)
		ents.FindByName("dumpster_msg"..box):RemoveCallback(14,BoxTable[box].message)
		local ChangeWeapon = timer.Create(0.1,
		function()
			local number = math.random(1, #BoxRoulette[player.m_iClass])
			ents.FindByName("dumpster_weapon"..box):AcceptInput("$SetModel", BoxRoulette[player.m_iClass][number].model)
			BoxTable[box].weapon = BoxRoulette[player.m_iClass][number].itemname
			BoxTable[box].text = BoxRoulette[player.m_iClass][number].text
			BoxTable[box].slot = BoxRoulette[player.m_iClass][number].slot
			BoxTable[box].response = BoxRoulette[player.m_iClass][number].response
		end, 0
		)
		timer.Simple(4, function()
			timer.Stop(ChangeWeapon)
			if BoxTable[box].weapon == "Dud" then
				if BoxTable[box].dud == true and BoxTable[box].firesale == false and BoxTable[box].count >= 4 then
					BoxTable[box].count = 0
					if DumpsterRouletteIndex == 5 then
						ShuffleInPlace(DumpsterRoulette)
						DumpsterRouletteIndex = 0
					end
					DumpsterRouletteIndex = DumpsterRouletteIndex+1
					ents.FindByName("dumpster_dudprop"..box):AcceptInput("Enable")
					ents.FindByName("dumpster_weapon"..box):AcceptInput("Disable")
					player:AddCurrency("950")
					player:PlaySoundToSelf("misc/happy_birthday_tf_10.wav")
					timer.Simple(1, function() player:PlaySoundToSelf("shadows/powerup_dud_03.mp3") end)
					timer.Simple(3, function() ents.FindByName("dumpster_warp_eff"..box):AcceptInput("Start") end)
					timer.Simple(3, function() ents.FindByName("dumpster_warp_beam"..box):AcceptInput("Stop") end)
					timer.Simple(3, function() ents.FindByName("dumpster_disappear"..box):AcceptInput("PlaySound") end)
					timer.Simple(4, function() ents.FindByName("dumpster_prop"..box):AcceptInput("$TeleportToEntity","dumpster_tele_out") end)
					timer.Simple(4, function() ents.FindByName("dumpster_dudprop"..box):AcceptInput("Disable") end)
					timer.Simple(4, function() BoxTable[box].spawned = false end)
					timer.Simple(24, function() SpawnDumpsterBox(DumpsterRouletteIndex) end)
				else
					number = math.random(1, #BoxRoulette[player.m_iClass]-1)
					ents.FindByName("dumpster_weapon"..box):AcceptInput("$SetModel", BoxRoulette[player.m_iClass][number].model)
					BoxTable[box].weapon = BoxRoulette[player.m_iClass][number].itemname
					BoxTable[box].text = BoxRoulette[player.m_iClass][number].text
					BoxTable[box].slot = BoxRoulette[player.m_iClass][number].slot
					BoxTable[box].response = BoxRoulette[player.m_iClass][number].response
					BoxTable[box].message = ents.FindByName("dumpster_msg"..box):AddCallback(ON_START_TOUCH,
					function(_, player)
						if player:IsRealPlayer() and player == owner then
							player.InteractWith = "tradeweapon"..box
							player:Print(2,"Hold Action key to trade your " .. BoxTable[box].slot .. " weapon with " .. BoxTable[box].text)
						end
					end)
				ents.FindByName("dumpster_msg"..box):AcceptInput("Enable")
				ents.FindByName("dumpster_train"..box):AcceptInput("TeleportToPathTrack", "dumpster_track2"..box)
				ents.FindByName("dumpster_train"..box):AcceptInput("SetSpeedDir", "0.02")
				end
			elseif BoxTable[box].weapon == "Thunder Gun" and ThunderGunTaken == true then
				ents.FindByName("dumpster_weapon"..box):AcceptInput("$SetModel", "models/weapons/c_models/c_shotfun/c_shotfun.mdl")
				BoxTable[box].weapon = "Double Barrel"
				BoxTable[box].text = "The Double Barrel"
				BoxTable[box].slot = "secondary"
				BoxTable[box].response = "TLK_MVM_LOOT_COMMON"
				BoxTable[box].message = ents.FindByName("dumpster_msg"..box):AddCallback(ON_START_TOUCH,
				function(_, player)
					if player:IsRealPlayer() and player == owner then
						player.InteractWith = "tradeweapon"..box
						player:Print(2,"Hold Action key to trade your " .. BoxTable[box].slot .. " weapon with " .. BoxTable[box].text)
					end
				end)
			else
				BoxTable[box].message = ents.FindByName("dumpster_msg"..box):AddCallback(ON_START_TOUCH,
					function(_, player)
						if player:IsRealPlayer() and player == owner then
							player.InteractWith = "tradeweapon"..box
							player:Print(2,"Hold Action key to trade your " .. BoxTable[box].slot .. " weapon with " .. BoxTable[box].text)
						end
					end)
				ents.FindByName("dumpster_msg"..box):AcceptInput("Enable")
				ents.FindByName("dumpster_train"..box):AcceptInput("TeleportToPathTrack", "dumpster_track2"..box)
				ents.FindByName("dumpster_train"..box):AcceptInput("SetSpeedDir", "0.02")
			end
		end)
		BoxTable[box].timer = timer.Simple(14, function()
			ents.FindByName("dumpster_msg"..box):AcceptInput("Disable")
			ents.FindByName("dumpster_msg"..box):RemoveCallback(14,BoxTable[box].message)
			BoxTable[box].message = ents.FindByName("dumpster_msg"..box):AddCallback(ON_START_TOUCH,
				function(_, player)
					if player:IsRealPlayer() then
						player.InteractWith = "dumpsterbutton"..box
						player:Print(2,"Hold Action key to receive a weapon for $"..DumpsterCost)
					end
				end)
			timer.Simple(1, function() ents.FindByName("dumpster_msg"..box):AcceptInput("Enable") end)
			timer.Simple(1, function() BoxTable[box].opened = false end)
			ents.FindByName("dumpster_rotdoor"..box):AcceptInput("Close")
			ents.FindByName("dumpster_particles"..box):AcceptInput("Stop")
			ents.FindByName("dumpster_light"..box):AcceptInput("TurnOff")
			ents.FindByName("dumpster_weapon"..box):AcceptInput("Disable")
			if BoxTable[box].firesale == true and FireSaleDuration <= 0 then
				ents.FindByName("dumpster_warp_eff"..box):AcceptInput("Start")
				ents.FindByName("dumpster_warp_beam"..box):AcceptInput("Stop")
				ents.FindByName("dumpster_disappear"..box):AcceptInput("PlaySound")
				timer.Simple(1, function() ents.FindByName("dumpster_prop"..box):AcceptInput("$TeleportToEntity","dumpster_tele_out") end)
				timer.Simple(1, function() ents.FindByName("dumpster_msg"..box):AcceptInput("Disable") end)
				BoxTable[box].spawned = false
			end
		end)
	end

function DumpsterBoxTakeWeapon(player, box)
	ents.FindByName("dumpster_msg"..box):AcceptInput("Disable")
	ents.FindByName("dumpster_particles"..box):AcceptInput("Stop")
	ents.FindByName("dumpster_rotdoor"..box):AcceptInput("Close")
	ents.FindByName("dumpster_light"..box):AcceptInput("TurnOff")
	ents.FindByName("dumpster_weapon"..box):AcceptInput("Disable")
	player:GiveItem(BoxTable[box].weapon)
	if BoxTable[box].weapon == "Thunder Gun" then ThunderGunTaken = true end
	if BoxTable[box].slot == "primary" then player.loadout[0] = BoxTable[box].weapon end
	if BoxTable[box].slot == "secondary" then player.loadout[1] = BoxTable[box].weapon end
	player:RefillAmmo()
	player:SpeakResponseConcept(BoxTable[box].response, 0.6)
	player:PlaySoundToSelf("items/gunpickup2.wav")
	player:DisplayTextChat("You've received: " .. BoxTable[box].text .. "!")
	timer.Stop(BoxTable[box].timer)
	ents.FindByName("dumpster_msg"..box):RemoveCallback(14,BoxTable[box].message)
	BoxTable[box].message = ents.FindByName("dumpster_msg"..box):AddCallback(ON_START_TOUCH,
	function(_, player)
		if player:IsRealPlayer() then
			player.InteractWith = "dumpsterbutton"..box
			player:Print(2,"Hold Action key to receive a weapon for $"..DumpsterCost)
		end
	end)
	timer.Simple(1, function() ents.FindByName("dumpster_msg"..box):AcceptInput("Enable") end)
	timer.Simple(1, function() BoxTable[box].opened = false end)
	if BoxTable[box].firesale == true and FireSaleDuration <= 0 then
		ents.FindByName("dumpster_warp_eff"..box):AcceptInput("Start")
		ents.FindByName("dumpster_warp_beam"..box):AcceptInput("Stop")
		ents.FindByName("dumpster_disappear"..box):AcceptInput("PlaySound")
		timer.Simple(1, function() ents.FindByName("dumpster_prop"..box):AcceptInput("$TeleportToEntity","dumpster_tele_out") end)
		timer.Simple(1, function() ents.FindByName("dumpster_msg"..box):AcceptInput("Disable") end)
		BoxTable[box].spawned = false
	end
end

function GiveSuperShank(_,player)
	player:GiveItem("Super Shank")
	player.loadout[2] = "Super Shank"
end