// mvm_hideout_b3.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		// Kill fish in func_fish_pool as it appears to crash Archive servers (fine on
		//  testing/local/etc.).
		// They sometimes report a NaN origin which seems to crash the server on occasion.
		// We don't register this as a fix as it is not an issue with the map but an
		//  as-of-yet undiagnosed issue on archive, and this whole "fix" is just a hack
		//  until the problem is identified.
		local tokill = []
		for (local f; f = Entities.FindByClassname(f, "fish");)
			tokill.push(f)
		for (local f; f = Entities.FindByClassname(f, "func_fish_pool");)
			tokill.push(f)
		foreach (e in tokill)
			e.Kill()
	}
}

function RunOnce() {
	local tokill = []
	for (local f; f = Entities.FindByClassname(f, "fish");)
		tokill.push(f)
	for (local f; f = Entities.FindByClassname(f, "func_fish_pool");)
		tokill.push(f)
	foreach (e in tokill)
		e.Kill()
}
