// If you are using PopExtensions+, you can instead use the HideRespawnText mission attribute.
if (!("HideRespawnText" in getroottable())) ::HideRespawnText <- {
    plyr_mgr = Entities.FindByClassname(null, "tf_player_manager")
    time = 0.0

    function RespawnTextThink() {
        for (local player; player = Entities.FindByClassname(player, "player");) {
            if (player.IsBotOfType(1337) || player.IsAlive() == true) continue
            NetProps.SetPropFloatArray(HideRespawnText.plyr_mgr, "m_flNextRespawnTime", HideRespawnText.time, player.entindex())
        }
        return -1
    }

	Events = {
		function OnGameEvent_teamplay_round_start(params) {
            AddThinkToEnt(HideRespawnText.plyr_mgr, null)
			delete ::HideRespawnText
		}
	}
}

HideRespawnText.plyr_mgr.ValidateScriptScope()
HideRespawnText.plyr_mgr.GetScriptScope().RespawnTextThink <- HideRespawnText.RespawnTextThink
AddThinkToEnt(HideRespawnText.plyr_mgr, "RespawnTextThink")

__CollectGameEventCallbacks(HideRespawnText.Events)
