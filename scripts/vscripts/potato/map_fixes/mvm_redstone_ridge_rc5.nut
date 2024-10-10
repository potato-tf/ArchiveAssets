// mvm_redstone_ridge_rc5.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		FixAllVisualizers()

		RegisterFix("Blocked an out-of-bounds access location.")
		MakeNoBuild(Vector(912, -312, 47), Vector(197, 250, 51), NOBUILD_EXTENDALL)
		MakeNoBuild(Vector(-256, -176, 240), Vector(400, 320, 240), NOBUILD_EXTENDALL)
	}
}
