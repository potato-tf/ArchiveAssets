::__potato.HideRespawnText <- {
	// Set __potato.HideRespawnText.Disabled = true to disable this functionality for your mission.
	Disabled = false
	// Set to 1.0 to always show "Prepare to respawn" instead.
	texttype = 0.0

	// Respawn wave times (in seconds) exceeding this value will be hidden
	TimerThreshold = 1000.0

	// Check if we should hide text for this mission (RespawnWaveTime exceeds 1000s).
	function TestAndApply() {
		for (local player; player = Entities.FindByClassname(player, "player");) {
			if (player.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)) continue

			// Assume player team by team of the first human found.
			if (NetProps.GetPropFloatArray(hGamerules, "m_TeamRespawnWaveTimes", player.GetTeam()) < TimerThreshold
				// Check if sigesegv-mvm attribute is being used to raise respawn times.
				&& player.GetCustomAttribute("min respawn time", 0.0) < TimerThreshold) {
				AddThinkToEnt(hPlyrMgr, null)
				return
			}
			break
		}

		// Try not to interfere with map/mission scripts.
		if (hPlyrMgr.GetScriptThinkFunc() != "") return

		hPlyrMgr.GetScriptScope().RespawnTextThink <- function() {
			for (local player; player = Entities.FindByClassname(player, "player");) {
				if (player.IsBotOfType(Constants.EBotType.TF_BOT_TYPE) || player.IsAlive())
					continue
				NetProps.SetPropFloatArray(self, "m_flNextRespawnTime",
					::__potato.HideRespawnText.texttype, player.entindex())
			}
			return -1
		}
		AddThinkToEnt(hPlyrMgr, "RespawnTextThink")
	}

	Events = {
		// Fired every wave start.
		function OnGameEvent_mvm_begin_wave(_) {
			// We delay application because there's a bug where RespawnWaveTime is inherited from
			//  the first loaded mission for the setup period on any mission.
			if (Disabled) return
			EntFireByHandle(hPlyrMgr,
				"RunScriptCode", "::__potato.HideRespawnText.TestAndApply()"
			, 0.015, null, null)
		}
	}
}
::__potato.HideRespawnText.setdelegate(::__potato)
::__potato.HideRespawnText.Events.setdelegate(::__potato.HideRespawnText)

__CollectGameEventCallbacks(::__potato.HideRespawnText.Events)
