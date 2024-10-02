// mvm_outlands_rc2.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return
		
		RegisterFix("Fixed cash getting stuck inside the hatch.")
		local hatchcollect = SpawnEntityFromTable("trigger_hurt", {
			origin = Vector(-192, -2560, -500)
		})
		hatchcollect.SetSize(Vector(), Vector(384, 385, 150))
		hatchcollect.SetSolid(Constants.ESolidType.SOLID_BBOX)

		RegisterFix("Fixed cash getting stuck in tank spawn.")
		local tankcollect = SpawnEntityFromTable("trigger_hurt", {
			origin = Vector(-1627, 2937, -274)
		})
		tankcollect.SetSize(Vector(), Vector(862, 626, 491))
		tankcollect.SetSolid(Constants.ESolidType.SOLID_BBOX)
	}
}
