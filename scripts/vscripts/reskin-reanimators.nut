// This helper script changes the reanimator model dropped by players on death.
// It is primarily used to provide the BLU reanimator sometimes used in reverse missions.
// It can be included in your popfile in Wave 1 and will apply for the rest of the mission.

// Example inclusion:
//  InitWaveOutput
//  {
//      Target BigNet
//      Action RunScriptCode
//      Param "IncludeScript(`reskin-reanimators.nut`)"
//  }

// You should also include the reanimator model using a sigsegv-mvm precache so that it is
//  added to the download table on Potato servers.
// It looks like this in your WaveSchedule block:
//  PrecacheModel "models/props_mvm/mvm_revive_tombstone_blu.mdl" [$SIGSEGV]

// Report any bugs or feature requests regarding this script to fellen.

::ROOT <- getroottable()
if ("ReskinReanimators" in ROOT) return
if (!("ConstantNamingConvention" in ROOT))
	foreach (a, b in Constants)
		foreach (k, v in b)
			ROOT[k] <- v != null ? v : 0

::ReskinReanimators <- {

	// === CONFIGURATION ===
	// Set the ETFTeam for which reanimators should be provided for.
	TargetTeam = TF_TEAM_BLUE
	// Revive marker model override.
	// Default model created by lite.
	ReviveTombstone = "models/props_mvm/mvm_revive_tombstone_blu.mdl"
	// === END CONFIGURATION ===

	// Unimplemented: Set to true to allow tf_bots to drop reanimators.
	AllowBots = false

	IsSigmod = Convars.GetBool("sig_etc_misc") != null
	sig_blue_allow_revive = Convars.GetBool("sig_mvm_jointeam_blue_allow_revive") ? true : false

	// Returns true if this player's reanimator should be modified.
	function AllowTargetPlayer(p)
		return AllowBots || !p.IsBotOfType(TF_BOT_TYPE)
			|| TargetTeam == TEAM_ANY || p.GetTeam() == TargetTeam

	// Fired every player death.
	function OnGameEvent_player_death(params) {
		local p = GetPlayerFromUserID(params.userid)
		if (!AllowTargetPlayer(p)) return

		// Non-functional reanimators are dropped by BLU in vanilla, kill them here.
		if (!IsSigmod && p.GetTeam() != TF_TEAM_RED) {
			for (local m; m = FindByClassname(m, "entity_revive_marker");) {
				if (m.GetOwner() != null) continue
				m.Kill()
				break
			}
		}

		// Modify our marker entity model.
		local marker = null
		if (p.GetTeam() == TF_TEAM_RED || (sig_blue_allow_revive && p.GetTeam() == TF_TEAM_BLUE)) {
			// The game or sigsegv-mvm will make our revive marker for us, simply find it.
			for (local m; m = Entities.FindByClassname(m, "entity_revive_marker");) {
				if (NetProps.GetPropEntity(m, "m_hOwner") != p) continue
				marker = m
				break
			}
		} else {
			// We must make our own revive marker.
			p.ValidateScriptScope()
			marker = SpawnEntityFromTable("entity_revive_marker", {
				origin = player.GetOrigin() + Vector(0, 0, 50)
				angles = player.GetAbsAngles()
			})
			NetProps.SetPropEntity(marker, "m_hOwner", p) // CBaseEntity.SetOwner() does not work here.
			marker.SetTeam(p.GetTeam())
			marker.SetBodygroup(marker.FindBodygroupByName("class"), p.GetPlayerClass() - 1)
			p.GetScriptScope().ReviveMarker <- marker // Store the marker for manual deletion later.
		}
		if (!marker || !marker.IsValid()) return
		marker.SetModelSimple(ReviveTombstone)
		marker.AddSolidFlags(Constants.FSolid.FSOLID_CUSTOMRAYTEST|Constants.FSolid.FSOLID_CUSTOMBOXTEST)
	}

	// Clean up lingering revive markers whenever a player spawns.
	function OnGameEvent_player_spawn(params) {
		local p = GetPlayerFromUserID(params.userid)
		if (!AllowTargetPlayer(p)) return

		p.ValidateScriptScope()
		local scope = p.GetScriptScope()
		if ("ReviveMarker" in scope && scope.ReviveMarker.IsValid())
			scope.ReviveMarker.Kill()
	}

	// Clean up lingering revive markers whenever a player disconnects.
	function OnGameEvent_player_disconnect(params) {
		local p = GetPlayerFromUserID(params.userid)
		if (!p || !AllowTargetPlayer(p)) return

		p.ValidateScriptScope()
		local scope = p.GetScriptScope()
		if ("ReviveMarker" in scope && scope.ReviveMarker.IsValid())
			scope.ReviveMarker.Kill()
	}

	// Fired every round reset or intermission.
	function OnGameEvent_recalculate_holidays(_) {
		// Filter out any intermissions.
		if (GetRoundState() != GR_STATE_PREROUND) return

		// Delete any ReviveMarker references stored on players.
		for (local p; p = Entities.FindByClassname(p, "player");)
			try p.GetScriptScope().ReviveMarker catch(_) continue

		// Clean-up the script if we're on wave 1 so that it doesn't leak in to other missions.
		if (NetProps.GetPropInt(
			Entities.FindByClassname(null, "tf_mann_vs_machine_stats"),
			"m_iCurrentWaveIdx") == 0
		) {
			for (local p; p = Entities.FindByClassname(p, "player");)
				try delete p.GetScriptScope().ReviveMarker catch(_) continue
			delete ::ReskinReanimators
		}
	}
}
__CollectGameEventCallbacks(::ReskinReanimators)

for (local p; p = Entities.FindByClassname(p, "player");)
	p.ValidateScriptScope()
