// mvm_production_rc6.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Fixed cash getting stuck in tank spawn.")
		local tankcollect = SpawnEntityFromTable("trigger_hurt", {
			origin = Vector(-1888, 1015, -136)
		})
		tankcollect.SetSize(Vector(), Vector(624, 280, 30))
		tankcollect.SetSolid(Constants.ESolidType.SOLID_BBOX)
	}
}
