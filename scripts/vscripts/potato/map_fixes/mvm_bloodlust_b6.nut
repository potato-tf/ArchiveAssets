// mvm_bloodlust_b6.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Fixed cash getting stuck in tank spawn.")
		local tankcollect = SpawnEntityFromTable("trigger_hurt", {
			origin = Vector(-5138, 3072, -370)
		})
		tankcollect.SetSize(Vector(), Vector(1426, 1001, 154))
		tankcollect.SetSolid(Constants.ESolidType.SOLID_BBOX)
	}
}
