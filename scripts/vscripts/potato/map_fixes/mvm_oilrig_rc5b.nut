// mvm_oilrig_rc5b.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Fixed missing rain weather particles.")
		// Kill broken rain particles.
		for (local rain; rain = Entities.FindByClassname(rain, "info_particle_system");) {
			if (rain.GetName() == "end_pit_destroy_particle") continue
			EntFireByHandle(rain, "Kill", null, -1, null, null)
		}

		// Spawn some Sawmill rain particles.
		local rain001 = [
			Vector(-2848, 384, 8810),   Vector(-1200, 1924, 3620), Vector(282, 1924, 3620),
			Vector(882, 1924, 3620),    Vector(-366, -608, 3620),  Vector(528, -608, 4100),
			Vector(1849, -291, 3420),   Vector(0, -1000, 1600),    Vector(1024, -1632, 4100),
			Vector(-1024, -1632, 4100), Vector(1562, -2210, 3620), Vector(-864, -3936, 3620),
			Vector(160, -4096, 4200),   Vector(320, -4960, 4300),  Vector(-704, -4960, 4300),
			Vector(1242, -4256, 3620),  Vector(-1146, -4702, 3620)
		]
		local rain002 = [Vector(-508, -2608, 1800), Vector(789, -2290, 1800), Vector(-324, -2694, 1800), Vector(-320, -3360, 1800)]
		foreach(vec in rain001) {
			SpawnEntityFromTable("info_particle_system", {
				origin = vec
				effect_name = "env_rain_001"
				start_active = 1
				flag_as_weather = 1
			})
		}
		foreach(vec in rain002) {
			SpawnEntityFromTable("info_particle_system", {
				origin = vec
				effect_name = "env_rain_002_256"
				start_active = 1
				flag_as_weather = 1
			})
		}

		RegisterFix("Added the missing centre spawn.")
		// Properly mark the tank spawn nav square as an invaders' spawn room.
		MarkAsSpawn(27, Constants.ETFTeam.TF_TEAM_BLUE)
		// Add missing BLU func_respawnroom.
		MakeSpawnroom(Vector(-520, -5450, 1063), Vector(-120, -5040, 1263), Constants.ETFTeam.TF_TEAM_BLUE)

		RegisterFix("Fixed cash getting stuck in the centre spawn.")
		MakeTriggerHurt(Vector(-520, -5450, 1063), Vector(-120, -5040, 1263))
	}
}
