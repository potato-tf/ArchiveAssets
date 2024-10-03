// mvm_giza_b7.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		FixAllVisualizers()

		RegisterFix("Blocked an out-of-bounds access spot.")
		local oobA = Vector(-1280, -2048, 960)
		local oobB = Vector(-768, -1912, 3072)
		MakeForceField(oobA, oobB)
		MakeNoBuild(oobA, oobB)
	}
}
