// mvm_dockyard_rc7.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Fixed the grinder not killing invulnerable players.")
		for (local pit; pit = Entities.FindByClassname(pit, "trigger_hurt");)
			pit.AcceptInput("SetDamage", "10000", null, null)
	}
}
