// mvm_doppler_b12.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Disabled visualizers on closed gates.")
		// This is basically just because they look quite weird, as there
		//  are already physical blockers here than can overlap.

		for (local v; v = Entities.FindByClassname(v, "func_respawnroomvisualizer");) {
			switch (NetProps.GetPropInt(v, "m_iHammerID")) {
				case 51633:
					v.KeyValueFromString("targetname", "__gate2white_vis")
					v.AcceptInput("Disable", "", null, null)
					continue
				case 54276:
					v.KeyValueFromString("targetname", "__gate2grey_vis")
					v.AcceptInput("Disable", "", null, null)
					continue
				case 70868:
					// This gate starts open.
					v.KeyValueFromString("targetname", "__gate0lower_vis")
					continue
			}
		}

		// Gate 2 white path door.
		EntityOutputs.AddOutput(Entities.FindByName(null, "gate2_spawn_door"),
			"OnClose", "__gate2white_vis", "Disable", "",
		-1.0, -1)
		EntityOutputs.AddOutput(Entities.FindByName(null, "gate2_spawn_door"),
			"OnFullyOpen", "__gate2white_vis", "Enable", "",
		-1.0, -1)

		// Gate 2 grey path door.
		EntityOutputs.AddOutput(Entities.FindByName(null, "gate2_spawn_door2"),
			"OnClose", "__gate2grey_vis", "Disable", "",
		-1.0, -1)
		EntityOutputs.AddOutput(Entities.FindByName(null, "gate2_spawn_door2"),
			"OnFullyOpen", "__gate2grey_vis", "Enable", "",
		-1.0, -1)

		// Gate 0 grey path door.
		EntityOutputs.AddOutput(Entities.FindByName(null, "gate0s2_entrance_door"),
			"OnClose", "__gate0lower_vis", "Disable", "",
		-1.0, -1)
		EntityOutputs.AddOutput(Entities.FindByName(null, "gate0s2_entrance_door"),
			"OnFullyOpen", "__gate0lower_vis", "Enable", "",
		-1.0, -1)
	}
}
