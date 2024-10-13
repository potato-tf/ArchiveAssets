// mvm_whitecliff_event_rc2.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return
		
		RegisterFix("Fixed the forward station breaking on mission swap.")

		EntityOutputs.AddOutput(Entities.FindByClassname(null, "logic_auto"),
			"OnMapSpawn", "FowardUpgradeStationTrigger", "Enable",
		null, -1, 1)
	}
}
