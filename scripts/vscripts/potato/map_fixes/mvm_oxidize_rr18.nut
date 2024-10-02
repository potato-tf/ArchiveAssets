// mvm_oxidize_rr18.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Added the missing centre spawn.")
		// Properly mark the tank spawn nav squares as an invaders' spawn room.
		foreach (tanknav in [27, 73, 3438, 3440, 3441]) {
			tanknav.SetAttributeTF(Constants.FTFNavAttributeType.TF_NAV_SPAWN_ROOM_BLUE)
			tanknav.ClearAttributeTF(Constants.FTFNavAttributeType.TF_NAV_BOMB_CAN_DROP_HERE)
		}
		
		// Add missing BLU func_respawnroom.
		local tankspawn = SpawnEntityFromTable("func_respawnroom", {
			origin = Vector(-2688, 2688, 0)
			TeamNum = Constants.ETFTeam.TF_TEAM_BLUE
		})
		tankspawn.SetSize(Vector(), Vector(768, 640, 60))
		tankspawn.SetSolid(Constants.ESolidType.SOLID_BBOX)

		RegisterFix("Fixed cash getting stuck in the tank spawn.")
		// Collect cash that drops in tank spawn.
		local tankcollect = SpawnEntityFromTable("trigger_hurt", {
			origin = Vector(-2688, 2688, 0)
		})
		tankcollect.SetSize(Vector(), Vector(768, 640, 60))
		tankcollect.SetSolid(Constants.ESolidType.SOLID_BBOX)
	}
}
