// mvm_outlands_rc2.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Fixed cash getting stuck inside the hatch.")
		MakeTriggerHurt(Vector(-192, -2560, -500), Vector(192, -2175, -350))

		RegisterFix("Fixed cash getting stuck in tank spawn.")
		MakeTriggerHurt(Vector(-1627, 2937, -274), Vector(-765, 3563, 217))

		RegisterFix("Blocked an out-of-bounds access spot.")
		MakeNoBuild(Vector(268, -260, 400), Vector(470, 80, 400), NOBUILD_EXTENDALL)
	}
}
