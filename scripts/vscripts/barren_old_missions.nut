/*
Disables the cramped path on Barren for old missions as there are reports of giants getting
stuck, and it can be blocked entirely with one sentry.

Can be enabled by including it in Wave 1 like so:
	InitWaveOutput
	{
		Target BigNet
		Action RunScriptCode
		Param "IncludeScript(`barren_old_missions`, getroottable())"
	}
*/
::BarrenOldMissions <-
{
	function Init()
	{
		local bombpath_choose_1_case = Entities.FindByName(null, "bombpath_choose_1_case")
		EntityOutputs.RemoveOutput(bombpath_choose_1_case, "OnCase01", "bombpath_left_relay", "Trigger", "")
	}

	function OnGameEvent_teamplay_round_start(_)
	{
		Init()
	}

	function OnGameEvent_mvm_reset_stats(_)
	{
		local mvm_stats = Entities.FindByClassname(null, "tf_mann_vs_machine_stats")
		if (NetProps.GetPropInt(mvm_stats,"m_iCurrentWaveIdx") == 0)
			delete ::BarrenOldMissions
	}
}
__CollectGameEventCallbacks(BarrenOldMissions)
BarrenOldMissions.Init()
