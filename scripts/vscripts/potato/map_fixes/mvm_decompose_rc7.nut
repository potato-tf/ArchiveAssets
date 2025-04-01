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
	}
}
