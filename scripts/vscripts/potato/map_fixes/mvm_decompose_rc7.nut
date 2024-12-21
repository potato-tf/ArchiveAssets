// mvm_decompose_rc7.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		FixAllVisualizers()
		// Also hide this front visualizer because it has a black alpha background.
		for (local vis; vis = Entities.FindByClassname(vis, "func_respawnroomvisualizer");) {
			if (NetProps.GetPropInt(vis, "m_iHammerID") != 47413) continue
			NetProps.SetPropInt(vis, "m_nRenderMode", Constants.ERenderMode.kRenderNone)
			break
		}

		// TODO: I want stronger confirmation that this is indeed fixed on RC7 before deleting this section.
		/* RegisterFix("Fixed bots getting stuck behind the wrong spawn door before gate capture.")
		// Setup gate teleport entities.
		SpawnEntityFromTable("info_teleport_destination", {
			targetname = "unstuck_dest"
			origin = Vector(164, -3048, 247)
		})
		local door_unstuck = SpawnEntityFromTable("trigger_teleport", {
			targetname = "unstuck_trigger"
			target = "unstuck_dest"
			origin = Vector(-4144, -3760, 0)
			spawnflags = 0x1  // SF_TRIGGER_ALLOW_CLIENTS
		})
		door_unstuck.SetSize(Vector(), Vector(1616, 688, 590))
		door_unstuck.SetSolid(Constants.ESolidType.SOLID_BBOX)

		// Enable/disable based on gate capture status.
		EntityOutputs.AddOutput(Entities.FindByName(null, "wave_reset_relay"),
			"OnTrigger", "unstuck_trigger", "Enable",
		null, -1, -1)
		EntityOutputs.AddOutput(Entities.FindByName(null, "gate01_relay"),
			"OnTrigger", "unstuck_trigger", "Disable",
		null, -1, -1) */
	}
}
