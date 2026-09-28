::DisableSquad <-
{
	function BotTagCheck(bot)
	{
		if (bot.HasBotTag("disband_squad"))
			bot.DisbandCurrentSquad()
	}

	function OnGameEvent_player_spawn(params)
	{
		local bot = GetPlayerFromUserID(params.userid);
		if (!bot.IsBotOfType(Constants.EBotType.TF_BOT_TYPE))
			return

		EntFireByHandle(bot, "RunScriptCode", "DisableSquad.BotTagCheck(self)", -1.0, null, null)
	}

	function OnGameEvent_mvm_reset_stats(_)
	{
		local mvm_stats = Entities.FindByClassname(null, "tf_mann_vs_machine_stats")
		if (NetProps.GetPropInt(mvm_stats, "m_iCurrentWaveIdx") != 0)
			return

		delete ::DisableSquad
	}
}
__CollectGameEventCallbacks(DisableSquad)
