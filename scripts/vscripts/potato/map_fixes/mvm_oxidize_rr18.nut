// mvm_oxidize_rr18.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Added the missing centre spawn.")
		// Properly mark the tank spawn nav squares as an invaders' spawn room.
		MarkAsSpawn([27, 73, 3438, 3440, 3441], Constants.ETFTeam.TF_TEAM_BLUE)
		// Add missing BLU func_respawnroom.
		MakeSpawnroom(Vector(-2688, 2688, 0), Vector(-1920, 3328, 60), Constants.ETFTeam.TF_TEAM_BLUE)

		RegisterFix("Fixed cash getting stuck in the tank spawn.")
		MakeTriggerHurt(Vector(-2688, 2688, 0), Vector(-1920, 3328, 60))
	}
}
