// mvm_derelict_rc4.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		FixAllVisualizers()

		RegisterFix("Block an out-of-bounds access spot.")
		local oobA = Vector(-2026, -1041, 895)
		local oobB = Vector(-1908, -854, 1510.91)
		MakeForcefield(oobA, oobB)
		MakeNoBuild(oobA, oobB, NOBUILD_EXTENDALL)
	}
}
