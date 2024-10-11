// mvm_downpour_rc3a.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		FixAllVisualizers()

		RegisterFix("Blocked a buster godspot.")
		MakeNoBuild(
			Vector(688, -3056, 112),
			Vector(765, -3205, 82),
			NOBUILD_EXTENDVERTICAL
		)
	}
}
