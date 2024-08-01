if (!("DisableSquad" in getroottable())) ::DisableSquad <-
{
	GLOBAL_CALLBACKS =
	{
		OnGameEvent_player_spawn = function(params)
		{
			local bot = GetPlayerFromUserID(params.userid);

			if (bot.IsFakeClient())
			{
				//printl("Bot spawn detected! Checking tags...")
				EntFireByHandle(bot, "RunScriptCode", "DisableSquad.BotTagCheck(self)", -1.0, null, null)
			}
		}

		OnGameEvent_teamplay_round_start = function(params)
		{
			delete ::DisableSquad
		}
	}

	BotTagCheck = function(bot)
	{
		if (bot.HasBotTag("disband_squad"))
		{
			//printl("Disbanding Squad...")
			bot.DisbandCurrentSquad()
		}
	}
}

__CollectGameEventCallbacks(DisableSquad.GLOBAL_CALLBACKS)
