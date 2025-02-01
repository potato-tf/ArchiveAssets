// mvm_frostwynd_rc1.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Fixed cash getting stuck in tank spawn.")
		MakeTriggerHurt(Vector(-3960, -2250, -660), Vector(-3450, -1270, -890))
	}
}
