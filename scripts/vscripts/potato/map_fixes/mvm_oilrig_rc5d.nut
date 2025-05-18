// mvm_oilrig_rc5d.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Raised rain particle positions.")
		RegisterFix("Flagged rain particles as weather.")
		for (local rain; rain = Entities.FindByClassname(rain, "info_particle_system");) {
			if (rain.GetName() == "end_pit_destroy_particle") continue
			rain.SetAbsOrigin(rain.GetOrigin() + Vector(0.0, 0.0, 1300.0))
			rain.KeyValueFromInt("flag_as_weather", 1)
		}

		RegisterFix("Added the missing centre spawn.")
		// Add missing BLU func_respawnroom.
		// Note that since this is done in recalculate_holidays, round start nav
		//  recalculation has not happened yet so we don't need to manually mark the nav
		//  below the spawnroom to fix it (as the game will do this for us).
		local tankspawn = MakeSpawnroom(
			Vector(-520, -5450, 1063), Vector(-120, -5077, 1263),
			Constants.ETFTeam.TF_TEAM_BLUE
		)
	}
}
