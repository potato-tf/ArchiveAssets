// mvm_giza_b7.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		FixAllVisualizers()

		RegisterFix("Blocked out-of-bounds access spot.")
		MakeForceField(Vector(-1024, -1980, 2016),
			Vector(-256, -68, -1056), Vector(256, 68, 1056))
	}
}
