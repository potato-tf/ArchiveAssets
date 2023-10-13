RouletteWinnings = 0
RouletteWinningsTotal = 0
RoulettePulls = 0
PachinkoWinnings = 0
PachinkoWinningsTotal = 0
PachinkoPulls = 0
SlotsWinnings = 0
SlotsWinningsTotal = 0
SlotsPulls = 0
BlackjackWinnings = 0
BlackjackWinningsTotal = 0
BlackjackPulls = 0
RouletteUpgrade = {[0] = 9999, [1] = 0.6, [2] = 0.6, [3] = 0.6}
PachinkoUpgrade = {[0] = 9999, [1] = 10, [2] = 3, [3] = 0.1}
SlotsUpgrade = {[0] = 9999, [1] = 3, [2] = 1.2, [3] = 0.1}
BlackjackUpgrade = {[0] = 9999, [1] = 31, [2] = 17, [3] = 8.5}
RouletteWait = 9999
PachinkoWait = 9999
SlotsWait = 9999
BlackjackWait = 9999
RouletteLevel = 0
PachinkoLevel = 0
SlotsLevel = 0
BlackjackLevel = 0
TicketsOwned = 0
CashedOut = 0
FlagTable = {}
WaveState = {}
EMPBought = false
NukeBought = false
EMPUsed = false
NukeUsed = false
HeliBought = false
ShieldBought = false
ShieldCounter = 0
SpecialPrize = false
MercBotCount = 0
MercBotQueue = {[1] = "", [2] = "", [3] = "", [4] = ""}
DispenserBought = false
TankChipsAmount = 0
FlagAttachments = {
    [1] = {bone = 22, origin = Vector(-0.19, 0.69, 7.85), angles = Vector(1, -3, 2)},
    [3] = {bone = 17, origin = Vector(1.42, 5.01, 8.82), angles = Vector(-4, 11, -10)},
    [7] = {bone = 12, origin = Vector(-0.65, 6.91, 9.17), angles = Vector(-3, -2, -14)},
    [4] = {bone = 16, origin = Vector(0.27, 1.65, 9.72), angles = Vector(-0, -13, -5)},
    [6] = {bone = 13, origin = Vector(0.00, -4.99, 9.58), angles = Vector(1, 3, 11)},
    [9] = {bone = 11, origin = Vector(0.12, 1.92, 9.64), angles = Vector(1, -7, -2)},
    [5] = {bone = 13, origin = Vector(1.02, 3.24, 7.93), angles = Vector(2, -4, -4)},
    [2] = {bone = 13, origin = Vector(0.03, 0.12, 10.38), angles = Vector(-1, 3, 2)},
    [8] = {bone = 20, origin = Vector(0.00, -1.39, 8.95), angles = Vector(-0, 3, 1)},
}
SpentChips = 0
BGMTimer = 0
BossActive = false
SummonHP = 0
SummonCount = 0

for i = 0, 7 do
WaveState[i] = {
		RouletteWinnings = 0,
		RouletteWinningsTotal = 0,
		PachinkoWinnings = 0,
		PachinkoWinningsTotal = 0,
		SlotsWinnings = 0,
		SlotsWinningsTotal = 0,
		BlackjackWinnings = 0,
		BlackjackWinningsTotal = 0,
		RouletteLevel = 0,
		PachinkoLevel = 0,
		SlotsLevel = 0,
		BlackjackLevel = 0,
		TicketsOwned = 0,
		CashedOut = 0,
		EMPBought = false,
		NukeBought = false,
		EMPUsed = false,
		NukeUsed = false,
		HeliBought = false,
		ShieldBought = false,
		ShieldCounter = 0,
		SpecialPrize = false,
		SpentChips = 0}
end


function SpawnRouletteBot()
	for _, bot in pairs(ents.GetAllPlayers()) do
		if bot:IsBot() and bot:IsAlive() == false then
			bot.m_iTeamNum = 2
			bot:SetFakeClientConVar("name", "Automatic Gambler Level " .. RouletteLevel)
			bot:SetAbsOrigin(Vector(-4020, 7424, 64))
			bot:SwitchClassInPlace('Soldier')
			bot:WeaponStripSlot(0)
			bot:WeaponStripSlot(1)
			bot:WeaponSwitchSlot(2)
			bot:SetAttributeValue('dmg taken increased', 0)
			bot:SetAttributeValue('rage giving scale', 0)
			bot:SetAttributeValue('move speed penalty', 0.001)
			bot:SetAttributeValue('no_jump', 1)
			bot:SetAttributeValue('no_attack', 1)
			bot:SetAttributeValue('cannot be sapped', 1)
			bot:SetName('roulettebot')
			bot.m_iTeamNum = 1
			return bot
		end
	end
end

function SpawnPachinkoBot()
	for _, bot in pairs(ents.GetAllPlayers()) do
		if bot:IsBot() and bot:IsAlive() == false then
			bot.m_iTeamNum = 2
			bot:SetFakeClientConVar("name", "Automatic Gambler Level " .. PachinkoLevel)
			bot:SetAbsOrigin(Vector(-1184, 7424, 64))
			bot:SwitchClassInPlace('Soldier')
			bot:WeaponStripSlot(0)
			bot:WeaponStripSlot(1)
			bot:WeaponSwitchSlot(2)
			bot:SetAttributeValue('dmg taken increased', 0)
			bot:SetAttributeValue('rage giving scale', 0)
			bot:SetAttributeValue('move speed penalty', 0.001)
			bot:SetAttributeValue('no_jump', 1)
			bot:SetAttributeValue('no_attack', 1)
			bot:SetAttributeValue('cannot be sapped', 1)
			bot:SetName('pachinkobot')
			bot.m_iTeamNum = 1
			return bot
		end
	end
end

function SpawnSlotsBot()
	for _, bot in pairs(ents.GetAllPlayers()) do
		if bot:IsBot() and bot:IsAlive() == false then
			bot.m_iTeamNum = 2
			bot:SetFakeClientConVar("name", "Automatic Gambler Level " .. SlotsLevel)
			bot:SetAbsOrigin(Vector(2912, 7424, 64))
			bot:SwitchClassInPlace('Soldier')
			bot:WeaponStripSlot(0)
			bot:WeaponStripSlot(1)
			bot:WeaponSwitchSlot(2)
			bot:SetAttributeValue('dmg taken increased', 0)
			bot:SetAttributeValue('rage giving scale', 0)
			bot:SetAttributeValue('move speed penalty', 0.001)
			bot:SetAttributeValue('no_jump', 1)
			bot:SetAttributeValue('no_attack', 1)
			bot:SetAttributeValue('cannot be sapped', 1)
			bot:SetName('slotsbot')
			bot.m_iTeamNum = 1
			return bot
		end
	end
end

function SpawnBlackjackBot()
	for _, bot in pairs(ents.GetAllPlayers()) do
		if bot:IsBot() and bot:IsAlive() == false then
			bot.m_iTeamNum = 2
			bot:SetFakeClientConVar("name", "Automatic Gambler Level " .. BlackjackLevel)
			bot:SetAbsOrigin(Vector(5344, 7424, 64))
			bot:SwitchClassInPlace('Soldier')
			bot:WeaponStripSlot(0)
			bot:WeaponStripSlot(1)
			bot:WeaponSwitchSlot(2)
			bot:SetAttributeValue('dmg taken increased', 0)
			bot:SetAttributeValue('rage giving scale', 0)
			bot:SetAttributeValue('move speed penalty', 0.001)
			bot:SetAttributeValue('no_jump', 1)
			bot:SetAttributeValue('no_attack', 1)
			bot:SetAttributeValue('cannot be sapped', 1)
			bot:SetName('blackjackbot')
			bot.m_iTeamNum = 1
			return bot
		end
	end
end

function OnWaveReset(wave)
	RouletteWinnings = WaveState[wave].RouletteWinnings
	RouletteWinningsTotal = WaveState[wave].RouletteWinningsTotal
	PachinkoWinnings = WaveState[wave].PachinkoWinnings
	PachinkoWinningsTotal = WaveState[wave].PachinkoWinningsTotal
	SlotsWinnings = WaveState[wave].SlotsWinnings
	SlotsWinningsTotal = WaveState[wave].SlotsWinningsTotal
	BlackjackWinnings = WaveState[wave].BlackjackWinnings
	BlackjackWinningsTotal = WaveState[wave].BlackjackWinningsTotal
	RouletteLevel = WaveState[wave].RouletteLevel
	PachinkoLevel = WaveState[wave].PachinkoLevel
	SlotsLevel = WaveState[wave].SlotsLevel
	BlackjackLevel = WaveState[wave].BlackjackLevel

	EMPBought = WaveState[wave].EMPBought
	NukeBought = WaveState[wave].NukeBought
	EMPUsed = WaveState[wave].EMPUsed
	NukeUsed = WaveState[wave].NukeUsed
	HeliBought = WaveState[wave].HeliBought
	ShieldBought = WaveState[wave].ShieldBought
	ShieldCounter = WaveState[wave].ShieldCounter
	SpecialPrize = WaveState[wave].SpecialPrize

	TicketsOwned = WaveState[wave].TicketsOwned
	CashedOut = WaveState[wave].CashedOut
	MercBotCount = 0
	MercBotQueue = {[1] = "", [2] = "", [3] = "", [4] = ""}

	SpentChips = WaveState[wave].SpentChips

	if NukeBought == true then
		timer.Simple(0.2, function()
			if NukeUsed == false then
				ents.FindByName("temp_prize_5_contents"):AcceptInput('ForceSpawn')
				timer.Simple(0.1, function()
					ents.FindByName("prize_5_nuke_button"):AcceptInput('Lock')
					ents.FindByName("prize_5_nuke_button"):AcceptInput('AddOutput', 'OnPressed popscript:$Used:nuke:0:-1')
				end)
			end
			ents.FindByName("prize_bought_relay_5"):AcceptInput('Kill')
			ents.FindByName("prize_compare_cost_5"):AcceptInput('Kill')
			ents.FindByName("prize_button_5"):AcceptInput('Kill')
			ents.FindByName("prize_placeholder_5"):AcceptInput('Kill')
			ents.FindByName("prize_sign_5"):AcceptInput('Kill')
			ents.FindByName("prize_prop_button_5"):AcceptInput('Kill')
		end)
	end

	if EMPBought == true then
		timer.Simple(0.2, function()
			if EMPUsed == false then
				ents.FindByName("temp_prize_7_contents"):AcceptInput('ForceSpawn')
				timer.Simple(0.1, function()
					ents.FindByName("prize_7_nuke_button"):AcceptInput('Lock')
					ents.FindByName("prize_7_nuke_button"):AcceptInput('AddOutput', 'OnPressed popscript:$Used:emp:0:-1')
				end)
			end
			ents.FindByName("prize_bought_relay_7"):AcceptInput('Kill')
			ents.FindByName("prize_compare_cost_7"):AcceptInput('Kill')
			ents.FindByName("prize_button_7"):AcceptInput('Kill')
			ents.FindByName("prize_placeholder_7"):AcceptInput('Kill')
			ents.FindByName("prize_sign_7"):AcceptInput('Kill')
			ents.FindByName("prize_prop_button_7"):AcceptInput('Kill')
		end)
	end

	if SpecialPrize == true then
		timer.Simple(0.2, function()
			ents.FindByName("temp_prize_8_contents"):AcceptInput('ForceSpawn')
			ents.FindByName("prize_bought_relay_8"):AcceptInput('Kill')
			ents.FindByName("prize_compare_cost_8"):AcceptInput('Kill')
			ents.FindByName("prize_button_8"):AcceptInput('Kill')
			ents.FindByName("prize_placeholder_8"):AcceptInput('Kill')
			ents.FindByName("prize_sign_8"):AcceptInput('Kill')
			ents.FindByName("prize_prop_button_8"):AcceptInput('Kill')
		end)
	end

	if HeliBought == true then
		timer.Simple(0.2, function()
			ents.FindByName("temp_prize_1_contents"):AcceptInput('ForceSpawn')
			ents.FindByName("prize_bought_relay_1"):AcceptInput('Kill')
			ents.FindByName("prize_compare_cost_1"):AcceptInput('Kill')
			ents.FindByName("prize_button_1"):AcceptInput('Kill')
			ents.FindByName("prize_placeholder_1"):AcceptInput('Kill')
			ents.FindByName("prize_sign_1"):AcceptInput('Kill')
			ents.FindByName("prize_prop_button_1"):AcceptInput('Kill')
		end)
	end

	if ShieldBought == true then
		timer.Simple(0.2, function()
			ents.FindByName("temp_prize_2_contents"):AcceptInput('ForceSpawn')
			ents.FindByName("prize_bought_relay_2"):AcceptInput('Kill')
			ents.FindByName("prize_compare_cost_2"):AcceptInput('Kill')
			ents.FindByName("prize_button_2"):AcceptInput('Kill')
			ents.FindByName("prize_placeholder_2"):AcceptInput('Kill')
			ents.FindByName("prize_sign_2"):AcceptInput('Kill')
			ents.FindByName("prize_prop_button_2"):AcceptInput('Kill')
			timer.Simple(0.1, function()
				for _,ent in pairs(ents.FindAllByName('prize_2_hatchshield_counter')) do
					ent:AcceptInput('SetValue', ShieldCounter)
				end
			end)
		end)
	end

	ents.FindByName('tickets_text_counter_buffer'):AcceptInput('Add', TicketsOwned)
	ents.FindByClass("func_flagdetectionzone"):AcceptInput('AddOutput', 'alarm 0')
	ents.FindByClass("func_flagdetectionzone"):AcceptInput('AddOutput','OnStartTouchFlag popscript:$Alarm::0:-1')
	ents.FindByClass("func_flagdetectionzone"):AcceptInput('AddOutput','OnEndTouchFlag popscript:$Alarm::0:-1')

	for _, player in pairs(ents.GetAllPlayers()) do
		player:AddCurrency(CashedOut)
	end

	ents.FindByName('howtoplaytext'):AcceptInput('SetText', "The rules have changed")
	ents.FindByName('howtoplaytext2'):AcceptInput('SetText', "1. Using AI technology, the games are\n   operated by automatic gamblers\n2. Robots will drop Australium cores\n   Install cores to upgrade gamblers\n3. No betting, gamblers are only\n   operational during wave time\n4. Collect chips from the gamblers\n   with melee")
	ents.FindByName('howtoplaytext3'):AcceptInput('SetText', "Note: The games do not cost any chips \n        from the players.\nNote: All chips are retained on wave loss.\n        Welcome to the house.")
	ents.FindByName('cashouttext2'):AcceptInput('SetText', "Total: $" .. CashedOut)

	if wave > 1 then
		local i = (RouletteLevel + PachinkoLevel + SlotsLevel + BlackjackLevel)
		local h = 0
		local LeftoverFlags = {}
		while i < math.min(((wave - 1) * 2), 12) do
			LeftoverFlags[i] = ents.SpawnTemplate('CoreFlagLeftover', {translation = Vector(33, -450, 46 + h), rotation = Vector(0, math.random() * 360, 0)})
			i = i + 1
			h = h + 11
		end
		LeftoverFlags[i-1][3]:AcceptInput('Enable')
	else
		ents.SpawnTemplate('CoreFlagProp', {translation = Vector(33, -450, 46), rotation = Vector(0, math.random() * 360, 0)})
	end

	timer.Simple(0.1, function()
		ents.FindByName('temp_prize_3_store'):AcceptInput('AddOutput', 'OnEntitySpawned Prize3ButtonFix:ForceSpawn:0:0:-1')
		ents.FindByName('temp_prize_2_store'):AcceptInput('AddOutput', 'OnEntitySpawned Prize2ButtonFix:ForceSpawn:0:0:-1')

		ents.FindByName('prize_bought_relay_1'):AcceptInput('AddOutput', 'OnTrigger popscript:$Spend:50:0:-1')
		ents.FindByName('prize_bought_relay_2'):AcceptInput('AddOutput', 'OnTrigger popscript:$Spend:15:0:-1')
		ents.FindByName('prize_bought_relay_3'):AcceptInput('AddOutput', 'OnTrigger popscript:$Spend:15:0:-1')
		ents.FindByName('prize_bought_relay_4'):AcceptInput('AddOutput', 'OnTrigger popscript:$Spend:15:0:-1')
		ents.FindByName('prize_bought_relay_5'):AcceptInput('AddOutput', 'OnTrigger popscript:$Spend:50:0:-1')
		ents.FindByName('prize_bought_relay_7'):AcceptInput('AddOutput', 'OnTrigger popscript:$Spend:30:0:-1')
		ents.FindByName('prize_bought_relay_8'):AcceptInput('AddOutput', 'OnTrigger popscript:$Spend:999:0:-1')
		ents.FindByName('prize_bought_relay_1'):AcceptInput('AddOutput', 'OnTrigger popscript:$SpendText:Helicopter!:0:-1')
		ents.FindByName('prize_bought_relay_2'):AcceptInput('AddOutput', 'OnTrigger popscript:$SpendText:Hatch Shield!:0:-1')
		ents.FindByName('prize_bought_relay_3'):AcceptInput('AddOutput', 'OnTrigger popscript:$SpendText:Speed Buff!:0:-1')
		ents.FindByName('prize_bought_relay_4'):AcceptInput('AddOutput', 'OnTrigger popscript:$SpendText:Power Buff!:0:-1')
		ents.FindByName('prize_bought_relay_5'):AcceptInput('AddOutput', 'OnTrigger popscript:$SpendText:Nuke!:0:-1')
		ents.FindByName('prize_bought_relay_7'):AcceptInput('AddOutput', 'OnTrigger popscript:$SpendText:EMP!:0:-1')
		ents.FindByName('prize_bought_relay_8'):AcceptInput('AddOutput', 'OnTrigger popscript:$SpendText:Special Prize!:0:-1')
	end)
end

function OnWaveInit(wave)
	if wave == 1 then
		WaveState[1] = {
				RouletteWinnings = 0,
				RouletteWinningsTotal = 0,
				PachinkoWinnings = 0,
				PachinkoWinningsTotal = 0,
				SlotsWinnings = 0,
				SlotsWinningsTotal = 0,
				BlackjackWinnings = 0,
				BlackjackWinningsTotal = 0,
				RouletteLevel = 0,
				PachinkoLevel = 0,
				SlotsLevel = 0,
				BlackjackLevel = 0,
				TicketsOwned = 0,
				CashedOut = 0,
				EMPBought = false,
				NukeBought = false,
				EMPUsed = false,
				NukeUsed = false,
				HeliBought = false,
				ShieldBought = false,
				ShieldCounter = 0,
				SpecialPrize = false,
				SpentChips = 0}
	end
	WaveSetup = true
	RouletteWait = RouletteUpgrade[0]
	PachinkoWait = PachinkoUpgrade[0]
	SlotsWait = SlotsUpgrade[0]
	BlackjackWait = BlackjackUpgrade[0]

	if DispenserBought == true then
		ResetDispenser()
	end

	WaveState[wave].RouletteWinnings = RouletteWinnings
	WaveState[wave].RouletteWinningsTotal = RouletteWinningsTotal
	WaveState[wave].PachinkoWinnings = PachinkoWinnings
	WaveState[wave].PachinkoWinningsTotal = PachinkoWinningsTotal
	WaveState[wave].SlotsWinnings = SlotsWinnings
	WaveState[wave].SlotsWinningsTotal = SlotsWinningsTotal
	WaveState[wave].BlackjackWinnings = BlackjackWinnings
	WaveState[wave].BlackjackWinningsTotal = BlackjackWinningsTotal
	WaveState[wave].RouletteLevel = RouletteLevel
	WaveState[wave].PachinkoLevel = PachinkoLevel
	WaveState[wave].SlotsLevel = SlotsLevel
	WaveState[wave].BlackjackLevel = BlackjackLevel

	WaveState[wave].EMPBought = EMPBought
	WaveState[wave].NukeBought = EMPBought
	WaveState[wave].EMPUsed = EMPUsed
	WaveState[wave].NukeUsed = NukeUsed
	WaveState[wave].HeliBought = HeliBought
	WaveState[wave].ShieldBought = ShieldBought
	WaveState[wave].ShieldCounter = ShieldCounter
	WaveState[wave].SpecialPrize = SpecialPrize

	WaveState[wave].TicketsOwned = TicketsOwned
	WaveState[wave].CashedOut = CashedOut
	MercBotCount = 0
	MercBotQueue = {[1] = "", [2] = "", [3] = "", [4] = ""}
	ents.FindByName('mercbottext2'):AcceptInput('SetText', "Max (".. MercBotCount .."/4)")

	WaveState[wave].SpentChips = SpentChips

	SpawnRouletteBot()
	SpawnPachinkoBot()
	SpawnSlotsBot()
	SpawnBlackjackBot()

	timer.Simple(0.2, function()
		BetRoulette()
		BetPachinko()
		BetSlots()
		BetBlackjack()
	end)

	timer.Simple(0.1, function()
		ents.FindByName('text_tickets_label'):AcceptInput('AddOutput', 'holdtime 0')
		ents.FindByName('text_tickets_value_3'):AcceptInput('AddOutput', 'holdtime 0')
		ents.FindByName('text_tickets_value_2'):AcceptInput('AddOutput', 'holdtime 0')
		ents.FindByName('text_tickets_value_1'):AcceptInput('AddOutput', 'holdtime 0')
		ents.FindByName('snd_tickets_lose'):AcceptInput('AddOutput', 'message null')
		ents.FindByName('snd_tickets_earn'):AcceptInput('AddOutput', 'message null')

		for _,ent in pairs(ents.FindAllByName('game_3_snd_jackpot')) do
			ent:AcceptInput('AddOutput', 'message null')
		end
		for _,ent in pairs(ents.FindAllByName('game_4_snd_jackpot')) do
			ent:AcceptInput('AddOutput', 'message null')
		end
		for _,ent in pairs(ents.FindAllByName('game_3_snd_spin')) do
			ent:AcceptInput('AddOutput', 'health 5')
		end

		ents.FindByName('game_1_timer'):AcceptInput('UpperRandomBound', 10-(RouletteLevel-1)*2.5)
		ents.FindByName('game_1_timer'):AcceptInput('LowerRandomBound', 7-(RouletteLevel-1)*2.5)
		ents.FindByName('rouletteleveltext'):AcceptInput('SetText', 'Level '..RouletteLevel)
		ents.FindByName('rouletteleveltext2'):AcceptInput('SetText', 'Level '..RouletteLevel)
		if RouletteLevel == 3 then
			ents.FindByName('rouletteleveltext'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('rouletteleveltext2'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('roulettetarget'):AcceptInput('$TeleportToEntity', 'spawnbot_chips')
		else
			ents.FindByName('rouletteleveltext'):AcceptInput('SetColor', '255 255 255')
			ents.FindByName('rouletteleveltext2'):AcceptInput('SetColor', '255 255 255')
			ents.FindByName('roulettetarget'):AcceptInput('$TeleportToEntity', 'rouletteleveltext2')
		end
		ents.FindByName('roulettebot'):SetFakeClientConVar("name", "Automatic Gambler Level " .. RouletteLevel)

		ents.FindByName('pachinkoleveltext'):AcceptInput('SetText', 'Level '..PachinkoLevel)
		ents.FindByName('pachinkoleveltext2'):AcceptInput('SetText', 'Level '..PachinkoLevel)
		if PachinkoLevel == 3 then
			ents.FindByName('pachinkoleveltext'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('pachinkoleveltext2'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('pachinkotarget'):AcceptInput('$TeleportToEntity', 'spawnbot_chips')
		else
			ents.FindByName('pachinkoleveltext'):AcceptInput('SetColor', '255 255 255')
			ents.FindByName('pachinkoleveltext2'):AcceptInput('SetColor', '255 255 255')
			ents.FindByName('pachinkotarget'):AcceptInput('$TeleportToEntity', 'pachinkoleveltext2')
		end
		ents.FindByName('pachinkobot'):SetFakeClientConVar("name", "Automatic Gambler Level " .. PachinkoLevel)

		ents.FindByName('slotsleveltext'):AcceptInput('SetText', 'Level '..SlotsLevel)
		ents.FindByName('slotsleveltext2'):AcceptInput('SetText', 'Level '..SlotsLevel)
		if SlotsLevel == 3 then
			ents.FindByName('slotsleveltext'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('slotsleveltext2'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('slotstarget'):AcceptInput('$TeleportToEntity', 'spawnbot_chips')
		else
			ents.FindByName('slotsleveltext'):AcceptInput('SetColor', '255 255 255')
			ents.FindByName('slotsleveltext2'):AcceptInput('SetColor', '255 255 255')
			ents.FindByName('slotstarget'):AcceptInput('$TeleportToEntity', 'slotsleveltext2')
		end
		ents.FindByName('slotsbot'):SetFakeClientConVar("name", "Automatic Gambler Level " .. SlotsLevel)
		ents.FindByName('game_3_slot_motor_1'):AcceptInput('AddOutput', 'speed ' .. 720+315*(SlotsLevel-1))
		ents.FindByName('game_3_slot_motor_2'):AcceptInput('AddOutput', 'speed ' .. 720+315*(SlotsLevel-1))
		ents.FindByName('game_3_slot_motor_3'):AcceptInput('AddOutput', 'speed ' .. 720+315*(SlotsLevel-1))

		ents.FindByName('blackjackleveltext'):AcceptInput('SetText', 'Level '..BlackjackLevel)
		ents.FindByName('blackjackleveltext2'):AcceptInput('SetText', 'Level '..BlackjackLevel)
		if BlackjackLevel == 3 then
			ents.FindByName('blackjackleveltext'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('blackjackleveltext2'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('blackjacktarget'):AcceptInput('$TeleportToEntity', 'spawnbot_chips')
		else
			ents.FindByName('blackjackleveltext'):AcceptInput('SetColor', '255 255 255')
			ents.FindByName('blackjackleveltext2'):AcceptInput('SetColor', '255 255 255')
			ents.FindByName('blackjacktarget'):AcceptInput('$TeleportToEntity', 'blackjackleveltext2')
		end
		ents.FindByName('blackjackbot'):SetFakeClientConVar("name", "Automatic Gambler Level " .. BlackjackLevel)

		ents.FindByName('roulettecollect'):AcceptInput('SetText', 'Chips Collected: ' .. RouletteWinnings .. '\n\nTotal: ' .. RouletteWinningsTotal)
		ents.FindByName('pachinkocollect'):AcceptInput('SetText', 'Chips Collected: ' .. PachinkoWinnings .. '\n\nTotal: ' .. PachinkoWinningsTotal)
		ents.FindByName('slotscollect'):AcceptInput('SetText', 'Chips Collected: ' .. SlotsWinnings .. '\n\nTotal: ' .. SlotsWinningsTotal)
		ents.FindByName('blackjackcollect'):AcceptInput('SetText', 'Chips Collected: ' .. BlackjackWinnings .. '\n\nTotal: ' .. BlackjackWinningsTotal)
		ents.FindByName('allcollect'):AcceptInput('SetText', 'Roulette.' .. RouletteLevel .. ':      ' .. RouletteWinnings .. '\nPachinko.' .. PachinkoLevel .. ':       ' .. PachinkoWinnings .. '\nSlots.' .. SlotsLevel .. ':          ' .. SlotsWinnings .. '\nBlackjack.' .. BlackjackLevel .. ':     ' .. BlackjackWinnings)

		ents.FindByName('game_1_relay_wheel_start'):AcceptInput('AddOutput', 'OnTrigger popscript:$BetRoulette:0:0:-1')
		ents.FindByName('game_2_counter_credits'):AcceptInput('AddOutput', 'OnHitMin popscript:$BetPachinko:0:0:-1')
		ents.FindByName('game_3_counter_credits'):AcceptInput('AddOutput', 'OnHitMin popscript:$BetSlots:0:0:-1')
		ents.FindByName('game_4_counter_credits'):AcceptInput('AddOutput', 'OnHitMin popscript:$BetBlackjack:0:0:-1')

		ents.FindByName('game_1_relay_buttons_unlock'):AcceptInput('AddOutput', 'OnTrigger game_1_door_button_blocker:Close::0.1:-1')
		ents.FindByName('game_2_counter_credits'):AcceptInput('AddOutput', 'OnHitMax game_2_door_button_blocker:Enable::0.1:-1')
		ents.FindByName('game_3_counter_credits'):AcceptInput('AddOutput', 'OnHitMax game_3_door_button_blocker:Enable::0.1:-1')
		ents.FindByName('game_4_cards_relay_ready'):AcceptInput('AddOutput', 'OnTrigger game_4_door_button_blocker:Enable::0.1:-1')

		ents.FindByName('game_1_relay_button_red'):AcceptInput('AddOutput', 'OnTrigger popscript:$CountRoulette:8:0:-1')
		ents.FindByName('game_1_relay_button_blue'):AcceptInput('AddOutput', 'OnTrigger popscript:$CountRoulette:8:0:-1')
		ents.FindByName('game_1_relay_button_orange'):AcceptInput('AddOutput', 'OnTrigger popscript:$CountRoulette:16:0:-1')
		ents.FindByName('game_1_relay_button_white'):AcceptInput('AddOutput', 'OnTrigger popscript:$CountRoulette:32:0:-1')
		ents.FindByName('game_2_trigger_1'):AcceptInput('AddOutput', 'OnStartTouch popscript:$CountPachinko:3:0:-1')
		ents.FindByName('game_2_trigger_2'):AcceptInput('AddOutput', 'OnStartTouch popscript:$CountPachinko:1:0:-1')
		ents.FindByName('game_2_trigger_3'):AcceptInput('AddOutput', 'OnStartTouch popscript:$CountPachinko:5:0:-1')
		ents.FindByName('game_2_trigger_5'):AcceptInput('AddOutput', 'OnStartTouch popscript:$CountPachinko:8:0:-1')
		ents.FindByName('game_2_trigger_7'):AcceptInput('AddOutput', 'OnStartTouch popscript:$CountPachinko:5:0:-1')
		ents.FindByName('game_2_trigger_8'):AcceptInput('AddOutput', 'OnStartTouch popscript:$CountPachinko:1:0:-1')
		ents.FindByName('game_2_trigger_9'):AcceptInput('AddOutput', 'OnStartTouch popscript:$CountPachinko:3:0:-1')
		ents.FindByName('game_3_payout_case_1'):AcceptInput('AddOutput', 'OnCase04 popscript:$CountSlots:100:0:-1')
		ents.FindByName('game_3_payout_case_2'):AcceptInput('AddOutput', 'OnCase04 popscript:$CountSlots:3:0:-1')
		ents.FindByName('game_3_payout_case_3'):AcceptInput('AddOutput', 'OnCase04 popscript:$CountSlots:10:0:-1')
		ents.FindByName('game_3_payout_case_4'):AcceptInput('AddOutput', 'OnCase04 popscript:$CountSlots:10:0:-1')
		ents.FindByName('game_3_payout_case_4'):AcceptInput('AddOutput', 'OnCase03 popscript:$CountSlots:5:0:-1')
		ents.FindByName('game_3_payout_case_4'):AcceptInput('AddOutput', 'OnCase02 popscript:$CountSlots:2:0:-1')
		ents.FindByName('game_3_payout_case_5'):AcceptInput('AddOutput', 'OnCase04 popscript:$CountSlots:50:0:-1')
		ents.FindByName('game_3_payout_case_6'):AcceptInput('AddOutput', 'OnCase04 popscript:$CountSlots:30:0:-1')
		ents.FindByName('game_3_payout_case_7'):AcceptInput('AddOutput', 'OnCase04 popscript:$CountSlots:77:0:-1')
		ents.FindByName('game_3_payout_case_8'):AcceptInput('AddOutput', 'OnCase04 popscript:$CountSlots:4:0:-1')
		ents.FindByName('game_3_payout_case_9'):AcceptInput('AddOutput', 'OnCase04 popscript:$CountSlots:20:0:-1')
		ents.FindByName('game_4_payout_case'):AcceptInput('AddOutput', 'OnCase01 popscript:$CountBlackjack:0:0:-1')
		ents.FindByName('game_4_payout_case'):AcceptInput('AddOutput', 'OnCase04 popscript:$CountBlackjack:4:0:-1')
		ents.FindByName('game_4_payout_case'):AcceptInput('AddOutput', 'OnCase02 popscript:$CountBlackjack:8:0:-1')
		ents.FindByName('game_4_payout_case'):AcceptInput('AddOutput', 'OnCase05 popscript:$CountBlackjack:8:0:-1')
		ents.FindByName('game_4_payout_case'):AcceptInput('AddOutput', 'OnCase03 popscript:$CountBlackjack:8:0:-1')

		ents.FindByName('game_1_relay_button_red'):AcceptInput('AddOutput', 'OnTrigger tickets_text_counter_buffer:Subtract:8:0:-1')
		ents.FindByName('game_1_relay_button_blue'):AcceptInput('AddOutput', 'OnTrigger tickets_text_counter_buffer:Subtract:8:0:-1')
		ents.FindByName('game_1_relay_button_orange'):AcceptInput('AddOutput', 'OnTrigger tickets_text_counter_buffer:Subtract:16:0:-1')
		ents.FindByName('game_1_relay_button_white'):AcceptInput('AddOutput', 'OnTrigger tickets_text_counter_buffer:Subtract:32:0:-1')
		ents.FindByName('game_2_trigger_1'):AcceptInput('AddOutput', 'OnStartTouch tickets_text_counter_buffer:Subtract:3:0:-1')
		ents.FindByName('game_2_trigger_2'):AcceptInput('AddOutput', 'OnStartTouch tickets_text_counter_buffer:Subtract:1:0:-1')
		ents.FindByName('game_2_trigger_3'):AcceptInput('AddOutput', 'OnStartTouch tickets_text_counter_buffer:Subtract:5:0:-1')
		ents.FindByName('game_2_trigger_5'):AcceptInput('AddOutput', 'OnStartTouch tickets_text_counter_buffer:Subtract:8:0:-1')
		ents.FindByName('game_2_trigger_7'):AcceptInput('AddOutput', 'OnStartTouch tickets_text_counter_buffer:Subtract:5:0:-1')
		ents.FindByName('game_2_trigger_8'):AcceptInput('AddOutput', 'OnStartTouch tickets_text_counter_buffer:Subtract:1:0:-1')
		ents.FindByName('game_2_trigger_9'):AcceptInput('AddOutput', 'OnStartTouch tickets_text_counter_buffer:Subtract:3:0:-1')
		ents.FindByName('game_3_payout_case_1'):AcceptInput('AddOutput', 'OnCase04 tickets_text_counter_buffer:Subtract:100:0:-1')
		ents.FindByName('game_3_payout_case_2'):AcceptInput('AddOutput', 'OnCase04 tickets_text_counter_buffer:Subtract:3:0:-1')
		ents.FindByName('game_3_payout_case_3'):AcceptInput('AddOutput', 'OnCase04 tickets_text_counter_buffer:Subtract:10:0:-1')
		ents.FindByName('game_3_payout_case_4'):AcceptInput('AddOutput', 'OnCase04 tickets_text_counter_buffer:Subtract:10:0:-1')
		ents.FindByName('game_3_payout_case_4'):AcceptInput('AddOutput', 'OnCase03 tickets_text_counter_buffer:Subtract:5:0:-1')
		ents.FindByName('game_3_payout_case_4'):AcceptInput('AddOutput', 'OnCase02 tickets_text_counter_buffer:Subtract:2:0:-1')
		ents.FindByName('game_3_payout_case_5'):AcceptInput('AddOutput', 'OnCase04 tickets_text_counter_buffer:Subtract:50:0:-1')
		ents.FindByName('game_3_payout_case_6'):AcceptInput('AddOutput', 'OnCase04 tickets_text_counter_buffer:Subtract:30:0:-1')
		ents.FindByName('game_3_payout_case_7'):AcceptInput('AddOutput', 'OnCase04 tickets_text_counter_buffer:Subtract:77:0:-1')
		ents.FindByName('game_3_payout_case_8'):AcceptInput('AddOutput', 'OnCase04 tickets_text_counter_buffer:Subtract:4:0:-1')
		ents.FindByName('game_3_payout_case_9'):AcceptInput('AddOutput', 'OnCase04 tickets_text_counter_buffer:Subtract:20:0:-1')
		ents.FindByName('game_4_payout_case'):AcceptInput('AddOutput', 'OnCase01 tickets_text_counter_buffer:Subtract:0:0:-1')
		ents.FindByName('game_4_payout_case'):AcceptInput('AddOutput', 'OnCase04 tickets_text_counter_buffer:Subtract:4:0:-1')
		ents.FindByName('game_4_payout_case'):AcceptInput('AddOutput', 'OnCase02 tickets_text_counter_buffer:Subtract:8:0:-1')
		ents.FindByName('game_4_payout_case'):AcceptInput('AddOutput', 'OnCase05 tickets_text_counter_buffer:Subtract:8:0:-1')
		ents.FindByName('game_4_payout_case'):AcceptInput('AddOutput', 'OnCase03 tickets_text_counter_buffer:Subtract:8:0:-1')

		ents.FindByName('game_1_button_ticket_display'):AcceptInput('AddOutput', 'OnPressed popscript:$CollectRoulette:0:0:-1')
		ents.FindByName('game_2_button_ticket_display'):AcceptInput('AddOutput', 'OnPressed popscript:$CollectPachinko:0:0:-1')
		ents.FindByName('game_3_button_ticket_display'):AcceptInput('AddOutput', 'OnPressed popscript:$CollectSlots:0:0:-1')
		ents.FindByName('game_4_button_ticket_display'):AcceptInput('AddOutput', 'OnPressed popscript:$CollectBlackjack:0:0:-1')
		ents.FindByName('button_ticket_display'):AcceptInput('AddOutput', 'OnPressed popscript:$CollectAll:0:0:-1')
	end)
end

function BetRoulette()
 	for _,ent in pairs(ents.FindAllByName('game_1_counter_credits')) do
		ent:AcceptInput('Add', 1)
	end
	ents.FindByName('game_1_relay_buttons_unlock'):AcceptInput('Enable')
	ents.FindByName('game_1_prop_button_bet'):AcceptInput('SetAnimation', 'press_in')
	ents.FindByName('game_1_relay_buttons_unlock_gate'):AcceptInput('Trigger')
	PlayRoulette()
end

function PlayRoulette()
	RouletteTimer = timer.Simple(RouletteWait, function()
		number = math.random()
		if number <= 2.5/13 then
			ents.FindByName('game_1_button_select_red'):AcceptInput('Press')
		elseif number <= 5/13 then
			ents.FindByName('game_1_button_select_blue'):AcceptInput('Press')
		elseif number <= 9/13 then
			ents.FindByName('game_1_button_select_orange'):AcceptInput('Press')
		elseif number <= 13/13 then
			ents.FindByName('game_1_button_select_white'):AcceptInput('Press')
		end
		timer.Simple(0.1,
		function()
			for _,ent in pairs(ents.FindAllByName('game_1_counter_credits')) do
				ent:AcceptInput('Add', 1)
			end
			ents.FindByName('game_1_relay_buttons_unlock'):AcceptInput('Enable')
			ents.FindByName('game_1_prop_button_bet'):AcceptInput('SetAnimation', 'press_in')
			ents.FindByName('game_1_relay_buttons_unlock_gate'):AcceptInput('Trigger')
	 	end)
	end)
end

function BetPachinko()
	ents.FindByName('game_2_counter_credits'):AcceptInput('Add', 1)
   	ents.FindByName('game_2_prop_button_bet'):AcceptInput('SetAnimation', 'press_in')
  	PlayPachinko()
end

function PlayPachinko()
	PachinkoTimer = timer.Simple(PachinkoWait, function()
		ents.FindByName('game_2_button_launch'):AcceptInput('Press', 1)
	end)
end

function BetSlots()
	ents.FindByName('game_3_counter_credits'):AcceptInput('Add', 1)
   	ents.FindByName('game_3_prop_button_bet'):AcceptInput('SetAnimation', 'press_in')
  	PlaySlots()
end

function PlaySlots()
	SlotsTimer = timer.Simple(SlotsWait, function()
		ents.FindByName('game_3_button_launch'):AcceptInput('Press', 1)
	end)
end

function BetBlackjack()
	ents.FindByName('game_4_counter_credits'):AcceptInput('Add', 1)
   	ents.FindByName('game_4_button_tokens'):AcceptInput('SetAnimation', 'press_in')
  	PlayBlackjack()
end

function PlayBlackjack()
	BlackjackTimer = timer.Simple(BlackjackWait, function()
		ents.FindByName('game_4_cards_relay_stand'):AcceptInput('Trigger', 1)
		ents.FindByName('game_4_prop_button_stand'):AcceptInput('SetAnimation', 'press_once')
	end)
end

function CountRoulette(amount)
	RouletteWinnings = RouletteWinnings + amount
	RouletteWinningsTotal = RouletteWinningsTotal + amount
	ents.FindByName('roulettecollect'):AcceptInput('SetText', 'Chips Collected: ' .. RouletteWinnings .. '\n\nTotal: ' .. RouletteWinningsTotal)
	ents.FindByName('allcollect'):AcceptInput('SetText', 'Roulette.' .. RouletteLevel .. ':        ' .. RouletteWinnings .. '\nPachinko.' .. PachinkoLevel .. ':         ' .. PachinkoWinnings .. '\nSlots.' .. SlotsLevel .. ':            ' .. SlotsWinnings .. '\nBlackjack.' .. BlackjackLevel .. ':       ' .. BlackjackWinnings)
	ents.FindByName('roulettecollect'):PlaySound('ui/training_point_big.wav')
end

function CountPachinko(amount)
	PachinkoWinnings = PachinkoWinnings + amount
	PachinkoWinningsTotal = PachinkoWinningsTotal + amount
	ents.FindByName('pachinkocollect'):AcceptInput('SetText', 'Chips Collected: ' .. PachinkoWinnings .. '\n\nTotal: ' .. PachinkoWinningsTotal)
	ents.FindByName('allcollect'):AcceptInput('SetText', 'Roulette.' .. RouletteLevel .. ':        ' .. RouletteWinnings .. '\nPachinko.' .. PachinkoLevel .. ':         ' .. PachinkoWinnings .. '\nSlots.' .. SlotsLevel .. ':            ' .. SlotsWinnings .. '\nBlackjack.' .. BlackjackLevel .. ':       ' .. BlackjackWinnings)
	ents.FindByName('pachinkocollect'):PlaySound('ui/training_point_big.wav')
end

function CountSlots(amount)
	SlotsWinnings = SlotsWinnings + amount
	SlotsWinningsTotal = SlotsWinningsTotal + amount
	ents.FindByName('slotscollect'):AcceptInput('SetText', 'Chips Collected: ' .. SlotsWinnings .. '\n\nTotal: ' .. SlotsWinningsTotal)
	ents.FindByName('allcollect'):AcceptInput('SetText', 'Roulette.' .. RouletteLevel .. ':        ' .. RouletteWinnings .. '\nPachinko.' .. PachinkoLevel .. ':         ' .. PachinkoWinnings .. '\nSlots.' .. SlotsLevel .. ':            ' .. SlotsWinnings .. '\nBlackjack.' .. BlackjackLevel .. ':       ' .. BlackjackWinnings)
	ents.FindByName('slotscollect'):PlaySound('ui/training_point_big.wav')
end

function CountBlackjack(amount)
	BlackjackWinnings = BlackjackWinnings + amount
	BlackjackWinningsTotal = BlackjackWinningsTotal + amount
	ents.FindByName('blackjackcollect'):AcceptInput('SetText', 'Chips Collected: ' .. BlackjackWinnings .. '\n\nTotal: ' .. BlackjackWinningsTotal)
	ents.FindByName('allcollect'):AcceptInput('SetText', 'Roulette.' .. RouletteLevel .. ':        ' .. RouletteWinnings .. '\nPachinko.' .. PachinkoLevel .. ':         ' .. PachinkoWinnings .. '\nSlots.' .. SlotsLevel .. ':            ' .. SlotsWinnings .. '\nBlackjack.' .. BlackjackLevel .. ':       ' .. BlackjackWinnings)
	ents.FindByName('blackjackcollect'):PlaySound('ui/training_point_big.wav')
end

function OnWaveStart(wave)
	WaveSetup = false
	ents.FindByName('trigger_chips_set_spawner'):AcceptInput('Disable')
	if RouletteLevel > 0 then
		ents.FindByName('game_1_door_button_blocker'):AcceptInput('Open')
	end
	if PachinkoLevel > 0 then
		ents.FindByName('game_2_door_button_blocker'):AcceptInput('Disable')
	end
	if SlotsLevel > 0 then
		ents.FindByName('game_3_door_button_blocker'):AcceptInput('Disable')
	end
	if BlackjackLevel > 0 then
		ents.FindByName('game_4_door_button_blocker'):AcceptInput('Disable')
	end
	timer.Stop(RouletteTimer)
	timer.Stop(PachinkoTimer)
	timer.Stop(SlotsTimer)
	timer.Stop(BlackjackTimer)
	timer.Simple(0.1,function() PlayRoulette() PlayPachinko() PlaySlots() PlayBlackjack() end)
	timer.Simple(0.1, function() ents.FindByName('games_open_relay'):AcceptInput('Trigger') end)
	RouletteWait = RouletteUpgrade[RouletteLevel]
	PachinkoWait = PachinkoUpgrade[PachinkoLevel]
	SlotsWait = SlotsUpgrade[SlotsLevel]
	BlackjackWait = BlackjackUpgrade[BlackjackLevel]

	for _,ent in pairs(ents.FindAllByName('coretext*')) do
		ent:AcceptInput('SetText', '')
	end

	if MercBotCount > 0 then
		timer.Create(1, function()
			if MercBotQueue[1] == "common" then
				ents.FindByName('spawnbot_mercbot'):AcceptInput('Enable')
				timer.Simple(0.2, function() ents.FindByName('spawnbot_mercbot'):AcceptInput('Disable') end)
			elseif MercBotQueue[1] == "crit" then
				ents.FindByName('spawnbot_mercbotcrit'):AcceptInput('Enable')
				timer.Simple(0.2, function() ents.FindByName('spawnbot_mercbotcrit'):AcceptInput('Disable') end)
			elseif MercBotQueue[1] == "giant" then
				ents.FindByName('spawnbot_mercbotgiant'):AcceptInput('Enable')
				timer.Simple(0.2, function() ents.FindByName('spawnbot_mercbotgiant'):AcceptInput('Disable') end)
			elseif MercBotQueue[1] == "giantcrit" then
				ents.FindByName('spawnbot_mercbotgiantcrit'):AcceptInput('Enable')
				timer.Simple(0.2, function() ents.FindByName('spawnbot_mercbotgiantcrit'):AcceptInput('Disable') end)
			end
			MercBotQueue[1] = MercBotQueue[2]
			MercBotQueue[2] = MercBotQueue[3]
			MercBotQueue[3] = MercBotQueue[4]
		end, MercBotCount)
	end
end

function UpgradeBot(game,player)
	function KillCore()
		FlagTable[player.Core]:AcceptInput("Kill")
		player.Core = 0
		player.m_bGlowEnabled = 0
		player:RemoveCond(32)
		player:AddCond(32, 10)
		timer.Stop(player.TrailTimer)
		if player:GetPlayerItemBySlot(2):GetItemName() == 'The Pain Train' then
			player:GetPlayerItemBySlot(2):SetAttributeValue('add attributes when active', nil)
			player:GetPlayerItemBySlot(2):SetAttributeValue('mod_maxhealth_drain_rate', nil)
			player:GetPlayerItemBySlot(2):SetAttributeValue('self mark for death', nil)
		end
	end
	function UpgradeText(game, user, level)
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('weapons/sentry_finish.wav')
			player:ShowHudText({
				channel = 0,
				x = 0.889,
				y = 0.38,
				r1 = 231,
				g1 = 181,
				b1 = 59,
				r2 = 103,
				g2 = 255,
				b2 = 37,
				fadeinTime = 0,
				fadeoutTime = 0,
				holdTime = 3},
				user:DumpProperties().m_szNetname[1].. ' upgraded ' .. game .. ' to Level ' .. level
			)
		end
	end
	if game == 'roulette' and RouletteLevel < 3 then
		RouletteLevel = RouletteLevel + 1
		ents.FindByName('game_1_timer'):AcceptInput('UpperRandomBound', 10-(RouletteLevel-1)*2.5)
		ents.FindByName('game_1_timer'):AcceptInput('LowerRandomBound', 7-(RouletteLevel-1)*2.5)
		ents.FindByName('rouletteleveltext'):AcceptInput('SetText', 'Level '..RouletteLevel)
		ents.FindByName('rouletteleveltext2'):AcceptInput('SetText', 'Level '..RouletteLevel)
		if RouletteLevel == 3 then
			ents.FindByName('rouletteleveltext'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('rouletteleveltext2'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('roulettetarget'):AcceptInput('$TeleportToEntity', 'spawnbot_chips')
		end
		ents.FindByName('roulettebot'):SetFakeClientConVar("name", "Automatic Gambler Level " .. RouletteLevel)
		if WaveSetup == false then
			RouletteWait = RouletteUpgrade[RouletteLevel]
			if RouletteLevel == 1 then
				timer.Stop(RouletteTimer)
				PlayRoulette()
			end
		end
		KillCore()
		UpgradeText('Roulette', player, RouletteLevel)
	elseif game == 'pachinko' and PachinkoLevel < 3 then
		PachinkoLevel = PachinkoLevel + 1
		ents.FindByName('pachinkoleveltext'):AcceptInput('SetText', 'Level '..PachinkoLevel)
		ents.FindByName('pachinkoleveltext2'):AcceptInput('SetText', 'Level '..PachinkoLevel)
		if PachinkoLevel == 3 then
			ents.FindByName('pachinkoleveltext'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('pachinkoleveltext2'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('pachinkotarget'):AcceptInput('$TeleportToEntity', 'spawnbot_chips')
		end
		ents.FindByName('pachinkobot'):SetFakeClientConVar("name", "Automatic Gambler Level " .. PachinkoLevel)
		if WaveSetup == false then
			PachinkoWait = PachinkoUpgrade[PachinkoLevel]
			if PachinkoLevel == 1 then
				timer.Stop(PachinkoTimer)
				ents.FindByName('game_2_button_launch'):AcceptInput('Press', 1)
			end
		end
		KillCore()
		UpgradeText('Pachinko', player, PachinkoLevel)
	elseif game == 'slots' and SlotsLevel < 3 then
		SlotsLevel = SlotsLevel + 1
		ents.FindByName('slotsleveltext'):AcceptInput('SetText', 'Level '..SlotsLevel)
		ents.FindByName('slotsleveltext2'):AcceptInput('SetText', 'Level '..SlotsLevel)
		if SlotsLevel == 3 then
			ents.FindByName('slotsleveltext'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('slotsleveltext2'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('slotstarget'):AcceptInput('$TeleportToEntity', 'spawnbot_chips')
		end
		ents.FindByName('slotsbot'):SetFakeClientConVar("name", "Automatic Gambler Level " .. SlotsLevel)
		ents.FindByName('game_3_slot_motor_1'):AcceptInput('AddOutput', 'speed ' .. 720+315*(SlotsLevel-1))
		ents.FindByName('game_3_slot_motor_2'):AcceptInput('AddOutput', 'speed ' .. 720+315*(SlotsLevel-1))
		ents.FindByName('game_3_slot_motor_3'):AcceptInput('AddOutput', 'speed ' .. 720+315*(SlotsLevel-1))
		if WaveSetup == false then
			SlotsWait = SlotsUpgrade[SlotsLevel]
			if SlotsLevel == 1 then
				timer.Stop(SlotsTimer)
				ents.FindByName('game_3_button_launch'):AcceptInput('Press', 1)
			end
		end
		KillCore()
		UpgradeText('Slots', player, SlotsLevel)
	elseif game == 'blackjack' and BlackjackLevel < 3 then
		BlackjackLevel = BlackjackLevel + 1
		ents.FindByName('blackjackleveltext'):AcceptInput('SetText', 'Level '..BlackjackLevel)
		ents.FindByName('blackjackleveltext2'):AcceptInput('SetText', 'Level '..BlackjackLevel)
		if BlackjackLevel == 3 then
			ents.FindByName('blackjackleveltext'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('blackjackleveltext2'):AcceptInput('SetColor', '255 0 0')
			ents.FindByName('blackjacktarget'):AcceptInput('$TeleportToEntity', 'spawnbot_chips')
		end
		ents.FindByName('blackjackbot'):SetFakeClientConVar("name", "Automatic Gambler Level " .. BlackjackLevel)
		if WaveSetup == false then
			BlackjackWait = BlackjackUpgrade[BlackjackLevel]
			if BlackjackLevel == 1 then
				timer.Stop(BlackjackTimer)
				ents.FindByName('game_4_cards_relay_stand'):AcceptInput('Trigger', 1)
				ents.FindByName('game_4_prop_button_stand'):AcceptInput('SetAnimation', 'press_once')
			end
		end
		KillCore()
		UpgradeText('Blackjack', player, BlackjackLevel)
	else
		player:Print(2,'Max level reached!')
	end
end

function CollectRoulette(_, user)
	if RouletteWinnings > 0 then
		TicketsOwned = TicketsOwned + RouletteWinnings
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('ui/scored.wav')
			player:ShowHudText({
				channel = 0,
				x = 0.889,
				y = 0.38,
				r1 = 230,
				g1 = 194,
				b1 = 89,
				r2 = 203,
				g2 = 179,
				b2 = 37,
				fadeinTime = 0,
				fadeoutTime = 0,
				holdTime = 3},
				user:DumpProperties().m_szNetname[1].. ' +' .. RouletteWinnings .. ' Chips from Roulette'
			)
		end
		ents.FindByName('tickets_text_counter_buffer'):AcceptInput('Add', RouletteWinnings)
		RouletteWinnings = 0
		ents.FindByName('roulettecollect'):AcceptInput('SetText', 'Chips Collected: '.. RouletteWinnings .. '\n\nTotal: ' .. RouletteWinningsTotal)
		ents.FindByName('allcollect'):AcceptInput('SetText', 'Roulette.' .. RouletteLevel .. ':      ' .. RouletteWinnings .. '\nPachinko.' .. PachinkoLevel .. ':       ' .. PachinkoWinnings .. '\nSlots.' .. SlotsLevel .. ':          ' .. SlotsWinnings .. '\nBlackjack.' .. BlackjackLevel .. ':     ' .. BlackjackWinnings)
	end
end

function CollectPachinko(_, user)
	if PachinkoWinnings > 0 then
		TicketsOwned = TicketsOwned + PachinkoWinnings
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('ui/scored.wav')
			player:ShowHudText({
				channel = 0,
				x = 0.889,
				y = 0.38,
				r1 = 230,
				g1 = 194,
				b1 = 89,
				r2 = 203,
				g2 = 179,
				b2 = 37,
				fadeinTime = 0,
				fadeoutTime = 0,
				holdTime = 3},
				user:DumpProperties().m_szNetname[1].. ' +' .. PachinkoWinnings .. ' Chips from Pachinko'
			)
		end
		ents.FindByName('tickets_text_counter_buffer'):AcceptInput('Add', PachinkoWinnings)
		PachinkoWinnings = 0
		ents.FindByName('pachinkocollect'):AcceptInput('SetText', 'Chips Collected: '.. PachinkoWinnings .. '\n\nTotal: ' .. PachinkoWinningsTotal)
		ents.FindByName('allcollect'):AcceptInput('SetText', 'Roulette.' .. RouletteLevel .. ':      ' .. RouletteWinnings .. '\nPachinko.' .. PachinkoLevel .. ':       ' .. PachinkoWinnings .. '\nSlots.' .. SlotsLevel .. ':          ' .. SlotsWinnings .. '\nBlackjack.' .. BlackjackLevel .. ':     ' .. BlackjackWinnings)
	end
end

function CollectSlots(_, user)
	if SlotsWinnings > 0 then
		TicketsOwned = TicketsOwned + SlotsWinnings
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('ui/scored.wav')
			player:ShowHudText({
				channel = 0,
				x = 0.889,
				y = 0.38,
				r1 = 230,
				g1 = 194,
				b1 = 89,
				r2 = 203,
				g2 = 179,
				b2 = 37,
				fadeinTime = 0,
				fadeoutTime = 0,
				holdTime = 3},
				user:DumpProperties().m_szNetname[1].. ' +' .. SlotsWinnings .. ' Chips from Slots'
			)
		end
		ents.FindByName('tickets_text_counter_buffer'):AcceptInput('Add', SlotsWinnings)
		SlotsWinnings = 0
		ents.FindByName('slotscollect'):AcceptInput('SetText', 'Chips Collected: '.. SlotsWinnings .. '\n\nTotal: ' .. SlotsWinningsTotal)
		ents.FindByName('allcollect'):AcceptInput('SetText', 'Roulette.' .. RouletteLevel .. ':      ' .. RouletteWinnings .. '\nPachinko.' .. PachinkoLevel .. ':       ' .. PachinkoWinnings .. '\nSlots.' .. SlotsLevel .. ':          ' .. SlotsWinnings .. '\nBlackjack.' .. BlackjackLevel .. ':     ' .. BlackjackWinnings)
	end
end

function CollectBlackjack(_, user)
	if BlackjackWinnings > 0 then
		TicketsOwned = TicketsOwned + BlackjackWinnings
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('ui/scored.wav')
			player:ShowHudText({
				channel = 0,
				x = 0.889,
				y = 0.38,
				r1 = 230,
				g1 = 194,
				b1 = 89,
				r2 = 203,
				g2 = 179,
				b2 = 37,
				fadeinTime = 0,
				fadeoutTime = 0,
				holdTime = 3},
				user:DumpProperties().m_szNetname[1].. ' +' .. BlackjackWinnings .. ' Chips from Blackjack'
			)
		end
		ents.FindByName('tickets_text_counter_buffer'):AcceptInput('Add', BlackjackWinnings)
		BlackjackWinnings = 0
		ents.FindByName('blackjackcollect'):AcceptInput('SetText', 'Chips Collected: '.. BlackjackWinnings .. '\n\nTotal: ' .. BlackjackWinningsTotal)
		ents.FindByName('allcollect'):AcceptInput('SetText', 'Roulette.' .. RouletteLevel .. ':      ' .. RouletteWinnings .. '\nPachinko.' .. PachinkoLevel .. ':       ' .. PachinkoWinnings .. '\nSlots.' .. SlotsLevel .. ':          ' .. SlotsWinnings .. '\nBlackjack.' .. BlackjackLevel .. ':     ' .. BlackjackWinnings)
	end
end

function CollectAll(_, user)
	local AllWinnings = RouletteWinnings + PachinkoWinnings + SlotsWinnings + BlackjackWinnings
	if AllWinnings > 0 then
		TicketsOwned = TicketsOwned + AllWinnings
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('ui/scored.wav')
			player:ShowHudText({
				channel = 0,
				x = 0.889,
				y = 0.38,
				r1 = 230,
				g1 = 194,
				b1 = 89,
				r2 = 203,
				g2 = 179,
				b2 = 37,
				fadeinTime = 0,
				fadeoutTime = 0,
				holdTime = 3},
				user:DumpProperties().m_szNetname[1].. ' +' .. AllWinnings .. ' Chips from all games'
			)
		end
		ents.FindByName('tickets_text_counter_buffer'):AcceptInput('Add', AllWinnings)
		RouletteWinnings = 0
		PachinkoWinnings = 0
		SlotsWinnings = 0
		BlackjackWinnings = 0
		ents.FindByName('roulettecollect'):AcceptInput('SetText', 'Chips Collected: '.. RouletteWinnings .. '\n\nTotal: ' .. RouletteWinningsTotal)
		ents.FindByName('pachinkocollect'):AcceptInput('SetText', 'Chips Collected: '.. PachinkoWinnings .. '\n\nTotal: ' .. PachinkoWinningsTotal)
		ents.FindByName('slotscollect'):AcceptInput('SetText', 'Chips Collected: '.. SlotsWinnings .. '\n\nTotal: ' .. SlotsWinningsTotal)
		ents.FindByName('blackjackcollect'):AcceptInput('SetText', 'Chips Collected: '.. BlackjackWinnings .. '\n\nTotal: ' .. BlackjackWinningsTotal)
		ents.FindByName('allcollect'):AcceptInput('SetText', 'Roulette.' .. RouletteLevel .. ':      ' .. RouletteWinnings .. '\nPachinko.' .. PachinkoLevel .. ':       ' .. PachinkoWinnings .. '\nSlots.' .. SlotsLevel .. ':          ' .. SlotsWinnings .. '\nBlackjack.' .. BlackjackLevel .. ':     ' .. BlackjackWinnings)
	end
end

function Cashout1(_,user)
	if TicketsOwned >= 1 then
		SpentChips = SpentChips + 1
		TicketsOwned = TicketsOwned - 1
		CashedOut = CashedOut + 1
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('ui/cyoa_node_deactivate.wav')
		end
		ents.FindByName('tickets_text_counter_buffer'):AcceptInput('Subtract', 1)
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('mvm/mvm_bought_upgrade.wav')
			player:AddCurrency(1)
			player:ShowHudText({
				channel = 0,
				x = 0.889,
				y = 0.38,
				r1 = 130,
				g1 = 254,
				b1 = 89,
				r2 = 103,
				g2 = 255,
				b2 = 37,
				fadeinTime = 0,
				fadeoutTime = 0,
				holdTime = 3},
				user:DumpProperties().m_szNetname[1].. ' cashed out $1!'
			)
		end
		ents.FindByName('cashouttext2'):AcceptInput('SetText', "Total: $" .. CashedOut)
	else
		ents.FindByName('prize_not_enough_tickets'):AcceptInput('Trigger')
		user:PlaySoundToSelf('replay/cameracontrolerror.wav')
	end
end

function Cashout10(_,user)
	if TicketsOwned >= 10 then
		SpentChips = SpentChips + 10
		TicketsOwned = TicketsOwned - 10
		CashedOut = CashedOut + 10
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('ui/cyoa_node_deactivate.wav')
		end
		ents.FindByName('tickets_text_counter_buffer'):AcceptInput('Subtract', 10)
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('mvm/mvm_bought_upgrade.wav')
			player:AddCurrency(10)
			player:ShowHudText({
				channel = 0,
				x = 0.889,
				y = 0.38,
				r1 = 130,
				g1 = 254,
				b1 = 89,
				r2 = 103,
				g2 = 255,
				b2 = 37,
				fadeinTime = 0,
				fadeoutTime = 0,
				holdTime = 3},
				user:DumpProperties().m_szNetname[1].. ' cashed out $10!'
			)
		end
		ents.FindByName('cashouttext2'):AcceptInput('SetText', "Total: $" .. CashedOut)
	else
		ents.FindByName('prize_not_enough_tickets'):AcceptInput('Trigger')
		user:PlaySoundToSelf('replay/cameracontrolerror.wav')
	end
end

function Cashout100(_,user)
	if TicketsOwned >= 100 then
		SpentChips = SpentChips + 100
		TicketsOwned = TicketsOwned - 100
		CashedOut = CashedOut + 100
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('ui/cyoa_node_deactivate.wav')
		end
		ents.FindByName('tickets_text_counter_buffer'):AcceptInput('Subtract', 100)
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('mvm/mvm_bought_upgrade.wav')
			player:AddCurrency(100)
			player:ShowHudText({
				channel = 0,
				x = 0.889,
				y = 0.38,
				r1 = 130,
				g1 = 254,
				b1 = 89,
				r2 = 103,
				g2 = 255,
				b2 = 37,
				fadeinTime = 0,
				fadeoutTime = 0,
				holdTime = 3},
				user:DumpProperties().m_szNetname[1].. ' cashed out $100!'
			)
		end
		ents.FindByName('cashouttext2'):AcceptInput('SetText', "Total: $" .. CashedOut)
	else
		ents.FindByName('prize_not_enough_tickets'):AcceptInput('Trigger')
		user:PlaySoundToSelf('replay/cameracontrolerror.wav')
	end
end

function Spend(number)
	TicketsOwned = TicketsOwned - number
	for _, player in pairs(ents.GetAllPlayers()) do
		player:PlaySoundToSelf('ui/cyoa_node_deactivate.wav')
	end
	SpentChips = SpentChips + number
end

function SpendText(prize,user)
	for _, player in pairs(ents.GetAllPlayers()) do
		player:PlaySoundToSelf('mvm/mvm_bought_upgrade.wav')
		player:ShowHudText({
			channel = 0,
			x = 0.889,
			y = 0.38,
			r1 = 255,
			g1 = 54,
			b1 = 189,
			r2 = 103,
			g2 = 255,
			b2 = 37,
			fadeinTime = 0,
			fadeoutTime = 0,
			holdTime = 3},
			user:DumpProperties().m_szNetname[1].. ' bought the ' .. prize
		)
	end
	if prize == "Special Prize!" then
		SpecialPrize = true
		SpawnSecret()
	elseif prize == "EMP!" then
		EMPBought = true
		timer.Simple(0.1, function() ents.FindByName("prize_7_nuke_button"):AcceptInput('AddOutput', 'OnPressed popscript:$Used:emp:0:-1') end)
		if WaveSetup == true then
			timer.Simple(0.1, function() ents.FindByName("prize_7_nuke_button"):AcceptInput('Lock') end)
		end
	elseif prize == "Nuke!" then
		NukeBought = true
		timer.Simple(0.1, function() ents.FindByName("prize_5_nuke_button"):AcceptInput('AddOutput', 'OnPressed popscript:$Used:nuke:0:-1') end)
		if WaveSetup == true then
			timer.Simple(0.1, function() ents.FindByName("prize_5_nuke_button"):AcceptInput('Lock') end)
		end
	elseif prize == "Helicopter!" then
		HeliBought = true
	elseif prize == "Hatch Shield!" then
		ShieldBought = true
		timer.Simple(0.1, function()
			ents.FindByName("prize_reset_relay_2"):AcceptInput('AddOutput', 'OnTrigger popscript:$Used:shield:0:-1')
			for _,ent in pairs(ents.FindAllByName('prize_2_hatchshield_counter')) do
				ent:AcceptInput('AddOutput', 'OutValue popscript:$Used::0:-1')
			end
		end)
	end
end

function SpawnCore(param,activator,caller)
	local CoreSpawned = {}
	if activator:IsRealPlayer() and activator.Core == 0 and activator:InCond(2) == false and activator:InCond(3) == false and activator:InCond(4) == false then
			CoreSpawned = ents.SpawnTemplate('CoreFlagPickup', {translation = caller:GetAbsOrigin()})
			CoreSpawned[3].m_nSkin = 2
		if WaveSetup == true then
			activator.m_hItem = CoreSpawned[3]

			CoreSpawned[3].moveparent = activator
			CoreSpawned[3].m_bClientSideAnimation = 0
			CoreSpawned[3].m_iParentAttachment = FlagAttachments[activator.m_iClass].bone
			CoreSpawned[3]:SetLocalOrigin(Vector(0,0,0))
			CoreSpawned[3]:SetLocalAngles(Vector(0,0,0))

			HoldCore(_,activator,CoreSpawned[3])
		end
		if param == 'leftover' then
			timer.Simple(0.015, function() Entity(caller:GetNetIndex()-3):AcceptInput('Enable') end)
			timer.Simple(0.03, function() caller:AcceptInput('Kill') end)
		else
			caller:AcceptInput('Kill')
		end
	end
end

function SpawnCoreProp(_,activator,caller)
	ents.SpawnTemplate('CoreFlagProp', {translation = caller:GetAbsOrigin()})
end

function HoldCore(_,player,flag)
	if player:IsRealPlayer() == true then
		player.Core = string.match(flag:GetName(), "%d+")
		FlagTable[player.Core] = flag
		timer.Simple(0.1, function ()
			if IsValid(flag) then
				player.Core = string.match(flag:GetName(), "%d+")
				FlagTable[player.Core] = flag
			end
		end)
		player:Print(2,'Take the Australium core to a game machine!')
		if player:GetPlayerItemBySlot(2):GetItemName() == 'The Pain Train' then
			player:GetPlayerItemBySlot(2):SetAttributeValue('add attributes when active', 'move speed bonus|3|increased air control|4')
			player:GetPlayerItemBySlot(2):SetAttributeValue('deploy time decreased', -1)
			if player.ActiveWeapon == 'tf_weapon_rocketlauncher'
			or player.ActiveWeapon == 'tf_weapon_rocketlauncher_directhit'
			or player.ActiveWeapon == 'tf_weapon_particle_cannon'
			or player.ActiveWeapon == 'tf_weapon_grenadelauncher'
			or player.ActiveWeapon == 'tf_weapon_cannon' then
				player:WeaponSwitchSlot(2)
				player:WeaponSwitchSlot(0)
			elseif player.ActiveWeapon == 'tf_weapon_shotgun_soldier'
			or player.ActiveWeapon == 'tf_weapon_shotgun'
			or player.ActiveWeapon == 'tf_weapon_buff_item'
			or player.ActiveWeapon == 'tf_weapon_raygun'
			or player.ActiveWeapon == 'tf_weapon_pipebomblauncher' then
				player:WeaponSwitchSlot(2)
				player:WeaponSwitchSlot(1)
			end
			player:GetPlayerItemBySlot(2):SetAttributeValue('deploy time decreased', nil)
			player:GetPlayerItemBySlot(2):SetAttributeValue('mod_maxhealth_drain_rate', 1)
			player:GetPlayerItemBySlot(2):SetAttributeValue('self mark for death', 1)
		end
		player:AddCond(32)
		if WaveSetup == true then
			--player:AcceptInput('RunScriptFile', 'autonavtrail')
--[[ 			for _,ent in pairs(ents.FindAllByName('trail_cpoint' .. player:GetNetIndex() .. '*')) do
				ent:AcceptInput('$HideToAll', player)
				ent:AcceptInput('$ShowTo', player)
			end ]]
		end

		player.TrailTimer = timer.Create(1, function()
			if WaveSetup == true then
				--player:AcceptInput('RunScriptFile', 'autonavtrail')
--[[ 				for _,ent in pairs(ents.FindAllByName('trail_cpoint' .. player:GetNetIndex() .. '*')) do
					ent:AcceptInput('$HideToAll', player)
					ent:AcceptInput('$ShowTo', player)
				end ]]
			end
		end, 0)
	end
end

function DropCore(_,player,flag)
	if player:IsRealPlayer() == true then
		timer.Simple(3, function() player.Core = 0 end)
		player:RemoveCond(32)
		if player:GetPlayerItemBySlot(2):GetItemName() == 'The Pain Train' then
			player:GetPlayerItemBySlot(2):SetAttributeValue('add attributes when active', nil)
			player:GetPlayerItemBySlot(2):SetAttributeValue('mod_maxhealth_drain_rate', nil)
			player:GetPlayerItemBySlot(2):SetAttributeValue('self mark for death', nil)
		end
		timer.Stop(player.TrailTimer)
	end
end

function SpawnMerc(robot,user)
	local price = 0
	if robot == "common" then
		price = 5
	elseif robot == "crit" then
		price = 50
	elseif robot == "giant" then
		price = 100
	elseif robot == "giantcrit" then
		price = 150
	end
	if MercBotCount < 4 then
		if TicketsOwned >= price then
			MercBotCount = MercBotCount + 1
			TicketsOwned = TicketsOwned - price
			SpentChips = SpentChips + price
			ents.FindByName('mercbottext2'):AcceptInput('SetText', "Max (".. MercBotCount .."/4)")
			for _, player in pairs(ents.GetAllPlayers()) do
				player:PlaySoundToSelf('ui/cyoa_node_deactivate.wav')
			end
			if WaveSetup == false then
				if robot == "common" then
					ents.FindByName('spawnbot_mercbot'):AcceptInput('Enable')
					timer.Simple(0.2, function() ents.FindByName('spawnbot_mercbot'):AcceptInput('Disable') end)
				elseif robot == "crit" then
					ents.FindByName('spawnbot_mercbotcrit'):AcceptInput('Enable')
					timer.Simple(0.2, function() ents.FindByName('spawnbot_mercbotcrit'):AcceptInput('Disable') end)
				elseif robot == "giant" then
					ents.FindByName('spawnbot_mercbotgiant'):AcceptInput('Enable')
					timer.Simple(0.2, function() ents.FindByName('spawnbot_mercbotgiant'):AcceptInput('Disable') end)
				elseif robot == "giantcrit" then
					ents.FindByName('spawnbot_mercbotgiantcrit'):AcceptInput('Enable')
					timer.Simple(0.2, function() ents.FindByName('spawnbot_mercbotgiantcrit'):AcceptInput('Disable') end)
				end
			else
				MercBotQueue[MercBotCount] = robot
			end
			local text = ''
			if robot == "common" then
				text = 'Common'
			elseif robot == "crit" then
				text = 'Crit'
			elseif robot == "giant" then
				text = 'Giant'
			elseif robot == "giantcrit" then
				text = 'Giant Crit'
			end
			ents.FindByName('tickets_text_counter_buffer'):AcceptInput('Subtract', price)
			for _, player in pairs(ents.GetAllPlayers()) do
				player:PlaySoundToSelf('mvm/mvm_bought_upgrade.wav')
				player:ShowHudText({
					channel = 0,
					x = 0.889,
					y = 0.38,
					r1 = 255,
					g1 = 56,
					b1 = 59,
					r2 = 103,
					g2 = 255,
					b2 = 37,
					fadeinTime = 0,
					fadeoutTime = 0,
					holdTime = 3},
					user:DumpProperties().m_szNetname[1].. ' hired a ' .. text .. ' Robot!'
				)
			end
		else
			ents.FindByName('prize_not_enough_tickets'):AcceptInput('Trigger')
			user:PlaySoundToSelf('replay/cameracontrolerror.wav')
		end
	else
		user:Print(2,'Max robot limit reached!')
		user:PlaySoundToSelf('replay/cameracontrolerror.wav')
	end
end

function OnWaveSpawnBot(bot, wave, tags)
	if tags[1] == 'mercbot' then
		if bot.m_iClass ~= 6 then
			bot.SpawnBoost = true
			bot:SetAttributeValue('CARD: move speed bonus', 30)
			bot:AddCond(32)
		end
		bot:AddCond(6, 18) --non functional
		bot:AddCond(5, 5)
		bot:AddCallback(ON_DEATH, function()
			if bot.m_iTeamNum == 2 then
				MercBotCount = MercBotCount - 1
				ents.FindByName('mercbottext2'):AcceptInput('SetText', "Max (".. MercBotCount .."/4)")
				bot:RemoveAllCallbacks()
			end end)
		bot:AddCallback(ON_KEY_PRESSED, function(ent, key) if ent.SpawnBoost == true and key == 1 then ent.SpawnBoost = false bot:SetAttributeValue('CARD: move speed bonus', nil) ent:RemoveCond(32) end end)
		util.ParticleEffect("teleportedin_red", bot:GetAbsOrigin())
		util.ParticleEffect("teleported_red", bot:GetAbsOrigin())
		util.ParticleEffect("player_recent_teleport_red", bot:GetAbsOrigin(),_,bot)
		bot:PlaySound('weapons/teleporter_send.wav')
		ents.SpawnTemplate('RedBotParticle', {parent = bot})
	end

	if tags[1] == 'chief' then
		SummonHP = 0
		SummonCount = 0
		ActivateSecret()
		SpawnSecret()
		local giantrolled = false

		timer.Simple(17, function()
			bot:WeaponStripSlot(1)
			bot:RemoveCond(26)
			util.ParticleEffect("drg_wrenchmotron_teleport", bot:GetAbsOrigin())
			bot:PlaySound('ambient_mp3/halloween/thunder_04.mp3')
			bot:PlaySound('physics/wood/wood_plank_break2.wav')
			ents.SpawnTemplate('ChiefAnimation', {translation = bot:GetAbsOrigin()})
		end)
		function DrawCard()
			local number = 0
			local suitrandom = math.random(4)
			local suit = ""
			local suittext = ""
			local numbertext = ""

			if giantrolled == false then
				number = math.random(11,14)
				giantrolled = true
			else
				number = math.random(1,10)
				giantrolled = false
			end

			if suitrandom == 1 then
				suit = "spades"
				suittext = "Spades"
			elseif suitrandom == 2 then
				suit = "clubs"
				suittext = "Clubs"
			elseif suitrandom == 3 then
				suit = "diamonds"
				suittext = "Diamonds"
			elseif suitrandom == 4 then
				suit = "hearts"
				suittext = "Hearts"
			end

			if number == 1 then
				numbertext = "Ace"
			elseif number == 2 then
				numbertext = "Two"
			elseif number == 3 then
				numbertext = "Three"
			elseif number == 4 then
				numbertext = "Four"
			elseif number == 5 then
				numbertext = "Five"
			elseif number == 6 then
				numbertext = "Six"
			elseif number == 7 then
				numbertext = "Seven"
			elseif number == 8 then
				numbertext = "Eight"
			elseif number == 9 then
				numbertext = "Nine"
			elseif number == 10 then
				numbertext = "Ten"
			elseif number == 11 then
				numbertext = "Jack"
			elseif number == 12 then
				numbertext = "Queen"
			elseif number == 13 then
				numbertext = "King"
			elseif number == 14 then
				numbertext = "Ace"
				number = 1
			end

			ents.FindByName(suit):AcceptInput('Enable')
			ents.FindByName(suit):AcceptInput('$SetLocalAngles', '180 0 0')
			ents.FindByName(suit):AcceptInput('AddOutput', 'skin ' .. number)
			timer.Simple(1, function() ents.FindByName('card_rotate'):AcceptInput('Open') end)
			timer.Simple(2, function() util.PrintToChatAll("\x0799CCFFCaptain Jackpot\x07fbeccb has drawn: \x07FFD700" .. numbertext .."\x07FFD700 of ".. suittext) end)
			timer.Simple(1.8, function() ents.FindByName('card_'..number):Teleport(bot:GetAbsOrigin()) end)
			timer.Simple(2, function() 
				ents.FindByName('card_'..number):AcceptInput('Enable')
				util.ParticleEffect("teleportedin_blue", bot:GetAbsOrigin())
				util.ParticleEffect("teleported_blue", bot:GetAbsOrigin())
				bot:PlaySound('weapons/teleporter_send.wav')
			 end)
			timer.Simple(3, function() ents.FindByName('card_'..number):AcceptInput('Disable') end)
			timer.Simple(4, function() ents.FindByName(suit):AcceptInput('Disable') end)
			timer.Simple(4, function() ents.FindByName('card_rotate'):AcceptInput('Close') end)

			return number, suit
		end

		timer.Create(11, function()
			local suit1 = ""
			local suit2 = ""
			local number1 = -1
			local number2 = -2
			if SummonHP <= 3000 and SummonCount <= 8 then
				suit1, number1 = DrawCard()
			end
--[[ 			if bot.m_iHealth < 20000 then
				suit2, number2 = timer.Simple(0.3, DrawCard())
			end
			if number1 == number2 then
				timer.Simple(2.3, function() util.PrintToChatAll("\x0799CCFFTwo of a kind! \x0700FFFFCritical Draw!")
					for _, player in pairs(ents.GetAllPlayers()) do
						if player.m_iTeamNum == 3 then
							if number2 == 1 then
								player:AddCond(56, 10)
							else
								player:AddCond(56, math.min(number2, 10))
							end
						end
					end
				end)
			end
			if number1 == number2 and suit1 == suit2 then
				timer.Simple(2.3, function() util.PrintToChatAll("\x0799CCFFTwo of a kind? \x07FFD700Cheater's Lament!")
					for _, player in pairs(ents.GetAllPlayers()) do
						if player.m_iTeamNum == 2 then
							player:AddCond(56, 10)
						end
					end
				end)
			end ]]
		end, 0)
	end

	if tags[1] == 'summon' then
		if tonumber(tags[2]) == nil then
			SummonHP = SummonHP + bot.m_iMaxHealth
		else
			SummonHP = SummonHP + tonumber(tags[2])
		end
		SummonCount = SummonCount + 1
		bot:AddCallback(ON_DEATH, function()
			if tonumber(tags[2]) == nil then
				SummonHP = SummonHP - bot.m_iMaxHealth
			else
				SummonHP = SummonHP - tonumber(tags[2])
			end
			SummonCount = SummonCount - 1
			bot:RemoveAllCallbacks()
			end)
	end
end

function BuyDispenser(_,player)
	if TicketsOwned >= 15 then
		TicketsOwned = TicketsOwned - 15
		SpentChips = SpentChips + 15
		DispenserBought = true
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('ui/cyoa_node_deactivate.wav')
		end
		SpendText('Dispenser Backpack!', player)
		ents.FindByName('tickets_text_counter_buffer'):AcceptInput('Subtract', 15)
		timer.Simple(0.5, function() ents.FindByName('dispenser_prop_button'):AcceptInput('Kill') end)
		ents.FindByName('dispenser_button'):AcceptInput('Kill')
		ents.FindByName('dispensertext'):AcceptInput('Kill')
		--ents.FindByName('dispensertext2'):AcceptInput('Kill')
		--ents.FindByName('dispenser_prop'):AcceptInput('Kill')
		ents.SpawnTemplate('DispenserPrizeSpawner')
	else
		ents.FindByName('prize_not_enough_tickets'):AcceptInput('Trigger')
		player:PlaySoundToSelf('replay/cameracontrolerror.wav')
	end
end

function SpawnDispenser(_,player)
	if player.hasDispenser ~= true then
		player.hasDispenser = true
		ents.SpawnTemplate('DispenserPrize', {translation = Vector(0, 0, 50), parent = player})
	end
	ents.FindByName('dispenser_touchtrigger'):AcceptInput('Disable')
	timer.Simple(0.1, function() ents.FindByName('dispenser_touchtrigger'):AcceptInput('Enable') end)
end

function ResetDispenser()
	DispenserBought = false
	ents.FindByName('dispenser_particles'):AcceptInput('Kill')
	ents.FindByName('dispenser_particles2'):AcceptInput('Kill')
	ents.FindByName('dispenser_spawner'):AcceptInput('Kill')
	ents.SpawnTemplate('DispenserPrizeBuy')
end

function OnPlayerConnected(player)
	if player:IsRealPlayer() then
		player:AddCallback(ON_SPAWN, function() player.hasDispenser = false player.Core = 0 end)
		player:AddCallback(ON_DEPLOY_WEAPON , function(_, weapon) player.ActiveWeapon = weapon:GetClassname() end)
	end
end

function OnPlayerDisconnected(player)
	if player:IsRealPlayer() then
		if player.TrailTimer ~= nil then
			timer.Stop(player.TrailTimer)
		end
	end
end

function Alarm(_,player)
	if player:IsBot() == true then
		ents.FindByClass("func_flagdetectionzone"):AcceptInput('AddOutput', 'alarm 1')
	else
		ents.FindByClass("func_flagdetectionzone"):AcceptInput('AddOutput', 'alarm 0')
	end
end

function Used(prize)
	if prize == 'nuke' then
		NukeUsed = true
	elseif prize == 'emp' then
		EMPUsed = true
	elseif prize == 'shield' then
		ShieldBought = false
		ShieldCounter = 0
	else
		if prize > ShieldCounter then
			ShieldCounter = prize
		end
	end
end

function SpawnTankChips(chips,tank)
	TankChipsAmount = chips
	ents.SpawnTemplate('TankChipDrop', {translation = Vector(0, 0, 32), parent = tank, ignoreParentAliveState = true})
	ChipsCountdown = timer.Create(1, function ()
		TankChipsAmount = TankChipsAmount - 1
		ents.FindByName("tanktext"):AcceptInput('SetText', 'Chips: ' .. TankChipsAmount)
		ents.FindByName("tank_drop_text"):AcceptInput('SetText', 'Chips: ' .. TankChipsAmount)
	end, chips)
end

function DropTankChips()
	if TankChipsAmount > 0 then
		timer.Stop(ChipsCountdown)
	end
end

function TankChips(_,activator,caller)
	if activator:IsRealPlayer() then
		caller:AcceptInput('Kill')
		TicketsOwned = TicketsOwned + TankChipsAmount
		ents.FindByName('tickets_text_counter_buffer'):AcceptInput('Add', TankChipsAmount)
		for _, player in pairs(ents.GetAllPlayers()) do
			player:PlaySoundToSelf('ui/scored.wav')
		end
	end
end

function SpawnSecret()
	if BossActive == true and SpecialPrize == true then
		ents.FindByName('spawnbot_mercbotsecret'):AcceptInput('Enable')
		util.PrintToChatAll("\x078889CCBGM: Jackpot Sad Girl - syudou")
		ents.FindByName('bossbgm'):AcceptInput('PlaySound')
		BGMTimer = timer.Create(47.07, function()
			ents.FindByName('bossbgm'):AcceptInput('StopSound')
			ents.FindByName('bossbgm'):AcceptInput('PlaySound') end, 0)
	end
end

function ActivateSecret()
	BossActive = true
end

function OnWaveSuccess(wave)
	if wave == ents.FindByClass('tf_objective_resource').m_nMannVsMachineMaxWaveCount + 1 then
		if SpentChips == 0 then
			util.PrintToChatAll("\x07FFD700>>>>>>>>SPENDLESS CLEAR<<<<<<<<")
			util.PrintToChatAll("\x07FFD700>>>>>>>>SPENDLESS CLEAR<<<<<<<<")
			util.PrintToChatAll("\x07FFD700>>>>>>>>SPENDLESS CLEAR<<<<<<<<")
			util.PrintToChatAll("\x07FFD700>>>>>>>>SPENDLESS CLEAR<<<<<<<<")
			util.PrintToChatAll("\x07FFD700>>>>>>>>SPENDLESS CLEAR<<<<<<<<")
			util.PrintToChatAll("\x07FFD700>>>>>>>>SPENDLESS CLEAR<<<<<<<<")
		end
		if SpecialPrize == true then
			timer.Stop(BGMTimer)
			ents.FindByName('bossbgm'):AcceptInput('StopSound')
			util.PrintToChatAll("\x07FFD700>>>>>>>>EASTER EGG CLEAR<<<<<<<<")
			util.PrintToChatAll("\x07FFD700>>>>>>>>EASTER EGG CLEAR<<<<<<<<")
			util.PrintToChatAll("\x07FFD700>>>>>>>>EASTER EGG CLEAR<<<<<<<<")
			util.PrintToChatAll("\x07FFD700>>>>>>>>EASTER EGG CLEAR<<<<<<<<")
			util.PrintToChatAll("\x07FFD700>>>>>>>>EASTER EGG CLEAR<<<<<<<<")
			util.PrintToChatAll("\x07FFD700>>>>>>>>EASTER EGG CLEAR<<<<<<<<")
		end
	end
end

function OnGameTick()
	for _, player in pairs(ents.GetAllPlayers()) do
		if player:IsRealPlayer() == true then
			player:ShowHudText({
				channel = 1,
				x = 0.889,
				y = 0.35,
				r1 = 230,
				g1 = 194,
				b1 = 89,
				r2 = 203,
				g2 = 179,
				b2 = 37,
				fadeinTime = 0,
				fadeoutTime = 0,
				holdTime = 1},
				'Chips: ' .. TicketsOwned
			)
		end
	end
end

--[[ function ShowChips(chips)
	util.PrintToChatAll(chips)
end ]]