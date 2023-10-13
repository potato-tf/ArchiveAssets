CUSTOM_CANTEENS = {}

local VANILLA_CANTEEN_CHARGE_ATTRIBUTES = {
	"critboost",
	"ubercharge",
	"refill_ammo",
	"recall",
	"building instant upgrade",
}

local canteenPlayers = {}

local function canteenMessage(activator, canteenName, playAudio)
	local team = activator.m_iTeamNum == 2 and "{red}" or "{blue}"

	for _, player in pairs(ents.GetAllPlayers()) do
		player["$DisplayTextChat"](player, team .. activator:GetPlayerName() .."{reset} has used their {9BBF4D}" .. canteenName .. " {reset}Power Up Canteen!")

		if playAudio then
			player["$PlaySoundToSelf"](player, "=35|mvm/mvm_used_powerup.wav")
		end
	end
end

local function hasVanillaCharges(canteen)
	for _, attr in pairs(VANILLA_CANTEEN_CHARGE_ATTRIBUTES) do
		if canteen:GetAttributeValue(attr) then
			return true
		end
	end

	return false
end

function CanteenSpawn(_, activator)
	local index = activator:GetHandleIndex()
	canteenPlayers[index] = {
		CustomCanteenData = nil
	}

	local canteen = activator:GetPlayerItemBySlot(LOADOUT_POSITION_ACTION)
	canteen.i_LastCanteenCharges = canteen.m_usNumCharges

	local think
	think = timer.Create(0.1, function()
		local function stop()
			canteenPlayers[index] = nil
			timer.Stop(think)
		end

		if not IsValid(activator) then
			stop()
			return
		end

		if not activator:IsAlive() then
			stop()
			return
		end

		if activator:GetPlayerItemBySlot(LOADOUT_POSITION_ACTION) ~= canteen then
			print("canteen changed")
			timer.Stop(think)
			return
		end

		if not canteenPlayers[index].CustomCanteenData then
			return
		end

		if hasVanillaCharges(canteen) then
			canteenPlayers[index].CustomCanteenData = nil
			return
		end

		-- if the canteen count was decreased, that means the player has used a canteen
		-- checking m_bUsingActionSlot means we bypass the internal stuff behind canteen usage such as cooldown
		-- while checking for canteen count changes happens after the internal stuff

		if canteen.m_usNumCharges >= canteen.i_LastCanteenCharges then
			return
		end

		-- so long as the canteen entity does not have any canteen attributes
		-- i.e 'critboost', 'ubercharge', 'building instant upgrade'
		-- no chat message will be displayed and no effect will be activated, canteen usage sound effect will still play
		-- we can fill in with our custom behavior

		canteenMessage(activator, canteenPlayers[index].CustomCanteenData.Display)
		canteenPlayers[index].CustomCanteenData.Effect(activator)

		canteen.i_LastCanteenCharges = canteen.m_usNumCharges

		-- remove canteen description when charges are out
		if canteen.m_usNumCharges <= 0 then
			canteen:SetAttributeValue("special item description", nil)
			return
		end
	end, 0)
end

-- can be used to let bots use custom canteens with FireInput
function ForceUseCanteen(canteenName, activator)
	local canteenIndex
	for i, canteenData in pairs(CUSTOM_CANTEENS) do
		if (canteenData.Display):lower() == canteenName:lower() then
			canteenIndex = i
			break
		end
	end

	if not canteenIndex then
		util.PrintToChatAll("No custom canteen data found for canteen " .. canteenName)
		return
	end

	local canteenData = CUSTOM_CANTEENS[canteenIndex]

	canteenMessage(activator, canteenData.Display, true)
	canteenData.Effect(activator)
end

function CanteenPurchase(tick, activator)
	local canteen = activator:GetPlayerItemBySlot(LOADOUT_POSITION_ACTION)

	-- assume only one custom canteen attribute are applied at once
	local purchasedCanteenIndex
	for i, canteenData in pairs(CUSTOM_CANTEENS) do
		if canteen:GetAttributeValue(canteenData.Attribute) then
			purchasedCanteenIndex = i
			break
		end
	end

	if not purchasedCanteenIndex then
		util.PrintToChatAll("No custom canteen data found. Make sure upgrade attribute matches canteen lua data")
		return
	end

	canteen.i_LastCanteenCharges = tick

	local index = activator:GetHandleIndex()

	local canteenData = CUSTOM_CANTEENS[purchasedCanteenIndex]

	canteen:SetAttributeValue("special item description", canteenData.Description)

	canteenPlayers[index].CustomCanteenData = canteenData
end