// mvm_production_rc6.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Fixed cash getting stuck in tank spawn.")
		MakeTriggerHurt(Vector(-1888, 1015, -136), Vector(-1264, 1295, -106))
	}
}
