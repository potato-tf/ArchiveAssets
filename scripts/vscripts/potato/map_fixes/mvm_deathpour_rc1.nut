// mvm_deathpour_rc1.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		FixAllVisualizers()

		printl(NOBUILD_EXTENDVERTICAL)
		RegisterFix("Blocked a buster godspot.")
		MakeNoBuild(
			Vector(688, -3056, 112),
			Vector(765, -3205, 82),
			NOBUILD_EXTENDVERTICAL
		)
	}
}
