// mvm_quetzal_rc5.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Fixed the forward station breaking on mission swap.")
		EntityOutputs.AddOutput(Entities.FindByClassname(null, "logic_auto"),
			"OnMapSpawn", "FrontStation", "Enable","",
        -1.0, 1)
	}
}
