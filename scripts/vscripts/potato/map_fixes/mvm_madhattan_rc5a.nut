// mvm_madhattan_rc5a.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Fixed the forward station breaking on wave fail/mission swap.")
		EntityOutputs.AddOutput(Entities.FindByClassname(null, "logic_auto"),
			"OnMapSpawn", "open_upgrade_relay", "Trigger",
		null, -1, 1)
	}
}
