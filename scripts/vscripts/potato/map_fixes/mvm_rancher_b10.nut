// mvm_rancher_b10.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		RegisterFix("Added rendermode 1 and disablereceiveshadows to func_respawnroomvisualizer.")
		for (local vis; vis = Entities.FindByClassname(vis, "func_respawnroomvisualizer");) {
			NetProps.SetPropInt(vis, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)

			NetProps.SetPropInt(vis, "m_fEffects", 
				NetProps.GetPropInt(vis, "m_fEffects") | Constants.FEntityEffects.EF_NORECEIVESHADOW
			)
		}
	}
}
