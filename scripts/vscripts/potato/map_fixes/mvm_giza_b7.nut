// mvm_giza_b7.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		FixAllVisualizers()

		RegisterFix("Blocked an out-of-bounds access spot.")
		MakeForceField(Vector(-1280, -2048, 960), Vector(-768, -1912, 3072))
	}
}
