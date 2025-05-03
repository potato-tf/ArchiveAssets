// mvm_quetzal_rc5.bsp
const SF_TRIGGER_ALLOW_CLIENTS = 0x1
const SF_DOOR_SILENT = 0x1000

Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Fixed the forward station breaking on mission swap.")
		EntityOutputs.AddOutput(Entities.FindByClassname(null, "logic_auto"),
			"OnMapSpawn", "FrontStation", "Enable","",
        -1.0, 1)

		RegisterFix("Fixed players getting stuck in the tank barricade.")
		Entities.FindByName(null, "Tank_Barricade_Push").KeyValueFromInt(
			"spawnflags", SF_TRIGGER_ALLOW_CLIENTS)

		RegisterFix("Silenced door sounds on the tank barricade.")
		Entities.FindByName(null, "Tank_Barricade_Door").KeyValueFromInt(
			"spawnflags", SF_DOOR_SILENT)
	}
}
