::caberCallbacks <- {
	Cleanup = function() {
		delete ::caberCallbacks
    }
	
	OnGameEvent_recalculate_holidays = function(_) { //may want to delete this earlier if it's only for one wave
		if(GetRoundState() == 3) {
			Cleanup()
		} 
	}
	
	OnGameEvent_player_spawn = function(params) {
		local player = GetPlayerFromUserID(params.userid)
		
		if(!IsPlayerABot(player)) {
			return
		}

		if(player.GetTeam() != 3) {
			return
		}
		
		EntFireByHandle(player, "RunScriptCode", "caberCallbacks.addCaberThink(activator)", 1, player, null)
	}
	
	addCaberThink = function(player) {
		if(!player.HasBotTag("caberbot")) {
			return
		}

		//ClientPrint(null, 3, "Caber bot spawned")
		
		player.GetScriptScope().caber <- player.GetActiveWeapon() //should be caber since meleeonly
		player.GetScriptScope().caberThink <- function() {
			//ClientPrint(null, 3, caber.GetClassname())
			if(NetProps.GetPropInt(self, "m_lifeState") != 0) {
				AddThinkToEnt(self, null)
				NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
			}
			if(NetProps.GetPropBool(caber, "m_iDetonated")) {
				self.AddBotAttribute(SUPPRESS_FIRE)
				self.AddCustomAttribute("Hand scale", 1, -1)
				AddThinkToEnt(self, null)
				NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
			}
		}
		AddThinkToEnt(player, "caberThink")
	}
}

//ClientPrint(null, 3, "The script works probably")
__CollectGameEventCallbacks(caberCallbacks)