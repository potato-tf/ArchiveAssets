//works in tandem with watermedic.lua
::mimicListeners <- {
	playerBotPairs = {}

	reset = function() {
		delete ::mimicListeners
    }
	
	OnGameEvent_recalculate_holidays = function(_) {if(GetRoundState() == 3) reset()}
	OnGameEvent_mvm_wave_complete = function(_) {reset()}
	
	OnGameEvent_player_spawn = function(params) {
		local player = GetPlayerFromUserID(params.userid);
		
		if(IsPlayerABot(player)) {
			return
		}
		
		if(player.GetEntityIndex() in playerBotPairs) { //skips specs and latejoiners
			local botIndex = playerBotPairs[player.GetEntityIndex()]
			local bot = PlayerInstanceFromIndex(botIndex)
			local interruptstring = "interrupt_action -posent " + player.GetName() + " -lookposent " + player.GetName() 
				+ " -killlook -waituntildone -alwayslook"
			
			if(NetProps.GetPropInt(bot, "m_lifeState") != 0) { //no need if bot has been killed
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
	
	OnGameEvent_player_turned_to_ghost = function(params) {
		local player = GetPlayerFromUserID(params.userid);
		
		if(player.GetEntityIndex() in playerBotPairs) {
			local bot = PlayerInstanceFromIndex(playerBotPairs[player.GetEntityIndex()])
			bot.AcceptInput("$BotCommand", "stop interrupt action", null, null) //attr ignored by bots should remove this player from target pool
		}
	}
	
	registerPair = function(playerIndex, botIndex) {
		playerBotPairs[playerIndex] <- botIndex
	}
}
__CollectGameEventCallbacks(mimicListeners)