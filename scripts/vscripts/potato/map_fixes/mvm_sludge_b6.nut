// mvm_sludge_b6.bsp
const SF_TRIGGER_ALLOW_NPCS = 0x2 // NPCs can fire this trigger.
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Block an out-of-bounds access spot.")
		MakeForcefield(Vector(-38, -2993, 3584), Vector(242, -890, 1178))

		RegisterFix("Fixed skeletons getting stuck in the forward upgrades station.")
		// Make a trigger that kills skeletons or skeleton skulls that touch it.
		local skelekill = SpawnEntityFromTable("trigger_multiple", {
			targetname = "potato_skelekill"
			spawnflags = SF_TRIGGER_ALLOW_NPCS
			wait = 0.1
			StartDisabled = true
		})
		SetupAABBox(skelekill, Vector(-191, -2567, 862), Vector(-80, -2289, 704))

		// Kill immobile skeletons for every 0.1s they are in the trigger.
		EntityOutputs.AddOutput(skelekill,
			"OnTrigger", "!activator", "RunScriptCode",
			"if(self.GetClassname()==`tf_zombie`&&self.IsImmobile())self.Kill()",
		-1, -1)

		// Use door outputs to only kill skeletons if they can get stuck (usually, if the wave is active).
		local ugs_door_push = Entities.FindByName(null, "ugs_door_push")
		EntityOutputs.AddOutput(ugs_door_push,
			"OnFullyClosed", "potato_skelekill", "Enable",
		"", -1, -1)
		EntityOutputs.AddOutput(ugs_door_push,
			"OnFullyOpen", "potato_skelekill", "Disable",
		"", -1, -1)
	}
}
