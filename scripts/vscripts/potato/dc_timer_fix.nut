// Fixes the setup timer not aborting when the only readied player disconnects.
// Based on this sourcemod plugin:
// https://github.com/mtxfellen/tf2-plugins/blob/199a0e4/addons/sourcemod/scripting/tf_readymodetimerfix.sp
::__potato.DCTimerFix <- {
	Disabled = false

	Events = {
		function OnGameEvent_player_disconnect(params) {
			if (Disabled) return
			local leaver = GetPlayerFromUserID(params.userid)

			// Note that both puppet bots and TFBots can be forced to ready up,
			//  but this is not relevant for potato so we just do nothing.
			if (leaver.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)) return

			// Do nothing if the countdown timer is uninterruptible or not running.
			if (NetProps.GetPropFloat(hGamerules, "m_flRestartRoundTime") <= Time() + 10.0) return
			// Alternatively: Do nothing only if the countdown timer is not running.
			//if (NetProps.GetPropFloat(hGamerules, "m_flRestartRoundTime") == -1.0) return

			// Do nothing if the disconnecting player was not readied.
			if (!NetProps.GetPropBoolArray(hGamerules, "m_bPlayerReady", leaver.entindex()))
				return
			// Fix the ready state of players persisting between sessions.
			NetProps.SetPropBoolArray(hGamerules, "m_bPlayerReady", false, leaver.entindex())

			for (local p; p = Entities.FindByClassname(p, "player");) {
				if (p.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)) continue
				if (p == leaver) continue

				// If a different player is readied, do nothing.
				if (NetProps.GetPropBoolArray(hGamerules, "m_bPlayerReady", p.entindex()))
					return
			}

			// Otherwise, stop the countdown!
			NetProps.SetPropFloat(hGamerules, "m_flRestartRoundTime", -1.0)
		}
	}
}
::__potato.DCTimerFix.setdelegate(::__potato)
::__potato.DCTimerFix.Events.setdelegate(::__potato.DCTimerFix)
__CollectGameEventCallbacks(::__potato.DCTimerFix.Events)
