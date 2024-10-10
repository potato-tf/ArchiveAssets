// mvm_mansion_rc1d.bsp
const TF_DEATH_FEIGN_DEATH = 0x020
Events <- {
	point_ccmd = null
	effect_jarate = null

	function OnGameEvent_recalculate_holidays(_) {
		if (GetRoundState() != Constants.ERoundState.GR_STATE_PREROUND) return

		FixAllVisualizers()

        RegisterFix("Fixed effect_jarate overlay breaking when activating the Dead Ringer.")
        point_ccmd = Entities.CreateByClassname("point_clientcommand")
        effect_jarate = Entities.FindByName(null, "effect_jarate")
	}

	function OnGameEvent_player_death(params) {
        local player = GetPlayerFromUserID(params.userid)

        // True if death was feigned.
        if (params.death_flags & TF_DEATH_FEIGN_DEATH) {
            // Do nothing if effect_jarate is disabled.
            if (NetProps.GetPropBool(effect_jarate, "m_bDisabled")) return
            // Do nothing if the player is not jarated.
            if (!player.InCond(Constants.ETFCond.TF_COND_URINE)) return

            // Restore the Jarate screen overlay, fixing a bug where the Dead Ringer
            //  incorrectly clears it.
            // SetScriptOverlayMaterial() can't be used for this as it will persist when the
            //  jarate condition is removed.
            point_ccmd.AcceptInput("Command",
                "r_screenoverlay effects/jarate_overlay",
            player, null)
        }
	}
}
