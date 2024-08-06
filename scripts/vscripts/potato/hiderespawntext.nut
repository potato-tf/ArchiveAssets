__potato.HideRespawnText <- {
    // Set __potato.HideRespawnText.Disable = true to disable this functionality for your mission.
    Disable = false
    // Set to 1.0 to always show "Prepare to respawn" instead.
    texttype = 0.0

    // Check if we should hide text for this mission (RespawnWaveTime exceeds 1000s).
    function TestAndApply() {
        // Hack to guess if players are on RED or BLU
        for (local player; player = Entities.FindByClassname(player, "player");) {
            if (player.IsBotOfType(1337)) continue
            if (NetProps.GetPropFloatArray(gamerules, "m_TeamRespawnWaveTimes", player.GetTeam()) < 1000.0
                && player.GetCustomAttribute("min respawn time", 0.0) < 1000.0) {
                AddThinkToEnt(plyrmgr, null)
                return
            }
            break
        }

        if (plyrmgr.GetScriptThinkFunc() != "") return

        plyrmgr.GetScriptScope().RespawnTextThink <- function() {
            for (local player; player = Entities.FindByClassname(player, "player");) {
                if (player.IsBotOfType(1337) || player.IsAlive() == true) continue
                NetProps.SetPropFloatArray(self, "m_flNextRespawnTime", __potato.HideRespawnText.texttype, player.entindex())
            }
            return -1
        }
        AddThinkToEnt(plyrmgr, "RespawnTextThink")
    }

    Events = {
        // Fired every wave start.
        function OnGameEvent_mvm_begin_wave(_) {
            if (__potato.HideRespawnText.Disable) return
            EntFireByHandle(plyrmgr, "RunScriptCode", "__potato.HideRespawnText.TestAndApply()", 0.015, null, null)
        }
    }
}
__potato.HideRespawnText.setdelegate(__potato)
__potato.HideRespawnText.Events.setdelegate(__potato.HideRespawnText)

__CollectGameEventCallbacks(__potato.HideRespawnText.Events)
