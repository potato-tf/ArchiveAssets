// Simple script file to apply "damage force reduction" 0 to all giants.
//  This is the default behaviour for BLU giants, but RED giants (reverse) will often be
//   launched by high damage sources like backstabs as it is not applied by default,
//    and it's common for mission makers to forget to apply this attribute manually.

if ("NoGiantKnockback" in getroottable())
	return

::NoGiantKnockback <-
{
	TICK_INTERVAL = floor(1000.0 / Convars.GetFloat("sv_maxupdaterate")) / 1000.0
	mvm_stats = Entities.FindByClassname(null, "tf_mann_vs_machine_stats")

	function OnGameEvent_player_spawn(params)
	{
		local bot = GetPlayerFromUserID(params.userid)
		if (!bot.IsBotOfType(Constants.EBotType.TF_BOT_TYPE))
			return

		EntFireByHandle(bot, "RunScriptCode", "if (self.IsMiniBoss()) self.AddCustomAttribute(`damage force reduction`, 0.0, 0.0)", TICK_INTERVAL, null, null)
	}

	function OnGameEvent_recalculate_holidays(_)
	{
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND)
			return

		if (NetProps.GetPropInt(mvm_stats, "m_iCurrentWaveIdx") != 0)
			return

		delete ::NoGiantKnockback
	}
}
__CollectGameEventCallbacks(NoGiantKnockback)
