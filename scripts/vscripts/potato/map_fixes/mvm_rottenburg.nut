// mvm_rottenburg.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return
		
		local barricade = Entities.FindByName(null, "Barricade")

		RegisterFix("Fixed the tank barricade turning invisible.")
		barricade.AddEFlags(Constants.FEntityEFlags.EFL_IN_SKYBOX)
		
		RegisterFix("Fixed client prediction errors on the tank barricade.")
		barricade.SetSolidFlags(Constants.ESolidType.SOLID_NONE)
	}
}
