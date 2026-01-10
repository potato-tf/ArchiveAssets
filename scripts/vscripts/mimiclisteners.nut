//works in tandem with watermedic.lua
::mimicListeners <- {
	playerBotPairs = {}

	function reset() {
		delete ::mimicListeners
    }
	
	function OnGameEvent_recalculate_holidays(_) {if(GetRoundState() == 3) reset()}
	function OnGameEvent_mvm_wave_complete(_) {reset()}
	
	function OnGameEvent_player_spawn(params) {
		local player = GetPlayerFromUserID(params.userid);
		
		if(IsPlayerABot(player)) {
			return
		}
		
		if(player.GetEntityIndex() in playerBotPairs) { //skips specs and latejoiners
			local botIndex = playerBotPairs[player.GetEntityIndex()]
			local bot = PlayerInstanceFromIndex(botIndex)
			local interruptstring = "interrupt_action -posent " + player.GetName() + " -lookposent " + player.GetName() 
				+ " -killlook -waituntildone -alwayslook"
			
			if(!bot.IsAlive()) { //no need if bot has been killed
				return
			}
			
			for(local i = 0; i < 8; i++) {
				local wep = NetProps.GetPropEntityArray(bot, "m_hMyWeapons", i)
				if(wep == null) continue
				
				if(wep.GetClassname() == "tf_weapon_crossbow") {
					interruptstring = interruptstring + " -distance 1500"
					break
				}
			}
			bot.AcceptInput("$BotCommand", interruptstring, null, null)
		}
	}
	
	function OnGameEvent_player_turned_to_ghost(params) {
		local player = GetPlayerFromUserID(params.userid);
		
		if(player.GetEntityIndex() in playerBotPairs) {
			local bot = PlayerInstanceFromIndex(playerBotPairs[player.GetEntityIndex()])
			bot.AcceptInput("$BotCommand", "stop interrupt action", null, null) //attr ignored by bots should remove this player from target pool
		}
	}
	
	function registerPair(playerIndex, botIndex) {
		playerBotPairs[playerIndex] <- botIndex
	}
}
__CollectGameEventCallbacks(mimicListeners)