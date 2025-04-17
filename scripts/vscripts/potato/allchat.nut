::__potato.AllChat <- {
	// Set __potato.AllChat.Disabled = true to disable this functionality for your mission.
	Disabled = false

    maxclients = MaxClients().tointeger()

    alltalk_enabled = Convars.GetInt("sv_alltalk")

    TEAM_SPECTATOR = Constants.ETFTeam.TEAM_SPECTATOR

	Events = {
		function OnGameEvent_player_say(params) {

			if (Disabled || !alltalk_enabled) return
			local player = GetPlayerFromUserID(params.userid)
            local name = Convars.GetClientConvarValue("name", player.entindex())

			local text = params.text
			if (player.GetTeam() == TEAM_SPECTATOR)
			{
                for (local i = 1; i <= maxclients; i++)
                {
                    local p = PlayerInstanceFromIndex(i)
                    if (p && p != player && p.GetTeam() != TEAM_SPECTATOR)
                        ClientPrint(p, 3, format("\x07CCCCCC %s \x07FBECCB : %s", name, text))
                }
			}
		}
        function OnGameEvent_server_cvar(params)
        {
            if (params.cvarname == "sv_alltalk")
                alltalk_enabled = params.cvarvalue.tointeger()
        }
	}
}
::__potato.AllChat.setdelegate(::__potato)
::__potato.AllChat.Events.setdelegate(::__potato.AllChat)

__CollectGameEventCallbacks(::__potato.AllChat.Events)
