// mvm_bronx_rc2.bsp
Events <- {
	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		DisableAllBoneFollowers()
		FixFuncRotating()

		local logic_auto
		while (logic_auto = Entities.FindByClassname(logic_auto, "logic_auto")) {
			// There are three logic_autos on this map, and one of them is dead so we must
			//  skip over it to find a usable one.
			if (NetProps.GetPropInt(logic_auto, "m_iHammerID") == 825152) continue
			break
		}

		local fwd_engie
		while (fwd_engie = Entities.FindByClassname(fwd_engie, "prop_dynamic")) {
			if (NetProps.GetPropInt(fwd_engie, "m_iHammerID") != 790586) continue
			fwd_engie.KeyValueFromString("targetname", "fwd_engiebot")
			break
		}

		RegisterFix("Fixed the grinder not killing invulnerable players.")
		for (local pit; pit = Entities.FindByClassname(pit, "trigger_hurt");)
			if (pit.GetName() != "trigger_hurt_hatch_fire")
				// We can't break early here as the death pit is actually two triggers.
				pit.AcceptInput("SetDamage", "10000", null, null)

		RegisterFix("Fixed the forward station not re-opening after wave fail or mission swap.")
		EntityOutputs.AddOutput(logic_auto,
			"OnMapSpawn", "upgrade_zone", "Enable",
		null, -1, -1)

		RegisterFix("Fixed the forward station door never closing.")
		// The fwd_upgrade_door output on wave_start_relay is set to
		//  OnSpawn instead of OnTrigger.
		local wave_start_relay = Entities.FindByName(null, "wave_start_relay")
		EntityOutputs.RemoveOutput(wave_start_relay,
			"OnSpawn", "fwd_upgrade_door", "Close",
		null)
		EntityOutputs.AddOutput(wave_start_relay,
			"OnTrigger", "fwd_upgrade_door", "Close"
		null, -1, -1)

		// Forward station stuff appears to be some geometry? and don't render due to PVS
		//  sometimes. Our workaround is to give them EFL_IN_SKYBOX so they always pass
		//  the PVS test while transmitting.
		RegisterFix("Fixed the forward station door failing to render.")
		Entities.FindByName(null, "fwd_upgrade_door").AddEFlags(
			Constants.FEntityEFlags.EFL_IN_SKYBOX)

		RegisterFix("Fixed the forward station Engiebot failing to render.")
		fwd_engie.AddEFlags(Constants.FEntityEFlags.EFL_IN_SKYBOX)

		// Manually set fwd_engie to enable/disable draw as the door opens/closes for
		//  minor performance gains.
		EntityOutputs.AddOutput(wave_start_relay,
			"OnTrigger", "fwd_engiebot", "Disable"
		null, 3.0, -1)
		EntityOutputs.AddOutput(Entities.FindByName(null, "wave_start_ironman_relay"),
			"OnTrigger", "fwd_engiebot", "Disable"
		null, 3.0, -1)
		EntityOutputs.AddOutput(Entities.FindByName(null, "wave_finished_relay"),
			"OnTrigger", "fwd_engiebot", "Enable"
		null, -1, -1)
		EntityOutputs.AddOutput(logic_auto,
			"OnMapSpawn", "fwd_engiebot", "Enable"
		null, -1, -1)

		PrintMapFixes()
	}
}
